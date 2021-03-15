;===============================================================================
                	SYNTAX        	6502
                	LINKLIST
                	SYMBOLS
			INCLUDE		System.inc
;===============================================================================
;������������Ϸ���Եĺ�ָ���������ָ����Ϸ�ĳ������ݺ�ͼ�������������е�λ�á�
;������������Ϸ��ڵ�ַ���Ƿ���ҪԤ�ȼ����ض����ݵ�
;���������	P_A		��Ϸ�����������е�λ��
;		P_S		��Ϸ���������
;		V_A		��Ϸͼ���������е�λ��
;		V_S		��Ϸͼ�������
;		H_V		��Ϸ�ľ���
;		G_P		��Ϸ��ҪԤ����
;-------------------------------------------------------------------------------
SetupGame       	macro   P_A,P_S,V_A,V_S,H_V,G_P
 
                	dw	P_A>>13					;00
                	dw	V_A>>13					;02
                	db	P_S					;04
                	db	V_S					;05
                	db	((G_P<<7) + H_V)			;06
                	endm
;===============================================================================
;�����Ƕ���ĳ����������Ժ��޸ĳ���
;-------------------------------------------------------------------------------
C_MaxGame		equ	128					;�ϼ��е���� 128 ����Ϸ
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
;����ѳ����ͼ��Ĵ����淶�����Ա���ӦС��������Ϸ
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
;��ʾ�������棬�ȴ��͵������ݵ�ͼ����������
;-------------------------------------------------------------------------------
Display_Logo:

			lda	#<A_Menudot				;���ݵ�ַ���ڵ������ݿ�ʼ
			sta	V_Data_Adr
			lda	#>A_Menudot
			sta	V_Data_Adr+1

			ldx	#$00					;ͼ��������ַ = 0000
			stx	$2006
			stx	$2006
			jsr	F_Decomp_PPU				;�������ݽ�ѹ�� 0000 ��ʼ�Ļ���

			ldx	#$20					;ͼ��������ַ = 2000
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
			bcc	Clear_Code0				;һֱ����� 2400

Clear_Code1:
			
			sta	$2007
			iny
			cpy	#$40
			bcc	Clear_Code1				;��������� 2340

			lda	#<A_Menucod				;���ݵ�ַ���ڴ������ݿ�ʼ
			sta	V_Data_Adr
			lda	#>A_Menucod
			sta	V_Data_Adr+1

			jsr	F_Decomp_PPU				;�������ݽ�ѹ�� 2340 ��ʼ�Ļ���

			lda	#$20					;ͼ��������ַ = 2048
			sta	$2006
			lda	#$48
			sta	$2006

			lda	#<A_Tital				;���ݵ�ַ���ڱ������ݿ�ʼ
			sta	V_Data_Adr
			lda	#>A_Tital
			sta	V_Data_Adr+1

			jsr	F_DispString				;��ʾһ���ַ�

			lda	#$3F					;ͼ��������ַ = 3F00
			ldy	#$00
			sta	$2006
			sty	$2006

Setup_Color:								;������ɫ����

			lda	A_Menucol,y
			sta	$2007
			iny
			cpy	#$20
			bcc	Setup_Color

			ldx	#$00

Setup_Sprite:								;���;��鶨������

			lda	Sprite_Dat,x
			sta	$0200,x
			inx
			cpx	#$1C					;������ 7 ����������
			bcc	Setup_Sprite

			lda	#$F8

Clear_Sprite:								;����ľ��鶨���ڴ棬�Ѿ��鶨�������

			sta	$0200,x
			inx
			bne	Clear_Sprite

			ldx	#$04

			lda	#$00					;��Ļ�������궨��00,00
			sta	V_SysFlge
			sta	V_Names_H
			sta	V_Names_L
			sta	V_Cursor

			jsr	F_DispName				��ʾһ����Ϸ����
