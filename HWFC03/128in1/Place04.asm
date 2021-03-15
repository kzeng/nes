;===============================================================================
               	SYNTAX        	6502
               	LINKLIST
               	SYMBOLS
;===============================================================================
;这是蝙蝠侠2的mapper修改，把 Mapper069 改成 Mapper004
;-------------------------------------------------------------------------------
F_SetVbank1	equ	$E39B
F_SetVbankL	equ	$E3AD

               	ORG	$8000
               	db	$FF
;-------------------------------------------------------------------------------
               	ORG	$8A06

		LDX	#$00		;$8A06	A2 00 
ADR_8A08:				;$8A08
;		STX	ADR_8000    	;$8A08	8E 00 80
;		STA	$A000		;$8A0B	8D 00 A0
		sta	$E0,x
		CLC			;$8A0E	18 
		ADC	#$01		;$8A0F	69 01 
		INX			;$8A11	E8 
		CPX	#$08		;$8A12	E0 08 
		BNE	ADR_8A08	;$8A14	D0 F2 
		nop
		jsr	F_SetVbank1
		LDA	$2002		;$8A16	AD 02 20
;-------------------------------------------------------------------------------
               	ORG	$8BA1

		LDX	#$00		;$8BA1	A2 00 
ADR_8BA3:				;$8BA3
;		STX	ADR_8000    	;$8BA3	8E 00 80
;		STA	$A000		;$8BA6	8D 00 A0
		sta	$E0,x
		CLC			;$8BA9	18 
		ADC	#$01		;$8BAA	69 01 
		INX			;$8BAC	E8 
		CPX	#$08		;$8BAD	E0 08 
ADR_8BAF:				;$8BAF
		BNE	ADR_8BA3	;$8BAF	D0 F2 
		nop
		jsr	F_SetVbank1
		LDA	$2002		;$8BB1	AD 02 20
;-------------------------------------------------------------------------------
               	ORG	$9609

;		LDA	#$80		;$9609	A9 80 
		lda	#$480/$72
		LDY	#$04		;$960B	A0 04 
		JSR	ADR_98AD    	;$960D	20 AD 98
		INC	$D4		;$9610	E6 D4 
		JMP	ADR_9894    	;$9612	4C 94 98
		LDA	$DA		;$9615	A5 DA 
		LSR	A		;$9617	4A 
		AND	#$01		;$9618	29 01 
		ORA	$FF		;$961A	05 FF 
		STA	$2000		;$961C	8D 00 20
		LDA	$D6		;$961F	A5 D6 
		JSR	ADR_98A1    	;$9621	20 A1 98
;		LDA	#$00		;$9624	A9 00 
		lda	#$300/$72
		LDY	#$03		;$9626	A0 03 
		JSR	ADR_98AD    	;$9628	20 AD 98
		INC	$D4		;$962B	E6 D4 
		JMP	ADR_9894    	;$962D	4C 94 98
		LDA	$DA		;$9630	A5 DA 
		LSR	A		;$9632	4A 
		LSR	A		;$9633	4A 
		AND	#$01		;$9634	29 01 
		ORA	$FF		;$9636	05 FF 
		STA	$2000		;$9638	8D 00 20
		LDA	$D7		;$963B	A5 D7 
		JSR	ADR_98A1    	;$963D	20 A1 98
;		LDA	#$00		;$9640	A9 00 
		lda	#$300/$72
		LDY	#$03		;$9642	A0 03 
		JSR	ADR_98AD    	;$9644	20 AD 98
		INC	$D4		;$9647	E6 D4 
		JMP	ADR_9894    	;$9649	4C 94 98
		LDA	$DA		;$964C	A5 DA 
		LSR	A		;$964E	4A 
		LSR	A		;$964F	4A 
		LSR	A		;$9650	4A 
		AND	#$01		;$9651	29 01 
		ORA	$FF		;$9653	05 FF 
		STA	$2000		;$9655	8D 00 20
		LDA	$D8		;$9658	A5 D8 
		JSR	ADR_98A1    	;$965A	20 A1 98
