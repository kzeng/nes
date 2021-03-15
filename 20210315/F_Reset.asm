;===============================================================================
                	SYNTAX        	6502
                	LINKLIST
                	SYMBOLS
			INCLUDE		System.inc
;===============================================================================
;下面是设置游戏属性的宏指令程序，用来指定游戏的程序数据和图像数据在闪存中的位置、
;容量、镜像、游戏入口地址、是否需要预先加载特定数据等
;输入参数：	P_A		游戏程序在闪存中的位置
;		P_S		游戏程序的容量
;		V_A		游戏图像在闪存中的位置
;		V_S		游戏图像的容量
;		H_V		游戏的镜像
;		G_P		游戏需要预处理
;-------------------------------------------------------------------------------
SetupGame       	macro   P_A,P_S,V_A,V_S,H_V,G_P
 
                	dw	P_A>>13					;00
                	dw	V_A>>13					;02
                	db	P_S					;04
                	db	V_S					;05
                	db	((G_P<<7) + H_V)			;06
                	endm
;===============================================================================
;下面是定义的常数，方便以后修改程序
;-------------------------------------------------------------------------------
C_MaxGame		equ	129					;合集中的最大 126 个游戏
;===============================================================================
                	ORG	$E000
;-------------------------------------------------------------------------------
;			asl	A
;			pha
;			lda	#$06
;			sta	$8000
;			pla
;			sta	$8001
;			clc
;			adc	#$01
;			pha
;			lda	#$07
;			sta	$8000
;			pla
;			sta	$8001
			
;			ret
			




Reset_Adr:

                	cld
                	sei
                	ldx     #$FF
                	txs
			inx
                	stx     $2000
                	stx     $2001
                	stx     $4015
                	lda	#$40
                	sta	$4017

WaitFor_Loop:

			lda	$2002
			bpl	WaitFor_Loop
WaitFor_Blnk:

			lda	$2002
			bmi	WaitFor_Blnk

			inx
			cpx	#$04
			bcc	WaitFor_Loop

                	sta     $E000
			lda	#$83
			sta	$A021
			lda	#$00
			sta	$A040
;-------------------------------------------------------------------------------
;下面把程序和图像寄存器规范化，以便适应小容量的游戏
;-------------------------------------------------------------------------------
                	ldx     #$00
                	ldy     #$00

Setup_VBank:    	

                	sty     $8000
                	stx     $8001
                	inx
                	iny
                	cpy     #$03
                	bcs     Setup_PBank

                	inx

Setup_PBank:    	

                	cpy     #$06
                	bcc     Setup_VBank

			ldx	#$00 
 			sty	$8000
 			stx	$8001
 			iny
 			inx
 			sty	$8000
 			stx	$8001

			ldx	#$00
			txa

Clear_Sram:

			sta	$0000,x
			sta	$0100,x
			sta	$0300,x
			sta	$0400,x
			sta	$0500,x
			sta	$0600,x
			sta	$0700,x
			inx
			bne	Clear_Sram

;			ldx	#$00

Setup_Sram:

			lda	Sram_Prg,x
			sta	P_Sram,x
			inx
			cpx	#$70
			bcc	Setup_Sram
;===============================================================================
;显示开机画面，先传送点阵数据到图像处理器缓存
;-------------------------------------------------------------------------------
Display_Logo:

			lda	#<A_Menudot				;数据地址设在点阵数据开始
			sta	V_Data_Adr
			lda	#>A_Menudot
			sta	V_Data_Adr+1

			ldx	#$00					;图像处理器地址 = 0000
			stx	$2006
			stx	$2006
			jsr	F_Decomp_PPU				;点阵数据解压到 0000 开始的缓存

			ldx	#$20					;图像处理器地址 = 2000
			lda	#$00
			stx	$2006
			sta	$2006

			tax
			tay

Clear_Code0:

			sta	$2007
			iny
			bne	Clear_Code0
			inx
			cpx	#$03
			bcc	Clear_Code0				;一直清除到 2400

Clear_Code1:
			
			sta	$2007
			iny
			cpy	#$40
			bcc	Clear_Code1				;接着清除到 2340

			lda	#<A_Menucod				;数据地址设在代码数据开始
			sta	V_Data_Adr
			lda	#>A_Menucod
			sta	V_Data_Adr+1

			jsr	F_Decomp_PPU				;代码数据解压到 2340 开始的缓存

			lda	#$20					;图像处理器地址 = 2048
			sta	$2006
			lda	#$48
			sta	$2006

			lda	#<A_Tital				;数据地址设在标题数据开始
			sta	V_Data_Adr
			lda	#>A_Tital
			sta	V_Data_Adr+1

			jsr	F_DispString				;显示一行字符

			lda	#$3F					;图像处理器地址 = 3F00
			ldy	#$00
			sta	$2006
			sty	$2006

Setup_Color:								;传送颜色数据

			lda	A_Menucol,y
			sta	$2007
			iny
			cpy	#$20
			bcc	Setup_Color

			ldx	#$00

Setup_Sprite:								;传送精灵定义数据

			lda	Sprite_Dat,x
			sta	$0200,x
			inx
			cpx	#$1C					;精灵由 7 个点阵块组成
			bcc	Setup_Sprite

			lda	#$F8

Clear_Sprite:								;多余的精灵定义内存，把精灵定义成隐藏

			sta	$0200,x
			inx
			bne	Clear_Sprite

			ldx	#$04

			lda	#$00					;屏幕窗口坐标定在00,00
			sta	V_SysFlge
			sta	V_Names_H
			sta	V_Names_L
			sta	V_Cursor

			jsr	F_DispName				显示一屏游戏名称
;===============================================================================
Main_Program:

			lda	V_SysFlge
			beq	Main_Program
			lda	#$00
			sta	V_SysFlge

			inc	V_Counter

			lda	V_Counter				;每4次中断，移动一次云朵
			and	#$03
			bne	Main_Program

			jsr	F_MoveCloud

			lda	V_Counter				;每8次中断，读取一次手柄
			and	#$07
			bne	Main_Program

			jsr	F_ReadKey
			lda	V_KeyCode
			bne	Process_Key

			lda	V_Counter				;每32次中断，改变一次光标颜色
			and	#$1F
			bne	Main_Program

			jsr	F_AlterColor
			jmp	Main_Program
;-------------------------------------------------------------------------------
;下面进行按键处理，先判断按下了哪个键，键值已经读到A中了
;-------------------------------------------------------------------------------
Process_Key:

			ldx	#$FF

Process_00:

			inx
			lsr	A
			bcc	Process_00

			txa
			asl	A
			tax

			lda	A_KeyProgram,x
			sta	V_PROM_Adr
			lda	A_KeyProgram+1,x
			sta	V_PROM_Adr+1
			jmp	(V_PROM_Adr)

A_KeyProgram:

			dw	PressKeyR				;00按的是向右
			dw	PressKeyL				;01按的是向左
			dw	PressKeyD				;02按的是向下
			dw	PressKeyU				;03按的是向上
			dw	PressKeyS				;04按的是开始
			dw	Main_Program				;05按的是选择，本程序没用到
			dw	PressKeyB				;06按的是 B
			dw	PressKeyA				;07按的是 A
;-------------------------------------------------------------------------------
;下面处理右键，功能是向后翻一屏，如果翻过了结尾，重新回到开始的那一屏
;-------------------------------------------------------------------------------
PressKeyR:
			jsr	F_GameSound				;发出音效
			jsr	F_TestName				;检查当前游戏编号是否已到结尾
			bcc	NormalKeyR				;没有到结尾，则正常翻屏

			lda	#$00					;到了结尾，则翻到开始屏
			sta	V_Names_H
			sta	V_Names_L

NormalKeyR:

			jsr	F_DispName				;显示一屏游戏名称
			jsr	F_TestName				;显示完成后再次游戏编号是否已到结尾
			bcc	Exit_Key_R				;没有到结尾，则不用检查光标

			jsr	F_TestCursor				;检查并设置光标的纵坐标

Exit_Key_R:

			jmp	Main_Program				;处理结束，返回主循环