;===============================================================================
Main_Program:

			lda	V_SysFlge
			beq	Main_Program
			lda	#$00
			sta	V_SysFlge

			inc	V_Counter

			lda	V_Counter				;ÿ4���жϣ��ƶ�һ���ƶ�
			and	#$03
			bne	Main_Program

			jsr	F_MoveCloud

			lda	V_Counter				;ÿ8���жϣ���ȡһ���ֱ�
			and	#$07
			bne	Main_Program

			jsr	F_ReadKey
			lda	V_KeyCode
			bne	Process_Key

			lda	V_Counter				;ÿ32���жϣ��ı�һ�ι����ɫ
			and	#$1F
			bne	Main_Program

			jsr	F_AlterColor
			jmp	Main_Program
;-------------------------------------------------------------------------------
;������а����������жϰ������ĸ�������ֵ�Ѿ�����A����
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

			dw	PressKeyR				;00����������
			dw	PressKeyL				;01����������
			dw	PressKeyD				;02����������
			dw	PressKeyU				;03����������
			dw	PressKeyS				;04�����ǿ�ʼ
			dw	Main_Program				;05������ѡ�񣬱�����û�õ�
			dw	PressKeyB				;06������ B
			dw	PressKeyA				;07������ A
;-------------------------------------------------------------------------------
;���洦���Ҽ������������һ������������˽�β�����»ص���ʼ����һ��
;-------------------------------------------------------------------------------
PressKeyR:
			jsr	F_GameSound				;������Ч
			jsr	F_TestName				;��鵱ǰ��Ϸ����Ƿ��ѵ���β
			bcc	NormalKeyR				;û�е���β������������

			lda	#$00					;���˽�β���򷭵���ʼ��
			sta	V_Names_H
			sta	V_Names_L

NormalKeyR:

			jsr	F_DispName				;��ʾһ����Ϸ����
			jsr	F_TestName				;��ʾ��ɺ��ٴ���Ϸ����Ƿ��ѵ���β
			bcc	Exit_Key_R				;û�е���β�����ü����

			jsr	F_TestCursor				;��鲢���ù���������

Exit_Key_R:

			jmp	Main_Program				;���������������ѭ��
;-------------------------------------------------------------------------------
;���洦���������������ǰ��һ������������˿�ʼ�����»ص�������һ��
;-------------------------------------------------------------------------------
PressKeyL:

			jsr	F_GameSound				;������Ч
			lda	V_Names_L				;��Ϸ�����ǰ��40
			sec
			sbc	#040
			sta	V_Names_L
			lda	V_Names_H
			sbc	#$00
			sta	V_Names_H
			bcs	NormalKeyL				;û�г�����ʼ��������������

			lda	#>(C_MaxGame/20*20)			;�����˷�Χ������ʾ���һ��
			sta	V_Names_H
			lda	#<(C_MaxGame/20*20)
			sta	V_Names_L

			jsr	F_TestCursor				;��ʾ���һ��ʱ����Ҫ������λ��

NormalKeyL:

			jsr	F_DispName				;��ʾһ����Ϸ����
			jmp	Main_Program				;���������������ѭ��
;-------------------------------------------------------------------------------
;���洦���¼��������ǹ��������һ�У�����������һ�У������һ�������ѹ����
;��������һ��
;-------------------------------------------------------------------------------
PressKeyD:

			jsr	F_KeySound				;������Ч
			inc	V_Cursor				;��������ƶ�һ��
			jsr	F_TestName				;��鵱ǰ��Ϸ����Ƿ��ѵ���β
			bcc	NormalKeyD				;û�е���β������ʾ����������

			lda	V_Cursor				;��ǰ��ʾ�������һ����������Ƿ��Ѿ��������һ��
			cmp	#(C_MaxGame-C_MaxGame/20*20)
			bcs	Next_KeyD				;�����곬�����һ�У��������

NormalKeyD:

			lda	V_Cursor				;��ǰ��ʾ������������������Ƿ��Ѿ��������һ��
			cmp	#020					;�����������һ����19
			bcs	Next_KeyD				;�����곬�����һ�У��������

			jsr	F_SetCursor				;���û�г������һ�У������ù���������
			jmp	Main_Program				;���������������ѭ��

Next_KeyD:

			lda	#00					;��Ҫ����ʱ���ѹ���Ƶ�������һ��
			sta	V_Cursor
			jsr	F_SetCursor
			jmp	PressKeyR				;���һ��
