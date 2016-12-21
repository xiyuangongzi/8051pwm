;FileName:
;Description:
;Date:
;Designed_by:
;CPU:8051F310
;��Ƶ��24.5MHz
;R0 <- DELAY
;R1 <- DELAY
;R2 <- ���ȵȼ�
;R3 <- ����
;R4 <- PWM����
;R5 <- ��ʾʮλ
;R6 <- ��ʾ��λ
;R7 <- 
;ISBI <- ��������־λ
;------------------------------------
;-  Generated Initialization File  --
;------------------------------------
$include (C8051F310.inc)


        ORG  0000H		
RESET:  LJMP  MAIN        	 
        
        ORG  000BH            
        LJMP  INTT0                
        
		ORG  0013H
		LJMP  INTX1
			
		ORG  001BH
		LJMP  INTT1

;-------------------------------------
;-  ������
;-------------------------------------
        ORG   0100H
MAIN:   
		LCALL  Init_Device		;ϵͳ��ʼ��
		ISBI BIT P3.1			;�����������־λ
		CLR  ISBI				;����������
		MOV  P3,#00H
		ISTEN BIT PSW.1			;�����Ƿ�������ʾʮλ��־λ
		CLR  ISTEN				;��ʼ��Ϊ0
        KEYED BIT 00H           ;
        FUCKT BIT 01H
		SET10 BIT 02H
		SET20 BIT 03H
		SET30 BIT 04H
		FAST  BIT 05H
        ROW  EQU 7AH
        LIN  EQU 7BH
        BUFF EQU 7CH
        TIME EQU 7DH
        MOV  LIN,#0CH
		MOV  ROW,#00H
		MOV  BUFF,#00H
        MOV  TIME,#200
		CLR  FUCKT
		CLR  KEYED
		CLR  SET10
		CLR  SET20
		CLR  SET30
		CLR  FAST
		MOV  P1,#00H			;�������ʾ����
		CLR  P0.7				;�����λѡ��ʼ��
		MOV  SP, #50H			;��ջ��ʼ��	
		MOV  DPTR,#TAB			;��ʾ���
	    MOV  TMOD, #11H			;��ʱ���������ڷ�ʽ1
		MOV  TL1, #08FH			
		MOV  TH1, #0FDH			;����Ϊ10ms
        SETB  P0.0      		;���           
		SETB  TR1				
		SETB  ET1				;��T1�ж�
		SETB  IT1				;�½��ش���
		SETB  EX1				;���ⲿ�ж�1
		SETB  PX1				;�����ⲿ�ж�1���ȼ�Ϊ��
        SETB  EA   				;�����ж�
		MOV  R2, #00H			;��ʼ���ȵȼ�Ϊ0
		MOV  R3, #00H			;��ʼʱ�����Ϊ0
		MOV  R5, #0				;������ʾʮλΪ0
		MOV  R6, #0				;������ʾ��λΪ0
HERE:	SJMP  HERE	            ;�ȴ��ж�
		
		
;---------------------------------------
;��ʱ��0�жϣ�����PWM��ʱ
;---------------------------------------
INTT0:  CJNE R4,#0,L1			;����ʣ��ʱ���Ƿ�Ϊ0
		SETB  P0.0				;����ص�
		CLR  TR0				;���ж�
		AJMP HOME2				;�˳�
L1:		DEC R4					;��Ϊ0���һ
		;MOV  TL0, #0D9H			
		;MOV  TH0, #0FFH		;��������(10/15)ms
		MOV  TL0, #0ECH
		MOV  TH0, #0FFH			;��������(10/31)ms
HOME2:  RETI					;�˳��ж�

;------------------------------------------
;��ʱ��1�жϴ����������
;------------------------------------------
INTT1:
		MOV  TL1, #08FH			
		MOV  TH1, #0FDH			;����10ms
		INC  R3					;ʱ�����+1
		;CJNE R3,#200,CAS1		;
		MOV A,R3
		CJNE A,TIME,CAS1		;�жϼ�ʱ��2s
		MOV  R3,#00H			;
		CJNE R2,#0,CAS16		;�жϵ�ǰ���ȵȼ�Ϊ0
		CLR F0					;�ݼ���־��0
		AJMP CAS2				;
CAS16:	;CJNE R2,#15,CAS2		;
		CJNE R2,#31,CAS2		;�жϵ�ǰ���ȵȼ�31
		SETB F0					;�ݼ���־��1
		AJMP CAS2				;
;--������--
CAS2:	JB   F0,SU				;F0Ϊ1�������ݼ�
		INC  R2
		INC  R6					;��������
		;CJNE R2,#15,CAS4		;
		CJNE R2, #31,CAS4		;��һ�����ȵȼ���31
		SETB ISBI				;����
