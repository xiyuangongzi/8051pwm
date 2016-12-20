;FileName:
;Description:
;Date:
;Designed_by:
;CPU:8051F310
;��Ƶ��24.5MHz
;R0 <- 
;R1 <- 
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
		MOV  P1,#00H			;�������ʾ����
		CLR  P0.7				;�����λѡ��ʼ��
		MOV  SP, #60H			;��ջ��ʼ��	
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
HERE:	;SJMP  HERE	            ;�ȴ��ж�
		
		
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
		MOV  TH1, #0FDH			;
		INC  R3					;
		;CJNE R3,#200,CAS1		;
		CJNE R3,#60,CAS1		;
		MOV  R3,#00H			;
		CJNE R2,#0,CAS16		;
		CLR F0					;
		AJMP CAS2				;
CAS16:	;CJNE R2,#15,CAS2		;
		CJNE R2,#31,CAS2		;
		SETB F0					;
		AJMP CAS2				;
;--������--
CAS2:	JB   F0,SU				;
		INC  R2
		INC  R6					;
		;CJNE R2,#15,CAS4		;
		CJNE R2, #31,CAS4		;
		SETB ISBI				;
CAS4:	CJNE R6, #0AH,HOME1		;
		MOV  R6, #0				;
		;MOV  R5, #1			;
		INC  R5					;
		AJMP HOME1
SU:		DEC  R2					;
		DEC  R6
		CJNE R2,#0,CAS5			;
		SETB ISBI				;
CAS5:	CJNE R6,#0FFH,HOME1		;
		MOV  R6,#9				;
		;MOV  R5,#0				;
		DEC  R5					;
		AJMP HOME1
CAS1:	JB   ISBI,CAS3			;
		AJMP HOME1				;
CAS3:	CJNE R3,#50,HOME1		;
		CLR  ISBI				;
HOME1:	LCALL KEYM
		LCALL PWM				;
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
DELAY:	MOV R0,#054H
DL:		MOV R1,#0FFH
DL0:	DJNZ R1,DL0
		DJNZ R0,DL
		RET
		
;-------------------------------------------
;KEYM
;-------------------------------------------
KEYM:	RET


;------------------------------------------
;ϵͳ��ʼ������
;------------------------------------------
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