;-------------------------------------------------------------------------------
;���洦���ϼ��������ǹ��������һ�У������������һ�У�����ǰ��һ�������ѹ����
;��������һ��
;-------------------------------------------------------------------------------
PressKeyU:

			jsr	F_KeySound				;������Ч
			dec	V_Cursor				;��������ƶ�һ��
			bpl	NormalKeyU				;���ֵ���ڻ��ߵ��� 00 ����û�г���������һ��

			lda	#019					;��곬����������һ�У���ѹ���Ƶ�������
			sta	V_Cursor
			jsr	F_SetCursor				;���ù���������
			jmp	PressKeyL				;��ǰ��һ��

NormalKeyU:

			jsr	F_SetCursor				;���û�г���������һ�У������ù���������
			jmp	Main_Program				;���������������ѭ��
;-------------------------------------------------------------------------------
;���洦��A������������󷭶�������������˽�β�����»ص���ʼ����һ��
;-------------------------------------------------------------------------------
PressKeyA:

			lda	V_Names_L				;��Ϸ��������60
			clc
			adc	#020
			sta	V_Names_L
			lda	V_Names_H
			adc	#$00
			sta	V_Names_H
			jmp	PressKeyR				;�Ҽ����������ж��Ƿ񳬹���Χ
;-------------------------------------------------------------------------------
;���洦��B������������ǰ����������������˿�ʼ�����򷭵�����������
;-------------------------------------------------------------------------------
PressKeyB:

			jsr	F_TestName				;��鵱ǰ��Ϸ����Ƿ��ѵ���β
			bcc	NormalKeyB				;û�е���β������������

			lda	#>(C_MaxGame/20*20)			;���˽�β����Ϸ���������һ���Ŀ�ʼ
			sta	V_Names_H
			lda	#<(C_MaxGame/20*20)
			sta	V_Names_L
			jmp	PressKeyL				;��������ܷ���

NormalKeyB:



			lda	V_Names_L				;��Ϸ�����ǰ��20
			sec
			sbc	#020
			sta	V_Names_L
			lda	V_Names_H
			sbc	#$00
			sta	V_Names_H
			bcs	Exit_Key_B				;û�г�����ʼ��������������

			lda	#$00
			sta	V_Names_H
			sta	V_Names_L

Exit_Key_B:

;			jsr	F_DispName
			jmp	PressKeyL				;���������������ѭ��
;-------------------------------------------------------------------------------
;���洦��ʼ�����������жϹ����ָ�����ĸ���Ϸ��������Ϸ��������Ҫ�����ݣ���ת
;����Ϸ�������ڵ�ַ��ִ�ж�Ӧ����Ϸ����
;-------------------------------------------------------------------------------
PressKeyS:

			jsr	F_ClearAll
			jsr	F_GameSound				;������Ч

			lda	#<A_GameTbl				;������Ϸ�����б��ַ
			sta	V_PROM_Adr
			lda	#>A_GameTbl
			sta	V_PROM_Adr+1

			jsr	F_TestName				;��鵱ǰ��Ϸ����Ƿ��ѵ���β
			bcc	NormalKeyS				;û�е���β������������

			lda	#<(C_MaxGame/20*20)			;���˽�β��������ָ����Ϸ��������һ�������+���ֵ
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

			lda	(V_PROM_Adr),y				;��ȡ��Ϸ�����ַ�����ַ
			sta	V_Data_Adr
			iny
			lda	(V_PROM_Adr),y
			sta	V_Data_Adr+1

			ldy	#$00

StartKey_Loop:

			lda	(V_Data_Adr),y				;��ȡ��Ϸ�����ַ�����ַ
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
;�����Ǳ�����ʹ�õ��ڲ��ӳ���
;===============================================================================
;����cmpt.exeѹ���ĸ���ͼ�����ݣ���ѹ��ͼ�񻺴����С�
;-------------------------------------------------------------------------------
;���룺		V_Data_Adr	=	ѹ�����ݵ�ַ
;		$2006		=	����ǰ���ͼ�񻺴��ַ
;�ƻ���		A��X��Y���Լ��õ��������ڴ浥Ԫ
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
;��ʾһ����Ϸ���֣��������Ϸ�����ַ�������� 00 ��ʾ����
;-------------------------------------------------------------------------------
;���룺		V_Data_Adr	=	�ַ������ݵ�ַ
;		$2006		=	����ǰ���ͼ�񻺴��ַ
;�ƻ���		A��X��Y���Լ��õ��������ڴ浥Ԫ
;-------------------------------------------------------------------------------
F_DispName:

			lda	#$00
			sta	$2000
			sta	$2001

			lda	#$20					;�Ȱ���ʾ�����������������ǰ����ʾ
			sta	$2006					;����ͼ�񻺴��ַ = 2060
			sta	V_R2006_H				;���Ѹ�λ��ַ��������
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
			bcc	Dispname_0				;һֱ����� 22A0