;-------------------------------------------------------------------------------
;下面处理左键，功能是向前翻一屏，如果翻过了开始，重新回到最后的那一屏
;-------------------------------------------------------------------------------
PressKeyL:

			jsr	F_GameSound				;发出音效
			jsr	F_TestName				;检查当前游戏编号是否已到结尾
			bcc	NormalKeyL				;没有到结尾，则正常翻屏

			lda	#>((C_MaxGame/20-1)*20)			;当前显示的是最后一屏，则翻向倒数第2屏
			sta	V_Names_H
			lda	#<((C_MaxGame/20-1)*20)
			sta	V_Names_L
			jmp	Exit_Key_L

NormalKeyL:

			lda	V_Names_L				;游戏编号向前移40
			sec
			sbc	#040
			sta	V_Names_L
			lda	V_Names_H
			sbc	#$00
			sta	V_Names_H
			bcs	Exit_Key_L				;没有超过开始屏，则正常处理

			lda	#>(C_MaxGame/20*20)			;超出了范围，则显示最后一屏
			sta	V_Names_H
			lda	#<(C_MaxGame/20*20)
			sta	V_Names_L

			jsr	F_TestCursor				;显示最后一屏时，需要检查光标的位置

Exit_Key_L:
			jsr	F_DispName				;显示一屏游戏名称
			jmp	Main_Program				;处理结束，返回主循环
;-------------------------------------------------------------------------------
;下面处理下键，功能是光标向下移一行，如果超过最后一行，则向后翻一屏，并把光标移
;到最上面一行
;-------------------------------------------------------------------------------
PressKeyD:

			jsr	F_KeySound				;发出音效
			inc	V_Cursor				;光标向下移动一行
			jsr	F_TestName				;检查当前游戏编号是否已到结尾
			bcc	NormalKeyD				;没有到结尾，则显示的是正常屏

			lda	V_Cursor				;当前显示的是最后一屏，检查光标是否已经超过最后一行
			cmp	#(C_MaxGame-C_MaxGame/20*20)
			bcs	Next_KeyD				;如果光标超过最后一行，则向后翻屏

NormalKeyD:

			lda	V_Cursor				;当前显示的是正常屏，检查光标是否已经超过最后一行
			cmp	#020					;正常屏的最后一行是19
			bcs	Next_KeyD				;如果光标超过最后一行，则向后翻屏

			jsr	F_SetCursor				;光标没有超过最后一行，则设置光标的纵坐标
			jmp	Main_Program				;处理结束，返回主循环

Next_KeyD:

			lda	#00					;需要翻屏时，把光标移到最上面一行
			sta	V_Cursor
			jsr	F_SetCursor
			jmp	PressKeyR				;向后翻一屏
;-------------------------------------------------------------------------------
;下面处理上键，功能是光标向上移一行，如果超过最上一行，则向前翻一屏，并把光标移
;到最下面一行
;-------------------------------------------------------------------------------
PressKeyU:

			jsr	F_KeySound				;发出音效
			dec	V_Cursor				;光标向上移动一行
			bpl	NormalKeyU				;光标值大于或者等于 00 ，则没有超过最上面一行

			lda	#019					;光标超过了最上面一行，则把光标移到最下面
			sta	V_Cursor
			jsr	F_SetCursor				;设置光标的纵坐标
			jmp	PressKeyL				;向前翻一屏

NormalKeyU:

			jsr	F_SetCursor				;光标没有超过最上面一行，则设置光标的纵坐标
			jmp	Main_Program				;处理结束，返回主循环
;-------------------------------------------------------------------------------
;下面处理A键，功能是向后翻二屏，如果翻过了结尾，重新回到开始的那一屏
;-------------------------------------------------------------------------------
PressKeyA:

			lda	V_Names_L				;游戏编号向后移60
			clc
			adc	#020
			sta	V_Names_L
			lda	V_Names_H
			adc	#$00
			sta	V_Names_H
			jmp	PressKeyR				;右键处理程序会判断是否超过范围
;-------------------------------------------------------------------------------
;下面处理B键，功能是向前翻二屏，如果翻过了开始屏，则翻到倒数第四屏
;-------------------------------------------------------------------------------
PressKeyB:

			jsr	F_TestName				;检查当前游戏编号是否已到结尾
			bcc	NormalKeyB				;没有到结尾，则正常翻屏

			lda	#>(C_MaxGame/20*20)			;到了结尾，游戏编号设成最后一屏的开始
			sta	V_Names_H
			lda	#<(C_MaxGame/20*20)
			sta	V_Names_L
			jmp	PressKeyL				;由左键功能翻屏

NormalKeyB:



			lda	V_Names_L				;游戏编号向前移20
			sec
			sbc	#020
			sta	V_Names_L
			lda	V_Names_H
			sbc	#$00
			sta	V_Names_H
			bcs	Exit_Key_B				;没有超过开始屏，则正常翻屏

			lda	#$00
			sta	V_Names_H
			sta	V_Names_L

Exit_Key_B:

;			jsr	F_DispName
			jmp	PressKeyL				;处理结束，返回主循环
;-------------------------------------------------------------------------------
;下面处理开始键，功能是判断光标所指的是哪个游戏，加载游戏设置所需要的数据，跳转
;到游戏程序的入口地址，执行对应的游戏程序。
;-------------------------------------------------------------------------------
PressKeyS:

			jsr	F_ClearAll
			jsr	F_GameSound				;发出音效

			lda	#<A_GameTbl				;设置游戏名称列表地址
			sta	V_PROM_Adr
			lda	#>A_GameTbl
			sta	V_PROM_Adr+1

			jsr	F_TestName				;检查当前游戏编号是否已到结尾
			bcc	NormalKeyS				;没有到结尾，则正常运行

			lda	#<(C_MaxGame/20*20)			;到了结尾，则光标所指的游戏编号是最后一屏的起点+光标值
			clc
			adc	V_Cursor
			tay
			lda	#>(C_MaxGame/20*20)
			adc	#$00
			tax
			jmp	GetGame_Data

NormalKeyS:

			lda	V_Names_L
			sec
			sbc	#020
			tay
			lda	V_Names_H
			sbc	#$00
			tax

			tya
			clc
			adc	V_Cursor
			tay
			bcc	GetGame_Data

			inx
GetGame_Data:

			tya
			asl	A
			tay

			txa
			rol	A
			adc	V_PROM_Adr+1
			sta	V_PROM_Adr+1

			lda	(V_PROM_Adr),y				;获取游戏名称字符串地址
			sta	V_Data_Adr
			iny
			lda	(V_PROM_Adr),y
			sta	V_Data_Adr+1

			ldy	#$00

StartKey_Loop:

			lda	(V_Data_Adr),y				;获取游戏名称字符串地址
			sta	D_Sram,y
			iny
			cpy	#$10
			bcc	StartKey_Loop

			lda	D_Sram+6
			sta	$A000
			bmi	Into_GameSet

			jmp	P_Sram

Into_GameSet:

			jmp	(D_Sram+7)
;===============================================================================
;下面是本程序使用的内部子程序
;===============================================================================
;把由cmpt.exe压缩的各种图像数据，解压到图像缓存器中。
;-------------------------------------------------------------------------------
;输入：		V_Data_Adr	=	压缩数据地址
;		$2006		=	调用前设好图像缓存地址
;破坏：		A，X，Y，以及用到的其它内存单元
;-------------------------------------------------------------------------------
F_Decomp_PPU:

                	ldy     #$00
                	lda     (V_Data_Adr),y
                	sta     V_Decomp_L
                	iny
                	lda     (V_Data_Adr),y
                	sta     V_Decomp_H
                	lda     V_Data_Adr
                	clc
                	adc     #$02
                	sta     V_Data_Adr
                	bcc     Decomp_Start
                	inc     V_Data_Adr+1

Decomp_Start:

                	ldy     #$08
                	lda     (V_Data_Adr),y
                	sta     V_Decomp_F
                	lda     #$00
                	sta     V_Decomp_X
                	lda     #$09
                	sta     V_Decomp_Y