;		LDA	#$00		;$965D	A9 00 
		lda	#$300/$72
		LDY	#$03		;$965F	A0 03 
		JSR	ADR_98AD    	;$9661	20 AD 98
		INC	$D4		;$9664	E6 D4 
		JMP	ADR_9894    	;$9666	4C 94 98
		LDA	$DA		;$9669	A5 DA 
		LSR	A		;$966B	4A 
		LSR	A		;$966C	4A 
		LSR	A		;$966D	4A 
		LSR	A		;$966E	4A 
		AND	#$01		;$966F	29 01 
		ORA	$FF		;$9671	05 FF 
		STA	$2000		;$9673	8D 00 20
		LDA	$D9		;$9676	A5 D9 
		JSR	ADR_98A1    	;$9678	20 A1 98
;		LDA	#$00		;$967B	A9 00 
		lda	#$300/$72
		LDY	#$03		;$967D	A0 03 
		JSR	ADR_98AD    	;$967F	20 AD 98
		INC	$D4		;$9682	E6 D4 
		JMP	ADR_9894    	;$9684	4C 94 98
		LDA	$DA		;$9687	A5 DA 
		AND	#$01		;$9689	29 01 
		ORA	$FF		;$968B	05 FF 
		STA	$2000		;$968D	8D 00 20
		LDA	$D5		;$9690	A5 D5 
		JSR	ADR_98A1    	;$9692	20 A1 98
;		LDA	#$00		;$9695	A9 00 
		lda	#$600/$72
		LDY	#$06		;$9697	A0 06 
		JSR	ADR_98AD    	;$9699	20 AD 98
		INC	$D4		;$969C	E6 D4 
		JMP	ADR_9894    	;$969E	4C 94 98
		LDA	$FF		;$96A1	A5 FF 
		ORA	#$01		;$96A3	09 01 
		STA	$2000		;$96A5	8D 00 20
		LDA	#$00		;$96A8	A9 00 
		JSR	ADR_98A1    	;$96AA	20 A1 98
		LDA	#$00		;$96AD	A9 00 
		STA	$D4		;$96AF	85 D4 
		LDA	$DA		;$96B1	A5 DA 
		AND	#$01		;$96B3	29 01 
		BNE	ADR_96CA	;$96B5	D0 13 
		LDA	$D5		;$96B7	A5 D5 
		CLC			;$96B9	18 
		ADC	#$20		;$96BA	69 20 
		STA	$D5		;$96BC	85 D5 
		BCC	ADR_96CA	;$96BE	90 0A 
		LDA	$DA		;$96C0	A5 DA 
		ORA	#$01		;$96C2	09 01 
		STA	$DA		;$96C4	85 DA 
		LDA	#$00		;$96C6	A9 00 
		STA	$D5		;$96C8	85 D5 
ADR_96CA:				;$96CA
		LDA	$DA		;$96CA	A5 DA 
		AND	#$02		;$96CC	29 02 
		BNE	ADR_96E3	;$96CE	D0 13 
		LDA	$D6		;$96D0	A5 D6 
		CLC			;$96D2	18 
		ADC	#$28		;$96D3	69 28 
		STA	$D6		;$96D5	85 D6 
		BCC	ADR_96E3	;$96D7	90 0A 
		LDA	$DA		;$96D9	A5 DA 
		ORA	#$02		;$96DB	09 02 
		STA	$DA		;$96DD	85 DA 
		LDA	#$00		;$96DF	A9 00 
		STA	$D6		;$96E1	85 D6 
ADR_96E3:				;$96E3
		LDA	$DA		;$96E3	A5 DA 
		AND	#$04		;$96E5	29 04 
		BNE	ADR_96FC	;$96E7	D0 13 
		LDA	$D7		;$96E9	A5 D7 
		CLC			;$96EB	18 
		ADC	#$40		;$96EC	69 40 
		STA	$D7		;$96EE	85 D7 
		BCC	ADR_96FC	;$96F0	90 0A 
		LDA	$DA		;$96F2	A5 DA 
		ORA	#$04		;$96F4	09 04 
		STA	$DA		;$96F6	85 DA 
		LDA	#$00		;$96F8	A9 00 
		STA	$D7		;$96FA	85 D7 
