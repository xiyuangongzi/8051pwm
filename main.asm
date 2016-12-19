;FileName:
;Description:
;Date:
;Designed_by:
;CPU:8051F310
;主频：24.5MHz
;R0 <- DPH
;R1 <- DPL
;R2
;R3 <- 2S
;R4
;R5
;R6
;R7
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
;-  主函数
;-------------------------------------
        ORG   0100H
MAIN:   LCALL  Init_Device
        MOV   SP, #60H	           
        MOV   R3, #00H	
	    MOV   TMOD, #11H
        MOV   DPTR, #PWM0
        ;SETB  P3.1
		MOV  TL1, #0EEH
		MOV  TH1, #85H
        CLR  P0.0                 
		SETB  TR0  	           
        SETB  ET0
		SETB  TR1
		SETB  ET1
        SETB  EA                  
HERE:   SJMP  HERE	            

;---------------------------------------
;定时器0中断处理函数
;---------------------------------------
INTT0:  JB P0.0,ISLOW
ISHIGH: MOV  A, #00H
		MOVC  A,@A+DPTR
		MOV  TH0,A
		MOV  A,#01H
		MOVC  A,@A+DPTR
        MOV  TL0,A   
        CPL  P0.0
		AJMP  L1
ISLOW:	MOV  A,#02H
		MOVC  A,@A+DPTR
		MOV  TL0,A 
		MOV  A,#03H
		MOVC  A,@A+DPTR
        MOV  TH0,A 
        CPL  P0.0                         
L1:     RETI

;------------------------------------------
;定时器1中断处理函数
;------------------------------------------
INTT1:	MOV  TL1,#0EEH
		MOV  TH1,#85H    ;0.5S
		CJNE  R3,#03H,INCR3 ;2S
		MOV  R3,#00H
		MOV  A,#01H
		MOVC  A,@A+DPTR    ;;这里会不会冲突？？？
		CJNE  A,#0F0H,INCDP
		MOV  DPTR,#PWM0
		AJMP  BACK1
INCDP:	INC  DPTR
		INC  DPTR
		INC  DPTR
		INC  DPTR	;+4
		AJMP  BACK1
INCR3:	INC  R3
BACK1:	RETI

;------------------------------------------
;PWM
;------------------------------------------
;		DB TH0L,TL0L,TH0H,TL0H
PWM0:	DB 0FFH,0FFH,0FFH,0F0H
PWM1:	DB 0FFH,0FEH,0FFH,0F1H
PWM2:	DB 0FFH,0FDH,0FFH,0F2H
PWM3:	DB 0FFH,0FCH,0FFH,0F3H
PWM4:	DB 0FFH,0FBH,0FFH,0F4H
PWM5:	DB 0FFH,0FAH,0FFH,0F5H
PWM6:	DB 0FFH,0F9H,0FFH,0F6H
PWM7:	DB 0FFH,0F8H,0FFH,0F7H
PWM8:	DB 0FFH,0F7H,0FFH,0F8H
PWM9:	DB 0FFH,0F6H,0FFH,0F9H
PWMA:	DB 0FFH,0F5H,0FFH,0FAH
PWMB:	DB 0FFH,0F4H,0FFH,0FBH
PWMC:	DB 0FFH,0F3H,0FFH,0FCH
PWMD:	DB 0FFH,0F2H,0FFH,0FDH
PWME:	DB 0FFH,0F1H,0FFH,0FEH
PWMF:	DB 0FFH,0F0H,0FFH,0FFH





;------------------------------------------
;初始化函数
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
    mov  TMOD,      #001h
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
    mov  IE,        #086h
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