Decomp_Lp00:    	

                	ldx     #$01
                	lsr     V_Decomp_F
                	bcc     Not_Repeat
                	ldy     V_Decomp_Y
                	inc     V_Decomp_Y
                	lda     (V_Data_Adr),y
                	tax

Not_Repeat:  	

                	ldy     V_Decomp_X
                	lda     (V_Data_Adr),y

Decomp_Lp01:    	

                	sta     $2007
                	dec     V_Decomp_L
                	bne     Decomp_Next
                	dec     V_Decomp_H
                	beq     Decomp_Exit

Decomp_Next:    	

                	dex
                	bne     Decomp_Lp01
                	inc     V_Decomp_X
                	lda     V_Decomp_X
                	cmp     #$08
                	bcc     Decomp_Lp00
                	lda     V_Data_Adr
                	clc
                	adc     V_Decomp_Y
                	sta     V_Data_Adr
                	bcc     Decomp_Start
                	inc     V_Data_Adr+1
                	bne     Decomp_Start

Decomp_Exit:    	

                	ret
;===============================================================================
;显示一屏游戏名字，定义的游戏名字字符串后面加 00 表示结束
;-------------------------------------------------------------------------------
;输入：		V_Data_Adr	=	字符串数据地址
;		$2006		=	调用前设好图像缓存地址
;破坏：		A，X，Y，以及用到的其它内存单元
;-------------------------------------------------------------------------------
F_DispName:

			lda	#$00
			sta	$2000
			sta	$2001

			lda	#$20					;先把显示区清屏，以免残留以前的显示
			sta	$2006					;设置图像缓存地址 = 2060
			sta	V_R2006_H				;并把高位地址保存起来
			lda	#$A0
			sta	$2006

			lda	#$00
			tax
			tay

Dispname_0:

			sta	$2007
			iny
			bne	Dispname_0
			inx
			cpx	#$02
			bcc	Dispname_0				;一直清除到 22A0

Dispname_1:

			sta	$2007
			iny
			cpy	#$80
			bcc	Dispname_1				;接着清除到 2320

			lda	#$A4			
			sta	V_R2006_L				;设置显示起点的低地址

Dispname_2:

			jsr	F_NameBcd				;把游戏编号转换成用于显示的代码

			lda	V_R2006_H				;先显示游戏编号
			sta	$2006
			lda	V_R2006_L
			sta	$2006

			lda	V_BcdDatH				;显示百位
			sta	$2007
			lda	V_BcdDatM				;显示十位
			sta	$2007
			lda	V_BcdDatL				;显示个位
			sta	$2007
			lda	#$00					;显示一个空格
			sta	$2007

			jsr	F_GetNameAdr				;获取字符串地址
			jsr	F_DispString				;显示一行字符串
			jsr	F_IncNameAdr				;游戏编号加一，并判断是否超过最大值
			bcs	Dispname_3				;如果超出了范围，则退出

			lda	V_R2006_L
			adc	#$20
			sta	V_R2006_L
			lda	V_R2006_H
			adc	#$00
			sta	V_R2006_H
			cmp	#$23					;检查显示是否超过预定的区域
			bcc	Dispname_2
			lda	V_R2006_L
			cmp	#$20
			bcc	Dispname_2

Dispname_3:

			lda	#$80
			sta	$2000
			lda	#$1E
			sta	$2001
			lda	#$00
			sta	$2005
			sta	$2005

			ret
;===============================================================================
;把游戏编号数值，转换成屏幕代码，程序使用的游戏编号从 00 开始，显示的游戏编号从
;001开始，因此先把游戏编号加01后，再进行转换。
;-------------------------------------------------------------------------------
;输入：		V_Names_H	=	游戏编号高位
;		V_Names_L	=	游戏编号低位
;输出		V_BcdDatH	=	屏幕代码的百位
;		V_BcdDatM	=	屏幕代码的十位
;		V_BcdDatL	=	屏幕代码的个位
;破坏：		A，X，Y
;-------------------------------------------------------------------------------
F_NameBcd:

			lda	V_Names_L
			clc
			adc	#$01
			sta	V_BcdDatL
			lda	V_Names_H
			adc	#$00
			sta	V_BcdDatM

			ldx	#$10					;预设屏幕代码为"0"
			sec

NameBcd_0:

			lda	V_BcdDatL
			sbc	#<0100					;减10进制数100的低位
			tay						;先保存起来，因为不知道是否够减
			lda	V_BcdDatM
			sbc	#>0100					;减10进制数100的高位
			bcc	NameBcd_1				;如果不够减，则数据没有百位
			sta	V_BcdDatM				;够减，则保存减去100以后的结果
			sty	V_BcdDatL
			inx						;记录百位的个数
			bne	NameBcd_0

NameBcd_1:

			stx	V_BcdDatH				;保存转换出来的百位
			ldx	#$10					;重置屏幕代码，准备转换十位
			sec

NameBcd_2:

			lda	V_BcdDatL
			sbc	#$0A
			bcc	NameBcd_3				;如果不够减，则数据没有十位
			sta	V_BcdDatL				;够减，则保存减去10以后的结果
			inx						;记录十位的个数
			bne	NameBcd_2

NameBcd_3:

			stx	V_BcdDatM				;保存转换出来的十位
			lda	V_BcdDatL				;没减完的数字就是个位
			ora	#$10
			sta	V_BcdDatL

			ret
;===============================================================================
;根据游戏编号，获得游戏名称的字符串地址
;-------------------------------------------------------------------------------
;输入：		V_Names_H	=	游戏编号高位
;		V_Names_L	=	游戏编号低位
;输出		V_Data_Adr	=	游戏字符串地址
;破坏：		A，Y，V_PROM_Adr
;-------------------------------------------------------------------------------
F_GetNameAdr:

			lda	#<A_NameTbl				;设置游戏名称列表地址
			sta	V_PROM_Adr

			lda	V_Names_L
			asl	A
			tay

			lda	V_Names_H
			rol	A
			adc	#>A_NameTbl
			sta	V_PROM_Adr+1

			lda	(V_PROM_Adr),y				;获取游戏名称字符串地址
			sta	V_Data_Adr
			iny
			lda	(V_PROM_Adr),y
			sta	V_Data_Adr+1

			ret
;===============================================================================
;把游戏编号加一，并检查编号是否达到设定的最大值。
;-------------------------------------------------------------------------------
;输入：		V_Names_H	=	游戏编号高位
;		V_Names_L	=	游戏编号低位
;输出		进位标致 C	=	是否达到最大值
;破坏：		A
;-------------------------------------------------------------------------------
F_IncNameAdr:

			inc	V_Names_L
			bne	F_TestName
			inc	V_Names_H

F_TestName:

			sec
			lda	V_Names_L
			sbc	#<C_MaxGame
			lda	V_Names_H
			sbc	#>C_MaxGame

			ret
;===============================================================================
;显示一行字符串，定义的字符串后面加 00 表示结束
;-------------------------------------------------------------------------------
;输入：		V_Data_Adr	=	字符串数据地址
;		$2006		=	调用前设好图像缓存地址
;破坏：		A，X，Y，以及用到的其它内存单元
;-------------------------------------------------------------------------------
F_DispString:

			ldy	#$00

String_Loop:

			lda	(V_Data_Adr),y
			beq	String_Exit
			sec
			sbc	#$20
			sta	$2007
			iny
			bne	String_Loop

String_Exit:

			ret
;===============================================================================
;移动云朵
;-------------------------------------------------------------------------------
F_MoveCloud:

			ldx	#$04

MoveCloud_0:

			dec	$0203,x					;减小精灵块的横坐标
			inx
			inx
			inx
			inx
			cpx	#$1C
			bcc	MoveCloud_0

			ret
;===============================================================================
;读取主手柄按键值，并把按键值存放在变量V_KeyCode中
;-------------------------------------------------------------------------------
;按键值定义如下：
;		00	没有按键按下
;		01	右
;		02	左
;		04	下
;		08	上
;		10	开始
;		20	选择
;		40	B
;		80	A
;-------------------------------------------------------------------------------
F_ReadKey:

                	ldx     #$01
                	stx     $4016
                	dex
                	stx     $4016