Dispname_1:

			sta	$2007
			iny
			cpy	#$80
			bcc	Dispname_1				;��������� 2320

			lda	#$A5			
			sta	V_R2006_L				;������ʾ���ĵ͵�ַ

Dispname_2:

			jsr	F_NameBcd				;����Ϸ���ת����������ʾ�Ĵ���

			lda	V_R2006_H				;����ʾ��Ϸ���
			sta	$2006
			lda	V_R2006_L
			sta	$2006

			lda	V_BcdDatH				;��ʾ��λ
			sta	$2007
			lda	V_BcdDatM				;��ʾʮλ
			sta	$2007
			lda	V_BcdDatL				;��ʾ��λ
			sta	$2007
			lda	#$00					;��ʾһ���ո�
			sta	$2007

			jsr	F_GetNameAdr				;��ȡ�ַ�����ַ
			jsr	F_DispString				;��ʾһ���ַ���
			jsr	F_IncNameAdr				;��Ϸ��ż�һ�����ж��Ƿ񳬹����ֵ
			bcs	Dispname_3				;��������˷�Χ�����˳�

			lda	V_R2006_L
			adc	#$20
			sta	V_R2006_L
			lda	V_R2006_H
			adc	#$00
			sta	V_R2006_H
			cmp	#$23					;�����ʾ�Ƿ񳬹�Ԥ��������
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
;����Ϸ�����ֵ��ת������Ļ���룬����ʹ�õ���Ϸ��Ŵ� 00 ��ʼ����ʾ����Ϸ��Ŵ�
;001��ʼ������Ȱ���Ϸ��ż�01���ٽ���ת����
;-------------------------------------------------------------------------------
;���룺		V_Names_H	=	��Ϸ��Ÿ�λ
;		V_Names_L	=	��Ϸ��ŵ�λ
;���		V_BcdDatH	=	��Ļ����İ�λ
;		V_BcdDatM	=	��Ļ�����ʮλ
;		V_BcdDatL	=	��Ļ����ĸ�λ
;�ƻ���		A��X��Y
;-------------------------------------------------------------------------------
F_NameBcd:

			lda	V_Names_L
			clc
			adc	#$01
			sta	V_BcdDatL
			lda	V_Names_H
			adc	#$00
			sta	V_BcdDatM

			ldx	#$10					;Ԥ����Ļ����Ϊ"0"
			sec

NameBcd_0:

			lda	V_BcdDatL
			sbc	#<0100					;��10������100�ĵ�λ
			tay						;�ȱ�����������Ϊ��֪���Ƿ񹻼�
			lda	V_BcdDatM
			sbc	#>0100					;��10������100�ĸ�λ
			bcc	NameBcd_1				;�����������������û�а�λ
			sta	V_BcdDatM				;�������򱣴��ȥ100�Ժ�Ľ��
			sty	V_BcdDatL
			inx						;��¼��λ�ĸ���
			bne	NameBcd_0

NameBcd_1:

			stx	V_BcdDatH				;����ת�������İ�λ
			ldx	#$10					;������Ļ���룬׼��ת��ʮλ
			sec

NameBcd_2:

			lda	V_BcdDatL
			sbc	#$0A
			bcc	NameBcd_3				;�����������������û��ʮλ
			sta	V_BcdDatL				;�������򱣴��ȥ10�Ժ�Ľ��
			inx						;��¼ʮλ�ĸ���
			bne	NameBcd_2

NameBcd_3:

			stx	V_BcdDatM				;����ת��������ʮλ
			lda	V_BcdDatL				;û��������־��Ǹ�λ
			ora	#$10
			sta	V_BcdDatL

			ret