ADR_96FC:				;$96FC
		LDA	$DA		;$96FC	A5 DA 
		AND	#$08		;$96FE	29 08 
		BNE	ADR_9715	;$9700	D0 13 
		LDA	$D8		;$9702	A5 D8 
		CLC			;$9704	18 
		ADC	#$50		;$9705	69 50 
		STA	$D8		;$9707	85 D8 
		BCC	ADR_9715	;$9709	90 0A 
		LDA	$DA		;$970B	A5 DA 
		ORA	#$08		;$970D	09 08 
		STA	$DA		;$970F	85 DA 
		LDA	#$00		;$9711	A9 00 
		STA	$D8		;$9713	85 D8 
ADR_9715:				;$9715
		LDA	$DA		;$9715	A5 DA 
		AND	#$10		;$9717	29 10 
		BNE	ADR_972E	;$9719	D0 13 
		LDA	$D9		;$971B	A5 D9 
		CLC			;$971D	18 
		ADC	#$58		;$971E	69 58 
		STA	$D9		;$9720	85 D9 
		BCC	ADR_972E	;$9722	90 0A 
		LDA	$DA		;$9724	A5 DA 
		ORA	#$10		;$9726	09 10 
		STA	$DA		;$9728	85 DA 
		LDA	#$00		;$972A	A9 00 
		STA	$D9		;$972C	85 D9 
ADR_972E:				;$972E
		JMP	$E29D    	;$972E	4C 9D E2
		LDA	$D4		;$9731	A5 D4 
		ASL	A		;$9733	0A 
		TAY			;$9734	A8 
		LDA	ADR_9742,Y  	;$9735	B9 42 97
		STA	$08		;$9738	85 08 
		LDA	ADR_9743,Y  	;$973A	B9 43 97
		STA	$09		;$973D	85 09 
		JMP	($0008)    	;$973F	6C 08 00
ADR_9742:				;$9742
		PHA			;$9742	48 
ADR_9743:				;$9743
    DB  $97,$62,$97,$7D,$97
;		ADC	$A597,X  	;$9746	7D 97 A5
;    DB  $DA
		lda	$DA
		AND	#$01		;$974A	29 01 
		ORA	$FF		;$974C	05 FF 
		STA	$2000		;$974E	8D 00 20
		LDA	$D5		;$9751	A5 D5 
		JSR	ADR_98A1    	;$9753	20 A1 98
;		LDA	#$00		;$9756	A9 00 
		lda	#$1000/$72
		LDY	#$10		;$9758	A0 10 
		JSR	ADR_98AD    	;$975A	20 AD 98
		LDA	#$01		;$975D	A9 01 
		JMP	$9892    	;$975F	4C 92 98
		LDA	$DA		;$9762	A5 DA 
		LSR	A		;$9764	4A 
		AND	#$01		;$9765	29 01 
		ORA	$FF		;$9767	05 FF 
		STA	$2000		;$9769	8D 00 20
		LDA	$D6		;$976C	A5 D6 
		JSR	ADR_98A1    	;$976E	20 A1 98
;		LDA	#$00		;$9771	A9 00 
		lda	#$1000/$72
		LDY	#$10		;$9773	A0 10 
		JSR	ADR_98AD    	;$9775	20 AD 98
		LDA	#$02		;$9778	A9 02 
		JMP	$9892    	;$977A	4C 92 98
		LDA	$FF		;$977D	A5 FF 
		AND	#$FE		;$977F	29 FE 
		STA	$2000		;$9781	8D 00 20
		LDA	#$00		;$9784	A9 00 
		JSR	ADR_98A1    	;$9786	20 A1 98
		LDA	#$00		;$9789	A9 00 
		STA	$D4		;$978B	85 D4 
		LDA	$DA		;$978D	A5 DA 
		AND	#$01		;$978F	29 01 
		BEQ	ADR_979E	;$9791	F0 0B 
		LDA	$DA		;$9793	A5 DA 
		AND	#$FE		;$9795	29 FE 
		STA	$DA		;$9797	85 DA 
		LDA	$D5		;$9799	A5 D5 
		JMP	ADR_97A2    	;$979B	4C A2 97