ReadKey_0:

                	lda     $4016
                	lsr     a
                	rol     V_KeyCode
                	inx
                	cpx     #$08
                	bcc     ReadKey_0

                	ret
;===============================================================================
;改变光标的颜色，光标交错使用第 0,1 号调色板
;精灵的第二个数据是属性值，其中D0,D1是指定使用哪块调色板
;-------------------------------------------------------------------------------
F_AlterColor:

			lda	$0202
			eor	#$01
			sta	$0202

			ret
;===============================================================================
;按上下键时的音效
;-------------------------------------------------------------------------------
F_KeySound:

                	lda     #$0F
                	sta     $4015
                	lda     #$1F
                	sta     $4000
                	sta     $4004
                	lda     #$99
                	sta     $4001
                	sta     $4005
                	lda     #$EF
                	sta     $4002
                	sta     $4006
                	lda     #$08
                	sta     $4003
                	sta     $4007
                	
                	ret
;===============================================================================
;进入游戏或者屏幕翻页时的音效
;-------------------------------------------------------------------------------
F_GameSound:

                	lda     #$0F
                	sta     $4015
                	lda     #$1F
                	sta     $4000
                	sta     $4004
                	lda     #$AA
                	sta     $4001
                	sta     $4005
                	lda     #$EF
                	sta     $4002
                	sta     $4006
                	lda     #$08
                	sta     $4003
                	sta     $4007

                	ret
;===============================================================================
;检查光标是否处在最后一屏的空白区，如果是，则把光标指向最后一个游戏
;-------------------------------------------------------------------------------
F_TestCursor:

			lda	V_Cursor				;检查光标是否超出范围
			cmp	#(C_MaxGame-C_MaxGame/20*20)
			bcc	Exit_Cursor				;如果光标没有超出范围，则退出

			lda	#(C_MaxGame-C_MaxGame/20*20)		;光标超出了范围，则指向最后一个游戏
			sta	V_Cursor
			dec	V_Cursor

F_SetCursor:

			lda	V_Cursor
			asl	A
			asl	A
			asl	A
			adc	#$28
			sta	$0200

Exit_Cursor:

			ret
;===============================================================================
;关闭中断，显示，声音，以便显示其他画面
;-------------------------------------------------------------------------------
F_ClearAll:

			ldx	#$00
			stx	$2000					;关闭中断
			stx	$2001					;关闭显示
			stx	$4015					;关闭声音
			stx	$E000					;关闭中断

			lda	#$3F
			sta	$2006
			stx	$2006

Clear_Color:

			sta	$2007
			inx
			cpx	#$20
			bcc	Clear_Color

			ret
;===============================================================================
;不可屏蔽中断服务程序，会在扫描间隙产生中断，用于设置扫描间隙标志，传送精灵数据，
;并把复制在缓存中的调色板传送给图像处理器，产生变色效果时，不需要直接操作图像处
;理器，只需改变缓存中的调色数据即可。
;-------------------------------------------------------------------------------
NMI_Program:

                	pha

                	lda     #$00
                	sta     $2003
                	lda     #$02
                	sta     $4014

                	sta     V_SysFlge
			pla

                	rti
;===============================================================================
;IRQ中断服务程序，只在移动屏幕时产生中断，用于在指定的显示行切换窗口坐标。
;-------------------------------------------------------------------------------
IRQ_Program:

                	rti
;===============================================================================
A_Menudot:
		INCLUDE		Reset_P.dfb
;-------------------------------------------------------------------------------
A_Menucod:
		INCLUDE		Reset_C.dfb
;-------------------------------------------------------------------------------
A_Menucol:
    DB   $22,$2B,$26,$0F,$22,$30,$30,$0F,$22,$20,$0A,$1A,$22,$27,$17,$0F
    DB   $22,$28,$26,$2A,$22,$26,$28,$2A,$23,$10,$10,$20,$22,$28,$14,$26
;-------------------------------------------------------------------------------
A_Tital:
                DB      'HUAWEI 129 IN 1',$00
;===============================================================================
;精灵定义：每个精灵块占4个字节，意义分别是：
;	字节0	=	精灵块的纵座标
;	字节1	=	精灵块的点阵号码
;	字节2	=	精灵块的属性
;	字节3	=	精灵块的横座标
;精灵块的属性描述如下：
;	D0,D1	=	精灵块使用的调色板号
;	D2-D4	=	没用到
;	D5	=	优先级，等于0时精灵在背景前面，等于1时，精灵在背景后面
;	D6	=	左右翻转，等于0时点阵不翻转，等于1时，点阵左右翻转
;	D7	=	上下颠倒，等于0时点阵不颠倒，等于1时，点阵上下颠倒
;-------------------------------------------------------------------------------
Sprite_Dat:
                db      $28,$1A,$00,$14					;光标
 
                db      $18,$01,$22,$D0					;云朵
                db      $18,$02,$22,$D8
                db      $18,$03,$22,$E0
                db      $18,$04,$22,$E8
                db      $18,$05,$22,$F0
                db      $18,$06,$22,$F8
;===============================================================================
Sram_Prg:


			lda	#$20					;允许写4801-4803
			sta	Rgst0

			lda	D_Sram+5				;读取图像长度
			beq	Setup_PRom

			ldx	#$00
			lda	D_Sram+3				;图像数据地址高位
			sta	Rgst2

Setup_VSRam:

			lda	#$80
			sta	V_Data_Adr+1
			ldy	#$00
			sty	V_Data_Adr

			sty	$2006
			sty	$2006

			txa
			clc
			adc	D_Sram+2				;图像数据地址低位
			sta	Rgst1
			stx	Rgst3

Setup_VLoop:

			lda	(V_Data_Adr),y				;读取程序地址
			sta	$2007
			iny
			bne	Setup_VLoop
			inc	V_Data_Adr+1
			lda	V_Data_Adr+1
			cmp	#$A0
			bcc	Setup_VLoop

			inx
			cpx	D_Sram+5
			bcc	Setup_VSRam

Setup_PRom:

			ldx	#$00
			txa

Setup_PRom0:

			sta	$4000,x
			inx
			cpx	#$08
			bcc	Setup_PRom0

			sta	$4015
			sta	Rgst3
			lda	D_Sram					;程序地址低位
			sta	Rgst1
			lda	D_Sram+1				;程序地址高位
			sta	Rgst2
			lda	D_Sram+4				;程序设置数据
			sta	Rgst0

			jmp	($FFFC)
;===============================================================================
A_NameTbl:
                DW      Name_001
                DW      Name_002
                DW      Name_003
                DW      Name_004
                DW      Name_005
                DW      Name_006
                DW      Name_007
                DW      Name_008
                DW      Name_009
                DW      Name_010
                DW      Name_011
                DW      Name_012
                DW      Name_013
                DW      Name_014
                DW      Name_015
                DW      Name_016
                DW      Name_017
                DW      Name_018
                DW      Name_019
                DW      Name_020
                DW      Name_021
                DW      Name_022
                DW      Name_023
                DW      Name_024
                DW      Name_025
                DW      Name_026
                DW      Name_027
                DW      Name_028
                DW      Name_029
                DW      Name_030
                DW      Name_031
                DW      Name_032
                DW      Name_033
                DW      Name_034
                DW      Name_035
                DW      Name_036
                DW      Name_037
                DW      Name_038
                DW      Name_039
                DW      Name_040
                DW      Name_041
                DW      Name_042
                DW      Name_043
                DW      Name_044
                DW      Name_045
                DW      Name_046
                DW      Name_047
                DW      Name_048
                DW      Name_049
                DW      Name_050
                DW      Name_051
                DW      Name_052
                DW      Name_053
                DW      Name_054
                DW      Name_055
                DW      Name_056
                DW      Name_057
                DW      Name_058
                DW      Name_059
                DW      Name_060
                DW      Name_061
                DW      Name_062
                DW      Name_063
                DW      Name_064
                DW      Name_065
                DW      Name_066
                DW      Name_067
                DW      Name_068
                DW      Name_069
                DW      Name_070
                DW      Name_071
                DW      Name_072
                DW      Name_073
                DW      Name_074
                DW      Name_075
                DW      Name_076
                DW      Name_077
                DW      Name_078
                DW      Name_079
                DW      Name_080
                DW      Name_081
                DW      Name_082
                DW      Name_083
                DW      Name_084
                DW      Name_085
                DW      Name_086
                DW      Name_087
                DW      Name_088
                DW      Name_089
                DW      Name_090
                DW      Name_091
                DW      Name_092
                DW      Name_093
                DW      Name_094
                DW      Name_095
                DW      Name_096
                DW      Name_097
                DW      Name_098
                DW      Name_099
                DW      Name_100
                DW      Name_101
                DW      Name_102
                DW      Name_103
                DW      Name_104
                DW      Name_105
                DW      Name_106
                DW      Name_107
                DW      Name_108
                DW      Name_109
                DW      Name_110
                DW      Name_111
                DW      Name_112
                DW      Name_113
                DW      Name_114
                DW      Name_115
                DW      Name_116
                DW      Name_117
                DW      Name_118
                DW      Name_119
                DW      Name_120
                DW      Name_121
                DW      Name_122
                DW      Name_123
                DW      Name_124
                DW      Name_125
                DW      Name_126
                DW      Name_127
                DW      Name_128
                DW      Name_129