;===============================================================================
;������Ϸ��ţ������Ϸ���Ƶ��ַ�����ַ
;-------------------------------------------------------------------------------
;���룺		V_Names_H	=	��Ϸ��Ÿ�λ
;		V_Names_L	=	��Ϸ��ŵ�λ
;���		V_Data_Adr	=	��Ϸ�ַ�����ַ
;�ƻ���		A��X��Y��V_PROM_Adr
;-------------------------------------------------------------------------------
F_GetNameAdr:

			lda	#<A_NameTbl				;������Ϸ�����б��ַ
			sta	V_PROM_Adr
			lda	#>A_NameTbl
			sta	V_PROM_Adr+1
			lda	V_Names_L
			asl	A
			tay
			lda	V_Names_H
			rol	A
			adc	V_PROM_Adr+1
			sta	V_PROM_Adr+1

			lda	(V_PROM_Adr),y				;��ȡ��Ϸ�����ַ�����ַ
			sta	V_Data_Adr
			iny
			lda	(V_PROM_Adr),y
			sta	V_Data_Adr+1

			ret
;===============================================================================
;����Ϸ��ż�һ����������Ƿ�ﵽ�趨�����ֵ��
;-------------------------------------------------------------------------------
;���룺		V_Names_H	=	��Ϸ��Ÿ�λ
;		V_Names_L	=	��Ϸ��ŵ�λ
;���		��λ���� C	=	�Ƿ�ﵽ���ֵ
;�ƻ���		A
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
;��ʾһ���ַ�����������ַ�������� 00 ��ʾ����
;-------------------------------------------------------------------------------
;���룺		V_Data_Adr	=	�ַ������ݵ�ַ
;		$2006		=	����ǰ���ͼ�񻺴��ַ
;�ƻ���		A��X��Y���Լ��õ��������ڴ浥Ԫ
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
;�ƶ��ƶ�
;-------------------------------------------------------------------------------
F_MoveCloud:

			ldx	#$04

MoveCloud_0:

			dec	$0203,x					;��С�����ĺ�����
			inx
			inx
			inx
			inx
			cpx	#$1C
			bcc	MoveCloud_0

			ret
;===============================================================================
;��ȡ���ֱ�����ֵ�����Ѱ���ֵ����ڱ���V_KeyCode��
;-------------------------------------------------------------------------------
;����ֵ�������£�
;		00	û�а�������
;		01	��
;		02	��
;		04	��
;		08	��
;		10	��ʼ
;		20	ѡ��
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
;�ı������ɫ����꽻��ʹ�õ� 0,1 �ŵ�ɫ��
;����ĵڶ�������������ֵ������D0,D1��ָ��ʹ���Ŀ��ɫ��
;-------------------------------------------------------------------------------
F_AlterColor:

			lda	$0202
			eor	#$01
			sta	$0202

			ret
;===============================================================================
;�����¼�ʱ����Ч
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
;������Ϸ������Ļ��ҳʱ����Ч
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
;������Ƿ������һ���Ŀհ���������ǣ���ѹ��ָ�����һ����Ϸ
;-------------------------------------------------------------------------------
F_TestCursor:

			lda	V_Cursor				;������Ƿ񳬳���Χ
			cmp	#(C_MaxGame-C_MaxGame/20*20)
			bcc	Exit_Cursor				;������û�г�����Χ�����˳�

			lda	#(C_MaxGame-C_MaxGame/20*20)		;��곬���˷�Χ����ָ�����һ����Ϸ
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
;�ر��жϣ���ʾ���������Ա���ʾ��������
;-------------------------------------------------------------------------------
F_ClearAll:

			ldx	#$00
			stx	$2000					;�ر��ж�
			stx	$2001					;�ر���ʾ
			stx	$4015					;�ر�����

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
;���������жϷ�����򣬻���ɨ���϶�����жϣ���������ɨ���϶��־�����;������ݣ�
;���Ѹ����ڻ����еĵ�ɫ�崫�͸�ͼ��������������ɫЧ��ʱ������Ҫֱ�Ӳ���ͼ��
;������ֻ��ı仺���еĵ�ɫ���ݼ��ɡ�
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
;IRQ�жϷ������ֻ���ƶ���Ļʱ�����жϣ�������ָ������ʾ���л��������ꡣ
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
    DB   $22,$2B,$26,$00,$22,$30,$30,$00,$22,$20,$0A,$1A,$22,$27,$17,$0F
    DB   $22,$28,$26,$2A,$22,$26,$28,$2A,$23,$10,$10,$20,$22,$28,$14,$26