CAS4:	CJNE R6, #0AH,HOME1		;��λ������10
		MOV  R6, #0				;
		;MOV  R5, #1			;
		INC  R5					;
		AJMP HOME1
SU:		DEC  R2					;�ݼ�����
		DEC  R6
		CJNE R2,#0,CAS5			;��һ�����ȵȼ���0
		SETB ISBI				;����
CAS5:	CJNE R6,#0FFH,HOME1		;��λ�Ƶ�-1
		MOV  R6,#9				;
		;MOV  R5,#0				;
		DEC  R5					;
		AJMP HOME1
CAS1:	JB   ISBI,CAS3			;�жϷ������ǲ�������
		AJMP HOME1				;
CAS3:	CJNE R3,#50,HOME1		;������ж��Ƿ���0.5s
		CLR  ISBI				;
HOME1:
		LCALL KEYM
		LCALL PWM				;
		MOV  DPTR,#TAB
		LCALL  PLAY				;
		RETI
;------------------------------------------
;PWM
;------------------------------------------
PWM:	CJNE R2,#0,HOME3		;������ȵȼ�Ϊ0
		CLR  TR0				;�Ͳ����жϲ�����
		RET						;�˳�
HOME3:	;MOV  TL0, #0D9H		;�����Ϊ0
		;MOV  TH0, #0FFH		;��ʱ(10/15)ms  
		MOV  TL0, #0ECH
		MOV  TH0, #0FFH			;��ʱ(10/31)ms
		MOV  B,R2
		MOV  R4,B				;R4Ϊ����ʱ��
		SETB  TR0
		SETB  ET0				;��T0�ж�
		CLR   P0.0				;����
		RET
		
;-------------------------------------------
;DISPLAY
;-------------------------------------------
PLAY:	JNB TR1,HOM
		JB ISTEN,TEN			;���������ʾʮλ
		CLR P0.6				;�Ϳ�ʼ��ʾ��λ
		MOV A,R6
		MOVC A,@A+DPTR			;ȡ��λ����
		MOV P1,A				;��ʾ
		CPL ISTEN				;��־λȡ��
		RET
TEN:	SETB P0.6				;��ʼ��ʾʮλ
		MOV A,R5				
		MOVC A,@A+DPTR			;ȡʮλ����
		MOV P1,A				;��ʾ
		CPL ISTEN				;��־λȡ��
HOM:	RET

TAB:	DB 0FCH,060H,0DAH,0F2H,066H
		DB 0B6H,0BEH,0E0H,0FEH,0F6H
		
;------------------------------------------
;�ⲿ�жϣ�Ϩ�Ƽ�����
;------------------------------------------
INTX1:	LCALL DELAY
		JB   P0.1,X1
		CPL  TR1	
		MOV  P1,#00H
		SETB P0.0
X1:		RETI
;------------------------------------------
;DELAY
;------------------------------------------
DELAY:	MOV R0,#034H
DL:		MOV R1,#0FFH
DL0:	DJNZ R1,DL0
		DJNZ R0,DL
		RET
		
;-------------------------------------------
;KEYM������ɨ�����
;-------------------------------------------
KEYM:	LCALL KEYAM			;�Ƿ��м�����
        JZ BACT1			;A=0,�ޣ�ȥ���֮ǰ�Ƿ��м�����
        JB FUCKT,BACT		;�м����£��Ƿ������ֵ���Ǿ�����ȥ
        JNB KEYED,BACT2     ;û�м�����keyed=0�ǵ�һ�μ죬ȥ��1 
        ;ZHAO_CHU_LAI       ;�������������İ�����
        CLR C				;
        MOV P2, #0FEH		;��ʼ�Ҽ�ֵ
        LCALL KEYBM			;
        MOV ROW,#00H		;
        JNZ BACT3           ;A!=0,�ҵ����У�ȥ����
        MOV P2, #0FDH       ;A=0,������
        LCALL KEYBM
        MOV ROW,#01H
        JNZ BACT3
        MOV P2, #0FBH
        LCALL KEYBM
        MOV ROW,#02H
        JNZ BACT3
        MOV P2, #0F7H
        LCALL KEYBM
        MOV ROW,#03H
        JNZ BACT3           ;
        AJMP BACT1			;�������û�ҵ����ͻ�ȥ
BACT4:  MOV A,ROW
        ADD A,LIN
		MOV  LIN,#0CH
        MOV BUFF,A
        ADD A,BUFF
        MOV DPTR,#TAB2	    ;�����ַ
        JMP @A+DPTR
BACT5:  		;���������˷��������ʾ���
        CLR FUCKT			;���������ֵ��־
        AJMP BACT1			;��ȥ