;-------------------------------------------------------------------------------
Name_001:
        DB      'CONTRA JPN 30P',$00
Name_002:
        DB      'SUPER CONTRA 30P',$00
Name_003:
        DB      'CONTRA FORCE',$00
Name_004:
        DB      'LIFE FORCE',$00
Name_005:
        DB      'JACKAL',$00
Name_006:
        DB      'RUSH N ATTACK',$00
Name_007:
        DB      'GUN SMOKE',$00
Name_008:
        DB      '1944',$00
Name_009:
        DB      'WORLD CUP SOCCER',$00
Name_010:
        DB      'SIDE POCKET',$00
Name_011:
        DB      'SILK WORM',$00
Name_012:
        DB      'DOUBLE DRAGON 1',$00
Name_013:
        DB      'DOUBLE DRAGON 2',$00
Name_014:
        DB      'DOUBLE DRAGON 3',$00
Name_015:
        DB      'DOUBLE DRAGON 4',$00
Name_016:
        DB      'NINJA GAIDEN 1',$00
Name_017:
        DB      'NINJA GAIDEN 2',$00
Name_018:
        DB      'NINJA GAIDEN 3',$00
Name_019:
        DB      'ADVENTURE ISLAND 1',$00
Name_020:
        DB      'ADVENTURE ISLAND 2',$00
Name_021:
        DB      'ADVENTURE ISLAND 3',$00
Name_022:
        DB      'ADVENTURE ISLAND 4',$00
Name_023:
        DB      'NINJA TURTLES 1',$00
Name_024:
        DB      'NINJA TURTLES 2',$00
Name_025:
        DB      'NINJA TURTLES 3',$00
Name_026:
        DB      'NINJA TURTLES 4',$00
Name_027:
        DB      'BATMAN 1',$00
Name_028:
        DB      'BATMAN 2',$00
Name_029:
        DB      'BATMAN 3',$00
Name_030:
        DB      'ROCKMAN 1',$00
Name_031:
        DB      'ROCKMAN 2',$00
Name_032:
        DB      'ROCKMAN 3',$00
Name_033:
        DB      'ROCKMAN 4',$00
Name_034:
        DB      'ROCKMAN 5',$00
Name_035:
        DB      'ROCKMAN 6',$00
Name_036:
        DB      'HOT STREET BASKET',$00
Name_037:
        DB      'HOT SHIN KIROKU',$00
Name_038:
        DB      'HOT KOUKOU DODGEBALL',$00
Name_039:
        DB      'HOT KAKUTOU DENSETSU',$00
Name_040:
        DB      'HOT MONOGATARI',$00
Name_041:
        DB      'HOT SOCCER HEN',$00
Name_042:
        DB      'HOT SOCCER LEAGUE',$00
Name_043:
        DB      'HOT KOUSHINKYOKU',$00
Name_044:
        DB      'HOT HOCKEY',$00
Name_045:
        DB      'HOT KOUHA KUNIO',$00
Name_046:
        DB      'SUPER MARIO',$00
Name_047:
        DB      'MARIO BROS 2',$00
Name_048:
        DB      'MARIO BROS 3',$00
Name_049:
        DB      'DR MARIO',$00
Name_050:
        DB      'WAI WAI WORLD',$00
Name_051:
        DB      'CASTLEVANIA 1',$00
Name_052:
        DB      'CASTLEVANIA 2',$00
Name_053:
        DB      'P O W',$00
Name_054:
        DB      'CROSS FIRE',$00
Name_055:
        DB      'MITSUME GA TOORU',$00
Name_056:
        DB      'CHIP N DALE 1',$00
Name_057:
        DB      'CHIP N DALE 2',$00
Name_058:
        DB      'JACKIE CHAN',$00
Name_059:
        DB      'SNOW BROS',$00
Name_060:
        DB      'SAIYUUKI WORLD 1',$00
Name_061:
        DB      'CAT NINDEN TEYANDEE',$00
Name_062:
        DB      'MIGHTY FINAL FIGHT',$00
Name_063:
        DB      'CAPTAIN AMERICA',$00
Name_064:
        DB      'FIRE BIRD',$00
Name_065:
        DB      'CAPTAIN TSUBASA 2',$00
Name_066:
        DB      'BAYOU BILLY',$00
Name_067:
        DB      'KAGE',$00
Name_068:
        DB      'KICK MASTER',$00
Name_069:
        DB      'IKARI 1',$00
Name_070:
        DB      'IKARI 2',$00
Name_071:
        DB      'IKARI 3',$00
Name_072:
        DB      'FINAL MISSION',$00
Name_073:
        DB      'GUERRILLA WAR',$00
Name_074:
        DB      'GUN DEC',$00
Name_075:
        DB      'ROBOCOP 1',$00
Name_076:
        DB      'ROBOCOP 2',$00
Name_077:
        DB      'ROBOCOP 3',$00
Name_078:
        DB      'ROBOCOP 4',$00
Name_079:
        DB      'CODE NAME VIPER',$00
Name_080:
        DB      'DARKWING DUCK',$00
Name_081:
        DB      'DRAGON FIGHTER',$00
Name_082:
        DB      'ARGOS NO SENSHI',$00
Name_083:
        DB      'G I JOE 1',$00
Name_084:
        DB      'G I JOE 2',$00
Name_085:
        DB      'SWORD MASTER',$00
Name_086:
        DB      'TINY TOON 1',$00
Name_087:
        DB      'TINY TOON 2',$00
Name_088:
        DB      'TINY TOON 3',$00
Name_089:
        DB      'TINY TOON 4',$00
Name_090:
        DB      'TINY TOON 5',$00
Name_091:
        DB      'TOKKYUU SHIREI',$00
Name_092:
        DB      'PAJAMA HERO',$00
Name_093:
        DB      'PARODIUS',$00
Name_094:
        DB      'POWER BLADE 1',$00
Name_095:
        DB      'POWER BLADE 2',$00
Name_096:
        DB      'ASTYANAX',$00
Name_097:
        DB      'BATTLE KID 1',$00
Name_098:
        DB      'BATTLE KID 2',$00
Name_099:
        DB      'FELIX THE CAT',$00
Name_100:
        DB      'HEAVY BARREL',$00
Name_101:
        DB      'BUCKY O HARE',$00
Name_102:
        DB      'MONSTER',$00
Name_103:
        DB      'NINJA CRUSADERS',$00
Name_104:
        DB      'ULTRAMAN CLUB',$00
Name_105:
        DB      'SEIREI DENSETSU LICKLE',$00
Name_106:
        DB      'ROCK BOARD',$00
Name_107:
        DB      'TOP SECRET',$00
Name_108:
        DB      'THE SUPER SHINOBI',$00
Name_109:
        DB      'BAD DUDES',$00
Name_110:
        DB      'GOLD MEDAL',$00
Name_111:
        DB      'LEGENDARY WINGS',$00
Name_112:
        DB      'GREMLINS 2',$00
Name_113:
        DB      'JURASSIC PARK',$00