ADR_979E:				;$979E
		LDA	$D5		;$979E	A5 D5 
		BEQ	ADR_97AA	;$97A0	F0 08 
ADR_97A2:				;$97A2
		SEC			;$97A2	38 
		SBC	#$08		;$97A3	E9 08 
		STA	$D5		;$97A5	85 D5 
		JMP	$E29D    	;$97A7	4C 9D E2
ADR_97AA:				;$97AA
		LDA	$DA		;$97AA	A5 DA 
		AND	#$02		;$97AC	29 02 
		BEQ	ADR_97B5	;$97AE	F0 05 
		LDA	$D6		;$97B0	A5 D6 
		JMP	ADR_97B9    	;$97B2	4C B9 97
ADR_97B5:				;$97B5
		LDA	$D6		;$97B5	A5 D6 
		BEQ	ADR_97C6	;$97B7	F0 0D 
ADR_97B9:				;$97B9
		CLC			;$97B9	18 
		ADC	#$08		;$97BA	69 08 
		STA	$D6		;$97BC	85 D6 
		BCC	ADR_97C6	;$97BE	90 06 
		LDA	$DA		;$97C0	A5 DA 
		AND	#$FD		;$97C2	29 FD 
		STA	$DA		;$97C4	85 DA 
ADR_97C6:				;$97C6
		JMP	$E29D    	;$97C6	4C 9D E2
		LDA	$D5		;$97C9	A5 D5 
		JSR	ADR_98A1    	;$97CB	20 A1 98
		LDA	$FD		;$97CE	A5 FD 
		CMP	#$41		;$97D0	C9 41 
		BCS	ADR_97DA	;$97D2	B0 06 
		LDA	$D5		;$97D4	A5 D5 
		BEQ	ADR_97DA	;$97D6	F0 02 
		DEC	$D5		;$97D8	C6 D5 
ADR_97DA:				;$97DA
		JMP	$E29D    	;$97DA	4C 9D E2
		LDA	$D4		;$97DD	A5 D4 
		ASL	A		;$97DF	0A 
		TAY			;$97E0	A8 
		LDA	ADR_97EE,Y  	;$97E1	B9 EE 97
		STA	$08		;$97E4	85 08 
		LDA	ADR_97EF,Y  	;$97E6	B9 EF 97
		STA	$09		;$97E9	85 09 
		JMP	($0008)    	;$97EB	6C 08 00
ADR_97EE:				;$97EE
    DB  $F2
ADR_97EF:				;$97EF
    DB  $97
		ASL	A		;$97F0	0A 
		TYA			;$97F1	98 
		LDA	#$01		;$97F2	A9 01 
		ORA	$FF		;$97F4	05 FF 
		STA	$2000		;$97F6	8D 00 20
		LDA	$D5		;$97F9	A5 D5 
		JSR	ADR_98A1    	;$97FB	20 A1 98
;		LDA	#$00		;$97FE	A9 00 
		lda	#$4000/$72
		LDY	#$40		;$9800	A0 40 
		JSR	ADR_98AD    	;$9802	20 AD 98
		LDA	#$01		;$9805	A9 01 
		JMP	$9892    	;$9807	4C 92 98
		LDA	$FF		;$980A	A5 FF 
		STA	$2000		;$980C	8D 00 20
		LDA	#$0A		;$980F	A9 0A 
		STA	$2001		;$9811	8D 01 20
		LDA	#$00		;$9814	A9 00 
		JSR	ADR_98A1    	;$9816	20 A1 98
		LDA	#$00		;$9819	A9 00 
		STA	$D4		;$981B	85 D4 
		JMP	$E29D    	;$981D	4C 9D E2
		LDA	$D4		;$9820	A5 D4 
		ASL	A		;$9822	0A 
		TAY			;$9823	A8 
		LDA	ADR_9831,Y  	;$9824	B9 31 98
		STA	$08		;$9827	85 08 
		LDA	ADR_9831+1,Y  	;$9829	B9 32 98
		STA	$09		;$982C	85 09 
		JMP	($0008)    	;$982E	6C 08 00
