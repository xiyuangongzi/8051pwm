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
		SETB  ET1				
        SETB  EA   				;��T1�ж�
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
		MOV  TH1, #0FDH			;����Ϊ10ms
		INC  R3					;ʱ�����+1
		;CJNE R3,#200,CAS1		;�жϼ�ʱ��2S
		CJNE R3,#100,CAS1		;�жϼ�ʱ��1S
		MOV  R3,#00H			;��������ʱ��0
		CJNE R2,#0,CAS16		;�жϵ�ǰ���ȵȼ�Ϊ0
		CLR F0					;�ݼ���־λ��0
		AJMP CAS2				;
CAS16:	;CJNE R2,#15,CAS2		;�жϵ�ǰ���ȵȼ���15
		CJNE R2,#31,CAS2		;�жϵ�ǰ���ȵȼ���31
		SETB F0					;�ݼ���־λ��1
		AJMP CAS2				;
;--����--
CAS2:	JB   F0,SU				;F0Ϊ1����ת���ݼ�
		INC  R2
		INC  R6					;��������
		;CJNE R2,#15,CAS4		;��һ�����ȵȼ���15
		CJNE R2, #31,CAS4		;��һ�����ȵȼ���31
		SETB ISBI				;����
CAS4:	CJNE R6, #0AH,HOME1		;��λ������10
		MOV  R6, #0				;��λ��0
		;MOV  R5, #1			;ʮλ��1
		INC  R5					;ʮλ+1
		AJMP HOME1
SU:		DEC  R2					;�ݼ�����
		DEC  R6
		CJNE R2,#0,CAS5			;��һ�����ȵȼ���0
		SETB ISBI				;����
CAS5:	CJNE R6,#0FFH,HOME1		;��λ�Ƶ�-1
		MOV  R6,#9				;��λ��9
		;MOV  R5,#0				;ʮλ��0
		DEC  R5					;ʮλ-1
		AJMP HOME1
CAS1:	JB   ISBI,CAS3			;�жϷ������ǲ�������
		AJMP HOME1				;û�������
CAS3:	CJNE R3,#50,HOME1		;������ж��Ƿ���0.5s
		CLR  ISBI				;�Ǿ͹��Ϸ�����
HOME1:	LCALL PWM				;����
		LCALL  PLAY				;��ʾ��ǰ���ȵȼ�
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
PLAY:	JB ISTEN,TEN			;���������ʾʮλ
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
		RET

TAB:	DB 0FCH,060H,0DAH,0F2H,066H
		DB 0B6H,0BEH,0E0H,0FEH,0F6H
		
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
    mov  IE,        #00Ah
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