Name_114:
        DB      'MATENDOUJI',$00
Name_115:
        DB      'THUNDERCADE',$00
Name_116:
        DB      'METAL STORM',$00
Name_117:
        DB      'NINJA BROTHERS',$00
Name_118:
        DB      'OVER HORIZON',$00
Name_119:
        DB      'ZANAC',$00
Name_120:
        DB      'FLINTSTONES 1',$00
Name_121:
        DB      'FLINTSTONES 2',$00
Name_122:
        DB      'TERMINATOR 1',$00
Name_123:
        DB      'TERMINATOR 2',$00
Name_124:
        DB      'SILVER SURFER',$00
Name_125:
        DB      'TRACK AND FIELD',$00
Name_126:
        DB      'SPARTAN X',$00
Name_127:
        DB      'LEGEND OF KAGE',$00
Name_128:
        DB      'TANK A 1990',$00
Name_129:
        DB      'HINO TORI',$00
;===============================================================================
A_GameTbl:
			dw	Game_001
			dw	Game_002
			dw	Game_003
			dw	Game_004
			dw	Game_005
			dw	Game_006
			dw	Game_007
			dw	Game_008
			dw	Game_009
			dw	Game_010
			dw	Game_011
			dw	Game_012
			dw	Game_013
			dw	Game_014
			dw	Game_015
			dw	Game_016
			dw	Game_017
			dw	Game_018
			dw	Game_019

			dw	Game_020
			dw	Game_021
			dw	Game_022
			dw	Game_023
			dw	Game_024
			dw	Game_025
			dw	Game_026
			dw	Game_027
			dw	Game_028
			dw	Game_029

			dw	Game_030
			dw	Game_031
			dw	Game_032
			dw	Game_033
			dw	Game_034
			dw	Game_035
			dw	Game_036
			dw	Game_037
			dw	Game_038
			dw	Game_039

			dw	Game_040
			dw	Game_041
			dw	Game_042
			dw	Game_043
			dw	Game_044
			dw	Game_045
			dw	Game_046
			dw	Game_047
			dw	Game_048
			dw	Game_049

			dw	Game_050
			dw	Game_051
			dw	Game_052
			dw	Game_053
			dw	Game_054
			dw	Game_055
			dw	Game_056
			dw	Game_057
			dw	Game_058
			dw	Game_059

			dw	Game_060
			dw	Game_061
			dw	Game_062
			dw	Game_063
			dw	Game_064
			dw	Game_065
			dw	Game_066
			dw	Game_067
			dw	Game_068
			dw	Game_069

			dw	Game_070
			dw	Game_071
			dw	Game_072
			dw	Game_073
			dw	Game_074
			dw	Game_075
			dw	Game_076
			dw	Game_077
			dw	Game_078
			dw	Game_079

			dw	Game_080
			dw	Game_081
			dw	Game_082
			dw	Game_083
			dw	Game_084
			dw	Game_085
			dw	Game_086
			dw	Game_087
			dw	Game_088
			dw	Game_089

			dw	Game_090
			dw	Game_091
			dw	Game_092
			dw	Game_093
			dw	Game_094
			dw	Game_095
			dw	Game_096
			dw	Game_097
			dw	Game_098
			dw	Game_099

			dw	Game_100
			dw	Game_101
			dw	Game_102
			dw	Game_103
			dw	Game_104
			dw	Game_105
			dw	Game_106
			dw	Game_107
			dw	Game_108
			dw	Game_109

			dw	Game_110
			dw	Game_111
			dw	Game_112
			dw	Game_113
			dw	Game_114
			dw	Game_115
			dw	Game_116
			dw	Game_117
			dw	Game_118
			dw	Game_119

			dw	Game_120
			dw	Game_121
			dw	Game_122
			dw	Game_123
			dw	Game_124
			dw	Game_125
			dw	Game_126
			dw	Game_127
			dw	Game_128
			dw	Game_129
;===============================================================================
;魂斗罗1代	日文版：预置$07FF，D6-D4选关，D3允许30条命，D2-D0选武器
;-------------------------------------------------------------------------------
Game_001:
		SetupGame	$0040000,P08,$0060000,15,0,1
			dw	Game001_Set
;===============================================================================
;魂斗罗2代	日文版：预置$07FD-$07FF，$07FD-人数，$07FE-武器，$07FF-关数
;-------------------------------------------------------------------------------
Game_002:
		SetupGame	$0000000,P08,$0020000,15,0,1
			dw	Game002_Set
;===============================================================================
;魂斗罗力量	英文版		不预置
;-------------------------------------------------------------------------------
Game_003:
		SetupGame	$0080000,P08,$00A0000,16,0,0
;===============================================================================
;沙罗曼蛇	英文版		不预置
;-------------------------------------------------------------------------------
Game_004:
		SetupGame	$00C0000,P08,$0000000,00,0,0
;===============================================================================
;赤色要塞	英文版		不预置
;-------------------------------------------------------------------------------
Game_005:
		SetupGame	$00E0000,P08,$0000000,00,0,0
;===============================================================================
;绿色兵团	英文版		不预置
;-------------------------------------------------------------------------------
Game_006:
		SetupGame	$0100000,P08,$0000000,00,0,0
;===============================================================================
;荒野大镖客	英文版		不预置
;-------------------------------------------------------------------------------
Game_007:
		SetupGame	$0120000,P08,$0000000,00,0,0
;===============================================================================
;1944		日文版		不预置
;-------------------------------------------------------------------------------
Game_008:
		SetupGame	$0140000,P08,$0000000,00,0,0
;===============================================================================
;世界杯足球	英文版		不预置
;-------------------------------------------------------------------------------
Game_009:
		SetupGame	$0800000,P04,$0810000,08,0,0
;===============================================================================
;花式台球	英文版		不预置
;-------------------------------------------------------------------------------
Game_010:
		SetupGame	$0160000,P08,$0000000,00,1,0
;===============================================================================
;海湾战争	英文版		不预置
;-------------------------------------------------------------------------------
Game_011:
		SetupGame	$0180000,P08,$01A0000,16,0,0
;===============================================================================
;双截龙一代	英文版		不预置
;-------------------------------------------------------------------------------
Game_012:
		SetupGame	$01C0000,P08,$01E0000,16,0,0
;===============================================================================
;双截龙二代	英文版		不预置
;-------------------------------------------------------------------------------
Game_013:
		SetupGame	$0200000,P08,$0220000,16,0,0
;===============================================================================
;双截龙三代	英文版		不预置
;-------------------------------------------------------------------------------
Game_014:
		SetupGame	$0240000,P08,$0260000,16,0,0
;===============================================================================
;双截龙四代	英文版		预置 $0100 大于 #$40 ，显示片头
;-------------------------------------------------------------------------------
Game_015:
		SetupGame	$0280000,P08,$02A0000,16,0,1
			dw	Game015_Set
;===============================================================================
;忍者龙剑传1	英文版		不预置
;-------------------------------------------------------------------------------
Game_016:
		SetupGame	$02C0000,P08,$02E0000,16,0,0
;===============================================================================
;忍者龙剑传2	英文版		不预置
;-------------------------------------------------------------------------------
Game_017:
		SetupGame	$0300000,P08,$0320000,16,0,0
;===============================================================================
;忍者龙剑传3	英文版		不预置
;-------------------------------------------------------------------------------
Game_018:
		SetupGame	$0340000,P08,$0360000,16,0,0
;===============================================================================
;冒险岛1	英文版		预置 $0100 人数
;-------------------------------------------------------------------------------
Game_019:
		SetupGame	$1E80000,P02,$1E88000,04,0,0
			dw	Game019_Set
;===============================================================================
;冒险岛2	英文版		不预置
;-------------------------------------------------------------------------------
Game_020:
		SetupGame	$0380000,P08,$03A0000,16,0,0
;===============================================================================
;冒险岛3	英文版		不预置
;-------------------------------------------------------------------------------
Game_021:
		SetupGame	$03C0000,P08,$03E0000,16,0,0
;===============================================================================
;冒险岛4	英文版		不预置
;-------------------------------------------------------------------------------
Game_022:
		SetupGame	$0400000,P16,$0440000,16,0,0