;-------------------------------------------------------------------------------
A_Tital:
                DB      'HUAWEI 128 IN 1',$00
;===============================================================================
;���鶨�壺ÿ�������ռ4���ֽڣ�����ֱ��ǣ�
;	�ֽ�0	=	������������
;	�ֽ�1	=	�����ĵ������
;	�ֽ�2	=	����������
;	�ֽ�3	=	�����ĺ�����
;�����������������£�
;	D0,D1	=	�����ʹ�õĵ�ɫ���
;	D2-D4	=	û�õ�
;	D5	=	���ȼ�������0ʱ�����ڱ���ǰ�棬����1ʱ�������ڱ�������
;	D6	=	���ҷ�ת������0ʱ���󲻷�ת������1ʱ���������ҷ�ת
;	D7	=	���µߵ�������0ʱ���󲻵ߵ�������1ʱ���������µߵ�
;-------------------------------------------------------------------------------
Sprite_Dat:
                db      $28,$1A,$00,$1C					;���
 
                db      $18,$01,$22,$D0					;�ƶ�
                db      $18,$02,$22,$D8
                db      $18,$03,$22,$E0
                db      $18,$04,$22,$E8
                db      $18,$05,$22,$F0
                db      $18,$06,$22,$F8
;===============================================================================
Sram_Prg:


			lda	#$20					;����д4801-4803
			sta	Rgst0

			lda	D_Sram+5				;��ȡͼ�񳤶�
			beq	Setup_PRom

			ldx	#$00
			lda	D_Sram+3				;ͼ�����ݵ�ַ��λ
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
			adc	D_Sram+2				;ͼ�����ݵ�ַ��λ
			sta	Rgst1
			stx	Rgst3

Setup_VLoop:

			lda	(V_Data_Adr),y				;��ȡ�����ַ
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
			lda	D_Sram					;�����ַ��λ
			sta	Rgst1
			lda	D_Sram+1				;�����ַ��λ
			sta	Rgst2
			lda	D_Sram+4				;������������
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
        DB      'NINJA RYUKENDEN 1',$00
Name_017:
        DB      'NINJA RYUKENDEN 2',$00
Name_018:
        DB      'NINJA RYUKENDEN 3',$00
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
        DB      'NEKKETSU STREET BASKET',$00
Name_037:
        DB      'NEKKETSU SHIN KIROKU',$00
Name_038:
        DB      'NEKKETSU KOUKOU DODGEBALL',$00
Name_039:
        DB      'NEKKETSU KAKUTOU DENSETSU',$00
Name_040:
        DB      'NEKKETSU MONOGATARI',$00
Name_041:
        DB      'NEKKETSU SOCCER HEN',$00
Name_042:
        DB      'NEKKETSU SOCCER LEAGUE',$00
Name_043:
        DB      'NEKKETSU KOUSHINKYOKU',$00
Name_044:
        DB      'NEKKETSU HOCKEY',$00
Name_045:
        DB      'NEKKETSU KOUHA KUNIO',$00
Name_046:
        DB      'SUPER MARIO',$00
Name_047:
        DB      'MARIO BROS 2',$00
Name_048:
        DB      'MARIO BROS 3',$00
Name_049:
        DB      'NINJA GAIDEN 1',$00
Name_050:
        DB      'NINJA GAIDEN 2',$00
Name_051:
        DB      'NINJA GAIDEN 3',$00
Name_052:
        DB      'CASTLEVANIA 1',$00
Name_053:
        DB      'CASTLEVANIA 2',$00
Name_054:
        DB      'P O W',$00
Name_055:
        DB      'CROSS FIRE',$00
Name_056:
        DB      'MITSUME GA TOORU',$00
Name_057:
        DB      'CHIP N DALE 1',$00