BACT3:  
        RLC A 				
        JC BACT6            ;�ҵ�����
		DEC  LIN
		DEC  LIN
		DEC  LIN
		DEC  LIN
		AJMP BACT3
BACT6:  SETB FUCKT 			;������ֵ��־��1
        AJMP BACT			;��ȥ
BACT2:  SETB KEYED 
        AJMP BACT
BACT1:  JB FUCKT,BACT4		;֮ǰ�м����£����ڷ���
        CLR KEYED
BACT:   RET
;-------------------------------------------
;TAB2�������������
;-------------------------------------------
TAB2:   AJMP    ANN0
        AJMP    ANN1   
        AJMP    ANN2   
        AJMP    ANN3    
        AJMP    ANN4
        AJMP    ANN5
        AJMP    ANN6
        AJMP    ANN7    
        AJMP    ANN8
        AJMP    ANN9
        AJMP    ANNA
        AJMP    ANNB    
        AJMP    ANNC
        AJMP    ANND
        AJMP    ANNE
        AJMP    ANNF    
;-------------------------------------------
;�����������
;-------------------------------------------
ANN0:   MOV  R3, #00H
		MOV  R6, #0
		JNB SET10,TO200
		MOV  R2, #0AH
		MOV  R5, #1
		CLR  SET10
		AJMP BACT5
TO200:  JNB SET20,TO300
		MOV  R2, #014H
		MOV  R5, #2
		CLR  SET20
		AJMP BACT5
TO300:  JNB SET30,TO000
		MOV  R2, #01EH
		MOV  R5, #3
		CLR  SET30
		AJMP BACT5
TO000:	MOV  R2, #00H
		MOV  R5, #0
		AJMP BACT5
ANN1:   MOV  R3, #00H
		MOV  R6, #1
		JNB SET10,TO201
		MOV  R2, #0bH
		MOV  R5, #1
		CLR  SET10
		AJMP BACT5
TO201:  JNB SET20,TO301
		MOV  R2, #015H
		MOV  R5, #2
		CLR  SET20
		AJMP BACT5
TO301:  JNB SET30,TO001
		MOV  R2, #01fH
		MOV  R5, #3
		CLR  SET30
		AJMP BACT5
TO001:	MOV  R2, #01H
		MOV  R5, #0
		AJMP BACT5
ANN2:   MOV  R3, #00H
		MOV  R6, #2
		JNB SET10,TO202
		MOV  R2, #0cH
		MOV  R5, #1
		CLR  SET10
		AJMP BACT5
TO202:  JNB SET20,TO302
		MOV  R2, #016H
		MOV  R5, #2
		CLR  SET20
		AJMP BACT5
TO302:  JNB SET30,TO002
		CLR  SET30
TO002:	MOV  R2, #02H
		MOV  R5, #0
		AJMP BACT5
ANN3:   MOV  R3, #00H
		MOV  R6, #3
		JNB SET10,TO203
		MOV  R2, #0dH
		MOV  R5, #1
		CLR  SET10
		AJMP BACT5
TO203:  JNB SET20,TO303
		MOV  R2, #017H
		MOV  R5, #2
		CLR  SET20
		AJMP BACT5
TO303:  JNB SET30,TO003
		CLR  SET30
TO003:	MOV  R2, #03H
		MOV  R5, #0
		AJMP BACT5
ANN4:   MOV  R3, #00H
		MOV  R6, #4
		JNB SET10,TO204
		MOV  R2, #0eH
		MOV  R5, #1
		CLR  SET10
		AJMP BACT5
TO204:  JNB SET20,TO304
		MOV  R2, #018H
		MOV  R5, #2
		CLR  SET20
		AJMP BACT5
TO304:  JNB SET30,TO004
		CLR  SET30
TO004:	MOV  R2, #04H
		MOV  R5, #0
		AJMP BACT5
ANN5:   MOV  R3, #00H
		MOV  R6, #5
		JNB SET10,TO205
		MOV  R2, #0fH
		MOV  R5, #1
		CLR  SET10
		AJMP BACT5
TO205:  JNB SET20,TO305
		MOV  R2, #019H
		MOV  R5, #2
		CLR  SET20
		AJMP BACT5
TO305:  JNB SET30,TO005
		CLR  SET30
TO005:	MOV  R2, #05H
		MOV  R5, #0
		AJMP BACT5
ANN6:   MOV  R3, #00H
		MOV  R6, #6
		JNB SET10,TO206
		MOV  R2, #010H
		MOV  R5, #1
		CLR  SET10
		AJMP BACT5
TO206:  JNB SET20,TO306
		MOV  R2, #01aH
		MOV  R5, #2
		CLR  SET20
		AJMP BACT5