;===============================================================================
;忍者龟1	英文版		不预置
;-------------------------------------------------------------------------------
Game_023:
		SetupGame	$11C0000,P08,$11E0000,16,0,0
;===============================================================================
;忍者龟2	英文版		不预置
;-------------------------------------------------------------------------------
Game_024:
		SetupGame	$0500000,P16,$0540000,32,0,0
;===============================================================================
;忍者龟3	英文版		不预置
;-------------------------------------------------------------------------------
Game_025:
		SetupGame	$0580000,P16,$05C0000,32,0,0
;===============================================================================
;忍者龟4	英文版		不预置
;-------------------------------------------------------------------------------
Game_026:
		SetupGame	$04C0000,P08,$04E0000,16,0,0
;===============================================================================
;蝙蝠侠1	英文版		不预置
;-------------------------------------------------------------------------------
Game_027:
		SetupGame	$0FC0000,P08,$0FE0000,16,0,0
;===============================================================================
;蝙蝠侠2	英文版		不预置
;-------------------------------------------------------------------------------
Game_028:
		SetupGame	$0460000,P08,$0480000,32,0,0
;===============================================================================
;蝙蝠侠3	英文版		不预置
;-------------------------------------------------------------------------------
Game_029:
		SetupGame	$0B60000,P08,$0B80000,32,0,0
;===============================================================================
;洛克人1	英文版		不预置
;-------------------------------------------------------------------------------
Game_030:
		SetupGame	$0660000,P08,$0000000,00,0,0
;===============================================================================
;洛克人2	英文版		不预置
;-------------------------------------------------------------------------------
Game_031:
		SetupGame	$0840000,P16,$0000000,00,0,0
;===============================================================================
;洛克人3	英文版		不预置
;-------------------------------------------------------------------------------
Game_032:
		SetupGame	$0600000,P16,$0640000,16,0,0
;===============================================================================
;洛克人4	英文版		不预置
;-------------------------------------------------------------------------------
Game_033:
		SetupGame	$0680000,P32,$0000000,00,0,0
;===============================================================================
;洛克人5	英文版		不预置
;-------------------------------------------------------------------------------
Game_034:
		SetupGame	$0700000,P16,$0740000,32,0,0
;===============================================================================
;洛克人6	英文版		不预置
;-------------------------------------------------------------------------------
Game_035:
		SetupGame	$0780000,P32,$0000000,00,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_036:
		SetupGame	$0880000,P08,$08A0000,16,0,0
;===============================================================================
;热血新记录	英文版		不预置
;-------------------------------------------------------------------------------
Game_037:
		SetupGame	$08C0000,P08,$08E0000,16,0,0
;===============================================================================
;热血躲避球	英文版		不预置
;-------------------------------------------------------------------------------
Game_038:
		SetupGame	$0900000,P08,$0920000,16,0,0
;===============================================================================
;热血格斗	英文版		不预置
;-------------------------------------------------------------------------------
Game_039:
		SetupGame	$0940000,P08,$0960000,16,0,0
;===============================================================================
;热血物语	英文版		不预置
;-------------------------------------------------------------------------------
Game_040:
		SetupGame	$0980000,P08,$09A0000,16,0,0
;===============================================================================
;热血足球	英文版		不预置
;-------------------------------------------------------------------------------
Game_041:
		SetupGame	$09C0000,P08,$09E0000,16,0,0
;===============================================================================
;热血足球联盟	英文版		不预置
;-------------------------------------------------------------------------------
Game_042:
		SetupGame	$0A00000,P08,$0A20000,16,0,0
;===============================================================================
;热血进行曲	英文版		不预置
;-------------------------------------------------------------------------------
Game_043:
		SetupGame	$0A40000,P08,$0A60000,16,0,0
;===============================================================================
;热血冰球	英文版		不预置
;-------------------------------------------------------------------------------
Game_044:
		SetupGame	$0A80000,P08,$0AA0000,32,0,0
;===============================================================================
;热血硬派	英文版		不预置
;-------------------------------------------------------------------------------
Game_045:
		SetupGame	$0820000,P08,$0000000,00,0,0
;===============================================================================
;马里奥1	英文版		预置 $0100 人数， $0101 关数
;-------------------------------------------------------------------------------
Game_046:
		SetupGame	$1F90000,P02,$1E9E000,01,0,1
			dw	Game046_Set
;===============================================================================
;马里奥2	英文版		不预置
;-------------------------------------------------------------------------------
Game_047:
		SetupGame	$0AC0000,P08,$0AE0000,16,0,0
;===============================================================================
;马里奥3	英文版		不预置
;-------------------------------------------------------------------------------
Game_048:
		SetupGame	$0B00000,P16,$0B40000,16,0,0
;===============================================================================
;马里奥医生	英文版		不预置
;-------------------------------------------------------------------------------
Game_049:
		SetupGame	$1E90000,P02,$1E98000,03,0,0
;===============================================================================
;柯那米世界	英文版		不预置
;-------------------------------------------------------------------------------
Game_050:
		SetupGame	$19C0000,P08,$19E0000,16,0,0
;===============================================================================
;恶魔城1	英文版		不预置
;-------------------------------------------------------------------------------
Game_051:
		SetupGame	$1440000,P08,$0000000,00,0,0
;===============================================================================
;恶魔城2	英文版		不预置
;-------------------------------------------------------------------------------
Game_052:
		SetupGame	$0BC0000,P08,$0BE0000,10,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_053:
		SetupGame	$0C00000,P08,$0C20000,16,0,0
;===============================================================================
;穿越火线	英文版		不预置
;-------------------------------------------------------------------------------
Game_054:
		SetupGame	$0C40000,P08,$0C60000,16,0,0
;===============================================================================
;三目童子	英文版		不预置
;-------------------------------------------------------------------------------
Game_055:
		SetupGame	$0C80000,P08,$0CA0000,16,0,0
;===============================================================================
;松鼠大战1	英文版		不预置
;-------------------------------------------------------------------------------
Game_056:
		SetupGame	$0CC0000,P08,$0CE0000,16,0,0
;===============================================================================
;松鼠大战2	英文版		不预置
;-------------------------------------------------------------------------------
Game_057:
		SetupGame	$0D00000,P08,$0D20000,16,0,0
;===============================================================================
;成龙2 		英文版		不预置
;-------------------------------------------------------------------------------
Game_058:
		SetupGame	$0D40000,P08,$0D60000,16,0,0
;===============================================================================
;雪人兄弟	英文版		不预置
;-------------------------------------------------------------------------------
Game_059:
		SetupGame	$0D80000,P08,$0DA0000,16,0,0
;===============================================================================
;西游记1	英文版		不预置
;-------------------------------------------------------------------------------
Game_060:
		SetupGame	$0DC0000,P08,$0000000,00,0,0
;===============================================================================
;忍者猫		英文版		不预置
;-------------------------------------------------------------------------------
Game_061:
		SetupGame	$0E00000,P08,$0E20000,16,0,0
;===============================================================================
;旋风快打	英文版		不预置
;-------------------------------------------------------------------------------
Game_062:
		SetupGame	$0E40000,P08,$0E60000,16,0,0
;===============================================================================
;上将密令	英文版		不预置
;-------------------------------------------------------------------------------
Game_063:
		SetupGame	$0E80000,P08,$0EA0000,16,0,0
;===============================================================================
;太阳火鸟	英文版		不预置
;-------------------------------------------------------------------------------
Game_064:
		SetupGame	$0EC0000,P08,$0EE0000,16,0,0
;===============================================================================
;天使之翼2	英文版		不预置
;-------------------------------------------------------------------------------
Game_065:
		SetupGame	$0F00000,P16,$0F40000,16,0,0
;===============================================================================
;鳄鱼先生	英文版		不预置
;-------------------------------------------------------------------------------
Game_066:
		SetupGame	$0F80000,P08,$0FA0000,16,0,0
;===============================================================================
;赤影战士	英文版		不预置
;-------------------------------------------------------------------------------
Game_067:
		SetupGame	$1000000,P08,$1020000,16,0,0
