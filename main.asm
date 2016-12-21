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
		ISTEN BIT PSW.1			;�����Ƿ�������ʾʮλ��־λ
		CLR  ISTEN				;��ʼ��Ϊ0
        KEYED BIT 00H           ;
        FUCKT BIT 01H
		SET10 BIT 02H
		SET20 BIT 03H
		SET30 BIT 04H
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
ANN0:   
		MOV  R2, #00H
		MOV  R3, #00H			
		MOV  R5, #0				
		MOV  R6, #0				
        AJMP BACT5
ANN1:   MOV  R2, #01H
		MOV  R3, #00H			
		MOV  R5, #0				
		MOV  R6, #1				
        AJMP BACT5
ANN2:   MOV  R2, #02H
		MOV  R3, #00H			
		MOV  R5, #0				
		MOV  R6, #2				
        AJMP BACT5
ANN3:   MOV  R2, #03H
		MOV  R3, #00H			
		MOV  R5, #0				
		MOV  R6, #3				
        AJMP BACT5
ANN4:   MOV  R2, #04H
		MOV  R3, #00H			
		MOV  R5, #0				
		MOV  R6, #4				
        AJMP BACT5
ANN5:   MOV  R2, #05H
		MOV  R3, #00H			
		MOV  R5, #0				
		MOV  R6, #5				
        AJMP BACT5
ANN6:   MOV  R2, #06H
		MOV  R3, #00H			
		MOV  R5, #0				
		MOV  R6, #6				
        AJMP BACT5
ANN7:   MOV  R2, #07H
		MOV  R3, #00H			
		MOV  R5, #0				
		MOV  R6, #7				
        AJMP BACT5
ANN8:   MOV  R2, #08H
		MOV  R3, #00H			
		MOV  R5, #0				
		MOV  R6, #8				
        AJMP BACT5
ANN9:   MOV  R2, #09H
		MOV  R3, #00H			
		MOV  R5, #0				
		MOV  R6, #9				
        AJMP BACT5
ANNA:   AJMP BACT5
ANNB:   AJMP BACT5
ANNC:   AJMP BACT5
ANND:   MOV A,TIME
        ADD A,#20
        MOV TIME,A
        AJMP BACT5
ANNE:   MOV A,TIME
        CLR C
        SUBB A,#20
        MOV TIME,A
        AJMP BACT5
ANNF:   SETB ISBI
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