TO306:  JNB SET30,TO006
		CLR  SET30
TO006:	MOV  R2, #06H
		MOV  R5, #0
		AJMP BACT5
ANN7:   MOV  R3, #00H
		MOV  R6, #7
		JNB SET10,TO207
		MOV  R2, #011H
		MOV  R5, #1
		CLR  SET10
		AJMP BACT5
TO207:  JNB SET20,TO307
		MOV  R2, #01bH
		MOV  R5, #2
		CLR  SET20
		AJMP BACT5
TO307:  JNB SET30,TO007
		CLR  SET30
TO007:	MOV  R2, #07H
		MOV  R5, #0
		AJMP BACT5
ANN8:   MOV  R3, #00H
		MOV  R6, #8
		JNB SET10,TO208
		MOV  R2, #012H
		MOV  R5, #1
		CLR  SET10
		AJMP BACT5
TO208:  JNB SET20,TO308
		MOV  R2, #01cH
		MOV  R5, #2
		CLR  SET20
		AJMP BACT5
TO308:  JNB SET30,TO008
		CLR  SET30
TO008:	MOV  R2, #08H
		MOV  R5, #0
		AJMP BACT5
ANN9:   MOV  R3, #00H
		MOV  R6, #9
		JNB SET10,TO209
		MOV  R2, #013H
		MOV  R5, #1
		CLR  SET10
		AJMP BACT5
TO209:  JNB SET20,TO309
		MOV  R2, #01dH
		MOV  R5, #2
		CLR  SET20
		AJMP BACT5
TO309:  JNB SET30,TO009
		CLR  SET30
TO009:	MOV  R2, #09H
		MOV  R5, #0
		AJMP BACT5

ANNA:   SETB SET10
        AJMP BACT5
ANNB:   SETB SET20
        AJMP BACT5
ANNC:   SETB SET30
        AJMP BACT5
ANND:   SETB F0
        AJMP BACT5
ANNE:   CLR  F0
        AJMP BACT5
ANNF:   CPL FAST
		JB  FAST,ANFK
ANFM:   MOV TIME,#200
		AJMP BACT5
ANFK:   MOV TIME,#60
		AJMP BACT5
;-------------------------------------------
;KEYAM���ж��Ƿ��м�����
;-------------------------------------------
KEYAM:  MOV P2,#0F0H
		MOV A,P2
        ORL A,#00FH
        CPL A
        RET
KEYBM: 
		MOV A,P2
        ORL A,#00FH
        CPL A
        RET
;-------------------------------------------
;ϵͳ��ʼ������
;-------------------------------------------
public  Init_Device

INIT SEGMENT CODE
    rseg INIT

; Peripheral specific initialization functions,
; Called from the Init_Device label
PCA_Init:
    anl  PCA0MD,    #0BFh
    mov  PCA0MD,    #000h
    ret

Timer_Init:
    mov  TMOD,      #011h
    mov  CKCON,     #002h
    ret

Port_IO_Init:
    ; P0.0  -  Unassigned,  Open-Drain, Digital
    ; P0.1  -  Unassigned,  Open-Drain, Digital
    ; P0.2  -  Unassigned,  Open-Drain, Digital
    ; P0.3  -  Unassigned,  Open-Drain, Digital
    ; P0.4  -  Unassigned,  Open-Drain, Digital
    ; P0.5  -  Unassigned,  Open-Drain, Digital
    ; P0.6  -  Unassigned,  Open-Drain, Digital
    ; P0.7  -  Unassigned,  Open-Drain, Digital

    ; P1.0  -  Unassigned,  Open-Drain, Digital
    ; P1.1  -  Unassigned,  Open-Drain, Digital
    ; P1.2  -  Unassigned,  Open-Drain, Digital
    ; P1.3  -  Unassigned,  Open-Drain, Digital
    ; P1.4  -  Unassigned,  Open-Drain, Digital
    ; P1.5  -  Unassigned,  Open-Drain, Digital
    ; P1.6  -  Unassigned,  Open-Drain, Digital
    ; P1.7  -  Unassigned,  Open-Drain, Digital
    ; P2.0  -  Unassigned,  Open-Drain, Digital
    ; P2.1  -  Unassigned,  Open-Drain, Digital
    ; P2.2  -  Unassigned,  Open-Drain, Digital
    ; P2.3  -  Unassigned,  Open-Drain, Digital

    mov  XBR1,      #040h
    ret

Interrupts_Init:
    mov  IT01CF,    #010h
    mov  IE,        #00Eh
    ret

; Initialization function for device,
; Call Init_Device from your main program
Init_Device:
    lcall PCA_Init
    lcall Timer_Init
    lcall Port_IO_Init
    lcall Interrupts_Init
    ret

end