;===============================================================================
;踢王		英文版		不预置
;-------------------------------------------------------------------------------
Game_068:
		SetupGame	$1040000,P08,$1060000,16,0,0
;===============================================================================
;怒1		英文版		不预置
;-------------------------------------------------------------------------------
Game_069:
		SetupGame	$1A60000,P08,$0000000,00,1,0
;===============================================================================
;怒2		英文版		不预置
;-------------------------------------------------------------------------------
Game_070:
		SetupGame	$1080000,P16,$0000000,00,0,0
;===============================================================================
;怒3		英文版		不预置
;-------------------------------------------------------------------------------
Game_071:
		SetupGame	$10C0000,P08,$10E0000,16,0,0
;===============================================================================
;终极任务	英文版		不预置
;-------------------------------------------------------------------------------
Game_072:
		SetupGame	$1100000,P08,$1120000,16,0,0
;===============================================================================
;古巴战争	英文版		不预置
;-------------------------------------------------------------------------------
Game_073:
		SetupGame	$1140000,P08,$1160000,16,0,0
;===============================================================================
;火炮		英文版		不预置
;-------------------------------------------------------------------------------
Game_074:
		SetupGame	$1180000,P08,$11A0000,16,0,0
;===============================================================================
;火炮		英文版		不预置
;-------------------------------------------------------------------------------
Game_075:
		SetupGame	$1200000,P08,$1220000,16,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_076:
		SetupGame	$1240000,P08,$1260000,16,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_077:
		SetupGame	$1280000,P08,$12A0000,16,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_078:
		SetupGame	$12C0000,P08,$12E0000,16,0,0
;===============================================================================
;人间兵器	英文版		不预置
;-------------------------------------------------------------------------------
Game_079:
		SetupGame	$1300000,P08,$1320000,16,0,0
;===============================================================================
;怪鸭历险记	英文版		不预置
;-------------------------------------------------------------------------------
Game_080:
		SetupGame	$1340000,P08,$1360000,16,0,0
;===============================================================================
;龙战士		英文版		不预置
;-------------------------------------------------------------------------------
Game_081:
		SetupGame	$1380000,P08,$13A0000,16,0,0
;===============================================================================
;阿戈斯战机	英文版		不预置
;-------------------------------------------------------------------------------
Game_082:
		SetupGame	$13C0000,P08,$0000000,00,0,0
;===============================================================================
;特敕指令1	英文版		不预置
;-------------------------------------------------------------------------------
Game_083:
		SetupGame	$13E0000,P08,$1400000,32,0,0
;===============================================================================
;特敕指令2	英文版		不预置
;-------------------------------------------------------------------------------
Game_084:
		SetupGame	$1460000,P08,$1480000,32,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_085:
		SetupGame	$14C0000,P08,$14E0000,16,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_086:
		SetupGame	$1500000,P08,$1520000,16,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_087:
		SetupGame	$1540000,P08,$1560000,16,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_088:
		SetupGame	$0DE0000,P04,$0DF0000,08,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_089:
		SetupGame	$1580000,P08,$15A0000,16,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_090:
		SetupGame	$15C0000,P08,$15E0000,16,0,0
;===============================================================================
;特敕指令	英文版		不预置
;-------------------------------------------------------------------------------
Game_091:
		SetupGame	$1600000,P08,$1620000,16,1,0
;===============================================================================
;特敕指令	英文版		不预置
;-------------------------------------------------------------------------------
Game_092:
		SetupGame	$1640000,P08,$1660000,16,0,0
;===============================================================================
;Q版沙罗曼蛇	英文版		不预置
;-------------------------------------------------------------------------------
Game_093:
		SetupGame	$1680000,P08,$16A0000,16,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_094:
		SetupGame	$16C0000,P08,$16E0000,16,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_095:
		SetupGame	$1700000,P08,$1720000,16,0,0
;===============================================================================
;战斧		英文版		不预置
;-------------------------------------------------------------------------------
Game_096:
		SetupGame	$1740000,P08,$1760000,16,0,0
;===============================================================================
;坦克1		英文版		不预置
;-------------------------------------------------------------------------------
Game_097:
		SetupGame	$1780000,P16,$0000000,00,0,0
;===============================================================================
;坦克2		英文版		不预置
;-------------------------------------------------------------------------------
Game_098:
		SetupGame	$1800000,P32,$0000000,00,0,0
;===============================================================================
;菲力猫		英文版		不预置
;-------------------------------------------------------------------------------
Game_099:
		SetupGame	$17C0000,P08,$17E0000,16,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_100:
		SetupGame	$1880000,P08,$18A0000,16,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_101:
		SetupGame	$18C0000,P08,$18E0000,16,1,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_102:
		SetupGame	$1900000,P08,$1920000,16,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_103:
		SetupGame	$1940000,P08,$0000000,00,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_104:
		SetupGame	$1960000,P08,$1980000,32,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_105:
		SetupGame	$1A00000,P16,$1A40000,16,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_106:
		SetupGame	$1A80000,P16,$0000000,00,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_107:
		SetupGame	$1AC0000,P16,$0000000,00,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_108:
		SetupGame	$1B00000,P16,$1B40000,32,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_109:
		SetupGame	$1B80000,P08,$1BA0000,16,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_110:
		SetupGame	$1BC0000,P08,$1BE0000,16,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_111:
		SetupGame	$1C00000,P08,$0000000,00,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_112:
		SetupGame	$1C20000,P08,$1C40000,32,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_113:
		SetupGame	$1C80000,P08,$1CA0000,16,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_114:
		SetupGame	$1CC0000,P08,$1CE0000,16,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_115:
		SetupGame	$1D00000,P08,$0000000,00,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_116:
		SetupGame	$1D20000,P08,$1D40000,32,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_117:
		SetupGame	$1D80000,P08,$1DA0000,16,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_118:
		SetupGame	$1DC0000,P08,$1DE0000,16,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_119:
		SetupGame	$1E00000,P08,$0000000,00,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_120:
		SetupGame	$1E20000,P08,$1E40000,32,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_121:
		SetupGame	$1EA0000,P08,$1EC0000,32,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_122:
		SetupGame	$1F00000,P08,$1F20000,16,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_123:
		SetupGame	$1F40000,P08,$1F60000,16,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_124:
		SetupGame	$1FA0000,P08,$1FC0000,32,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_125:
		SetupGame	$1F80000,P02,$1F88000,04,0,0
;===============================================================================
;热血篮球	英文版		不预置
;-------------------------------------------------------------------------------
Game_126:
		SetupGame	$1F98000,P02,$003E000,04,0,0
;===============================================================================
;影子传说	英文版		不预置
;-------------------------------------------------------------------------------
Game_127:
		SetupGame	$0BF8000,P02,$0BF4000,02,1,0
;===============================================================================
;坦克90A	英文版		不预置
;-------------------------------------------------------------------------------
Game_128:
		SetupGame	$02BC000,P01,$0C7E000,01,1,0
;===============================================================================
;火之鸟凤凰编	英文版		不预置
;-------------------------------------------------------------------------------
Game_129:
		SetupGame	$0F60000,P08,$0000000,00,0,0
;===============================================================================
Game001_Set:
			lda	#$08					;30条命，默认武器，第一关开始
			sta	$07FF
			jmp	P_Sram
;-------------------------------------------------------------------------------
Game002_Set:
			lda	#029					;30条命
			sta	$07FD
			jmp	P_Sram
;-------------------------------------------------------------------------------
Game015_Set:
			lda	#$FF					;显示片头
			sta	$0100
			jmp	P_Sram
;-------------------------------------------------------------------------------
Game019_Set:
			lda	#$05					;6 条命
			sta	$0100
			jmp	P_Sram
;-------------------------------------------------------------------------------
Game046_Set:
			lda	#$05					;6 条命
			sta	$0100
			jmp	P_Sram
;-------------------------------------------------------------------------------
;===============================================================================
                	ORG     $FFFA					;此处是复位向量地址
;-------------------------------------------------------------------------------
               		DW      NMI_Program
                	DW      Reset_Adr
                	DW      IRQ_Program
;===============================================================================