Name_058:
        DB      'CHIP N DALE 2',$00
Name_059:
        DB      'JACKIE CHAN',$00
Name_060:
        DB      'SNOW BROS',$00
Name_061:
        DB      'SAIYUUKI WORLD 1',$00
Name_062:
        DB      'CAT NINDEN TEYANDEE',$00
Name_063:
        DB      'MIGHTY FINAL FIGHT',$00
Name_064:
        DB      'CAPTAIN AMERICA',$00
Name_065:
        DB      'CAPTAIN TSUBASA 1',$00
Name_066:
        DB      'CAPTAIN TSUBASA 2',$00
Name_067:
        DB      'ADVENTURES OF BAYOU BILLY',$00
Name_068:
        DB      'KAGE',$00
Name_069:
        DB      'KICK MASTER',$00
Name_070:
        DB      'IKARI 1',$00
Name_071:
        DB      'IKARI 2',$00
Name_072:
        DB      'IKARI 3',$00
Name_073:
        DB      'FINAL MISSION',$00
Name_074:
        DB      'GUERRILLA WAR',$00
Name_075:
        DB      'GUN DEC',$00
Name_076:
        DB      'ROBOCOP 1',$00
Name_077:
        DB      'ROBOCOP 2',$00
Name_078:
        DB      'ROBOCOP 3',$00
Name_079:
        DB      'ROBOCOP 4',$00
Name_080:
        DB      'CODE NAME VIPER',$00
Name_081:
        DB      'DARKWING DUCK',$00
Name_082:
        DB      'DRAGON FIGHTER',$00
Name_083:
        DB      'ARGOS NO SENSHI',$00
Name_084:
        DB      'G I JOE 1',$00
Name_085:
        DB      'G I JOE 2',$00
Name_086:
        DB      'SWORD MASTER',$00
Name_087:
        DB      'TINY TOON 1',$00
Name_088:
        DB      'TINY TOON 2',$00
Name_089:
        DB      'TINY TOON 3',$00
Name_090:
        DB      'TINY TOON 4',$00
Name_091:
        DB      'TINY TOON 5',$00
Name_092:
        DB      'TOKKYUU SHIREI',$00
Name_093:
        DB      'PAJAMA HERO',$00
Name_094:
        DB      'PARODIUS',$00
Name_095:
        DB      'POWER BLADE 1',$00
Name_096:
        DB      'POWER BLADE 2',$00
Name_097:
        DB      'ASTYANAX',$00
Name_098:
        DB      'BATTLE KID 1',$00
Name_099:
        DB      'BATTLE KID 2',$00
Name_100:
        DB      'FELIX THE CAT',$00
Name_101:
        DB      'HEAVY BARREL',$00
Name_102:
        DB      'BUCKY O HARE',$00
Name_103:
        DB      'MONSTER',$00
Name_104:
        DB      'NINJA CRUSADERS',$00
Name_105:
        DB      'ULTRAMAN CLUB',$00
Name_106:
        DB      'SEIREI DENSETSU LICKLE',$00
Name_107:
        DB      'ROCK BOARD',$00
Name_108:
        DB      'TOP SECRET',$00
Name_109:
        DB      'THE SUPER SHINOBI',$00
Name_110:
        DB      'BAD DUDES',$00
Name_111:
        DB      'GOLD MEDAL',$00
Name_112:
        DB      'LEGENDARY WINGS',$00
Name_113:
        DB      'GREMLINS 2',$00
Name_114:
        DB      'JURASSIC PARK',$00
Name_115:
        DB      'MATENDOUJI',$00
Name_116:
        DB      'THUNDERCADE',$00
Name_117:
        DB      'METAL STORM',$00
Name_118:
        DB      'NINJA BROTHERS',$00
Name_119:
        DB      'OVER HORIZON',$00
Name_120:
        DB      'ZANAC',$00
Name_121:
        DB      'FLINTSTONES 1',$00
Name_122:
        DB      'FLINTSTONES 2',$00
Name_123:
        DB      'TERMINATOR 1',$00
Name_124:
        DB      'TERMINATOR 2',$00
Name_125:
        DB      'SILVER SURFER',$00