ADR_9831:				;$9831
		AND	$4A98,Y  	;$9831	39 98 4A
		TYA			;$9834	98 
		AND	$5B98,Y  	;$9835	39 98 5B
		TYA			;$9838	98 
		LDA	$D8		;$9839	A5 D8 
		JSR	ADR_98A1    	;$983B	20 A1 98
;		LDA	#$00		;$983E	A9 00 
		lda	#$1000/$72
		LDY	#$10		;$9840	A0 10 
		JSR	ADR_98AD    	;$9842	20 AD 98
		INC	$D4		;$9845	E6 D4 
		JMP	ADR_9894    	;$9847	4C 94 98
		LDA	$DA		;$984A	A5 DA 
		JSR	ADR_98A1    	;$984C	20 A1 98
;		LDA	#$00		;$984F	A9 00 
		lda	#$700/$72
		LDY	#$07		;$9851	A0 07 
		JSR	ADR_98AD    	;$9853	20 AD 98
		INC	$D4		;$9856	E6 D4 
		JMP	ADR_9894    	;$9858	4C 94 98
;-------------------------------------------------------------------------------
               	ORG	$9894

ADR_9894:				;$9894				;允许中断请求
;		LDX	#$0D		;$9894	A2 0D 
;		LDA	#$81		;$9896	A9 81 
;		STX	ADR_8000    	;$9898	8E 00 80
;		STA	$A000		;$989B	8D 00 A0
		sta	$E001
		JMP	$E29D    	;$989E	4C 9D E2
		nop
		nop
		nop
		nop
		nop
		nop
		nop

ADR_98A1:				;$98A1
		LDX	$2002		;$98A1	AE 02 20
		STA	$2005		;$98A4	8D 05 20
		LDA	#$00		;$98A7	A9 00 
		STA	$2005		;$98A9	8D 05 20
		RTS			;$98AC	60 
ADR_98AD:				;$98AD
;		LDX	#$0E		;$98AD	A2 0E 
;		STX	ADR_8000    	;$98AF	8E 00 80
;		STA	$A000		;$98B2	8D 00 A0
;		INX			;$98B5	E8 
;		STX	ADR_8000    	;$98B6	8E 00 80
;		STY	$A000		;$98B9	8C 00 A0
		sta	$C000
		sta	$C001

		RTS			;$98BC	60 
ADR_98BD:				;$98BD
;-------------------------------------------------------------------------------
               	ORG	$9925

ADR_9925:				;$9925
		LDX	#$F7		;$9925	A2 F7 
		LDY	#$07		;$9927	A0 07 
ADR_9929:				;$9929
;		STY	$8000		;$9929	8C 00 80
;		nop
;		nop
;		nop
;		STX	ADR_A000    	;$992C	8E 00 A0
;		nop
;		nop
		stx	$E0,y
		DEX			;$992F	CA 
		DEY			;$9930	88 
		BPL	ADR_9929	;$9931	10 F6 
		nop
		jsr	F_SetVbank1

		LDA	#$7E		;$9933	A9 7E 
		STA	$11		;$9935	85 11 
		LDA	#$60		;$9937	A9 60 
		STA	$10		;$9939	85 10 
		LDA	$2002		;$993B	AD 02 20
		LDA	#$1E		;$993E	A9 1E 
;-------------------------------------------------------------------------------
               	ORG	$9B76

		LDX	#$F7		;$9B76	A2 F7 
		LDY	#$03		;$9B78	A0 03 
ADR_9B7A:				;$9B7A
;		STY	$8000		;$9B7A	8C 00 80
;		STX	ADR_A000    	;$9B7D	8E 00 A0
		stx	$E0,y
		DEX			;$9B80	CA 
		DEY			;$9B81	88 
		BPL	ADR_9B7A	;$9B82	10 F6 
		jsr	F_SetVbankL
		nop
		LDY	#$00		;$9B84	A0 00 
		STY	$10		;$9B86	84 10 
		LDA	#$60		;$9B88	A9 60 
		STA	$11		;$9B8A	85 11 
		LDA	$2002		;$9B8C	AD 02 20
;===============================================================================
              	ORG     $FFFA
 
               	DW      $FFFF
               	DW      $FFFF
               	DW      $FFFF
;===============================================================================