Name_126:
        DB      'TRACK AND FIELD',$00
Name_127:
        DB      'SPARTAN X',$00
Name_128:
        DB      '  ',$00
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
			dw	Game_015
;===============================================================================
;�궷��1��	���İ棺Ԥ��$07FF��D6-D4ѡ�أ�D3����30������D2-D0ѡ����
;-------------------------------------------------------------------------------
Game_001:
		SetupGame	$0040000,P08,$0060000,16,0,1
			dw	Contra1_Prg
;===============================================================================
;�궷��2��	���İ棺Ԥ��$07FD-$07FF��$07FD-������$07FE-������$07FF-����
;-------------------------------------------------------------------------------
Game_002:
		SetupGame	$0000000,P08,$0020000,16,0,1
			dw	Contra2_Prg
;===============================================================================
;�궷������	Ӣ�İ�		��Ԥ��
;-------------------------------------------------------------------------------
Game_003:
		SetupGame	$0080000,P08,$00A0000,16,0,0
;===============================================================================
;ɳ������	Ӣ�İ�		��Ԥ��
;-------------------------------------------------------------------------------
Game_004:
		SetupGame	$00C0000,P08,$0000000,00,0,0
;===============================================================================
;��ɫҪ��	Ӣ�İ�		��Ԥ��
;-------------------------------------------------------------------------------
Game_005:
		SetupGame	$00E0000,P08,$0000000,00,0,0
;===============================================================================
;��ɫ����	Ӣ�İ�		��Ԥ��
;-------------------------------------------------------------------------------
Game_006:
		SetupGame	$0100000,P08,$0000000,00,0,0
;===============================================================================
;��Ұ���ڿ�	Ӣ�İ�		��Ԥ��
;-------------------------------------------------------------------------------
Game_007:
		SetupGame	$0120000,P08,$0000000,00,0,0
;===============================================================================
;1944		���İ�		��Ԥ��
;-------------------------------------------------------------------------------
Game_008:
		SetupGame	$0140000,P08,$0000000,00,0,0
;===============================================================================
;���籭����	Ӣ�İ�		��Ԥ��
;-------------------------------------------------------------------------------
Game_009:
		SetupGame	$0160000,P04,$0170000,08,0,0
;===============================================================================
;��ʽ̨��	Ӣ�İ�		��Ԥ��
;-------------------------------------------------------------------------------
Game_010:
		SetupGame	$0180000,P08,$0000000,00,1,0
;===============================================================================
;����ս��	Ӣ�İ�		��Ԥ��
;-------------------------------------------------------------------------------
Game_011:
		SetupGame	$01A0000,P08,$01C0000,16,0,0
;===============================================================================
;˫����һ��	Ӣ�İ�		��Ԥ��
;-------------------------------------------------------------------------------
Game_012:
		SetupGame	$01E0000,P08,$0200000,16,0,0
;===============================================================================
;˫��������	Ӣ�İ�		��Ԥ��
;-------------------------------------------------------------------------------
Game_013:
		SetupGame	$0220000,P08,$0240000,16,0,0
;===============================================================================
;˫��������	Ӣ�İ�		��Ԥ��
;-------------------------------------------------------------------------------
Game_014:
		SetupGame	$0260000,P08,$0280000,16,0,0
;===============================================================================
;˫�����Ĵ�	Ӣ�İ�		��Ԥ��
;-------------------------------------------------------------------------------
Game_015:
		SetupGame	$02A0000,P08,$02C0000,16,0,0
;===============================================================================
Contra1_Prg:
			lda	#$08					;30������Ĭ����������һ�ؿ�ʼ
			sta	$07FF
			jmp	P_Sram
;-------------------------------------------------------------------------------
Contra2_Prg:
			lda	#029					;30����
			sta	$07FD
			lda	#00					;Ĭ������
			sta	$07FE
			sta	$07FF					;��һ�ؿ�ʼ
			jmp	P_Sram
;-------------------------------------------------------------------------------
;===============================================================================
                	ORG     $FFFA					;�˴��Ǹ�λ������ַ
;-------------------------------------------------------------------------------
               		DW      NMI_Program
                	DW      Reset_Adr
                	DW      IRQ_Program
;===============================================================================
