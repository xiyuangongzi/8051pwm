;FileName:
;Description:
;Date:
;Designed_by:
;CPU:8051F310
;主频：24.5MHz
;R0 <- 
;R1 <- 
;R2 <- 亮度等级
;R3 <- 两秒
;R4 <- PWM计数
;R5 <- 显示十位
;R6 <- 显示个位
;R7 <-
;ISBI <- 蜂鸣器标志位
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
MAIN:   
		LCALL  Init_Device		;系统初始化
		ISBI BIT P3.1			;定义蜂鸣器标志位
		CLR  ISBI				;蜂鸣器关上
		ISTEN BIT PSW.1			;定义是否正在显示十位标志位
		CLR  ISTEN				;初始化为0
		MOV  P1,#00H			;数码管显示清零
		CLR  P0.7				;数码管位选初始化
		MOV  SP, #60H			;堆栈初始化	
		MOV  DPTR,#TAB			;显示码表
	    MOV  TMOD, #11H			;计时器都工作在方式1
		MOV  TL1, #08FH			
		MOV  TH1, #0FDH			;节拍为10ms
        SETB  P0.0      		;灭灯           
		SETB  TR1				
		SETB  ET1				
        SETB  EA   				;开T1中断
		MOV  R2, #00H			;初始亮度等级为0
		MOV  R3, #00H			;初始时间计数为0
		MOV  R5, #0				;亮度显示十位为0
		MOV  R6, #0				;亮度显示个位为0
HERE:	SJMP  HERE	            ;等待中断
		
;---------------------------------------
;定时器0中断，处理PWM定时
;---------------------------------------
INTT0:  CJNE R4,#0,L1			;亮灯剩余时间是否为0
		SETB  P0.0				;是则关灯
		CLR  TR0				;关中断
		AJMP HOME2				;退出
L1:		DEC R4					;不为0则减一
		;MOV  TL0, #0D9H			
		;MOV  TH0, #0FFH		;重新置数(10/15)ms
		MOV  TL0, #0ECH
		MOV  TH0, #0FFH			;重新置数(10/31)ms
HOME2:  RETI					;退出中断

;------------------------------------------
;定时器1中断处理：任务调度
;------------------------------------------
INTT1:
		MOV  TL1, #08FH			
		MOV  TH1, #0FDH			;节拍为10ms
		INC  R3					;时间计数+1
		;CJNE R3,#200,CAS1		;判断计时满2S
		CJNE R3,#100,CAS1		;判断计时满1S
		MOV  R3,#00H			;若满，计时清0
		CJNE R2,#0,CAS16		;判断当前亮度等级为0
		CLR F0					;递减标志位置0
		AJMP CAS2				;
CAS16:	;CJNE R2,#15,CAS2		;判断当前亮度等级满15
		CJNE R2,#31,CAS2		;判断当前亮度等级满31
		SETB F0					;递减标志位置1
		AJMP CAS2				;
;--计数--
CAS2:	JB   F0,SU				;F0为1则跳转到递减
		INC  R2
		INC  R6					;递增计数
		;CJNE R2,#15,CAS4		;下一个亮度等级是15
		CJNE R2, #31,CAS4		;下一个亮度等级是31
		SETB ISBI				;响铃
CAS4:	CJNE R6, #0AH,HOME1		;个位计数到10
		MOV  R6, #0				;个位置0
		;MOV  R5, #1			;十位置1
		INC  R5					;十位+1
		AJMP HOME1
SU:		DEC  R2					;递减计数
		DEC  R6
		CJNE R2,#0,CAS5			;下一个亮度等级是0
		SETB ISBI				;响铃
CAS5:	CJNE R6,#0FFH,HOME1		;个位计到-1
		MOV  R6,#9				;个位置9
		;MOV  R5,#0				;十位置0
		DEC  R5					;十位-1
		AJMP HOME1
CAS1:	JB   ISBI,CAS3			;判断蜂鸣器是不是在响
		AJMP HOME1				;没响就算了
CAS3:	CJNE R3,#50,HOME1		;在响就判断是否满0.5s
		CLR  ISBI				;是就关上蜂鸣器
HOME1:	LCALL PWM				;亮灯
		LCALL  PLAY				;显示当前亮度等级
		RETI

;------------------------------------------
;PWM
;------------------------------------------
PWM:	CJNE R2,#0,HOME3		;如果亮度等级为0
		CLR  TR0				;就不开中断不开灯
		RET						;退出
HOME3:	;MOV  TL0, #0D9H		;如果不为0
		;MOV  TH0, #0FFH		;定时(10/15)ms  
		MOV  TL0, #0ECH
		MOV  TH0, #0FFH			;定时(10/31)ms
		MOV  B,R2
		MOV  R4,B				;R4为亮的时间
		SETB  TR0
		SETB  ET0				;开T0中断
		CLR   P0.0				;开灯
		RET
		
;-------------------------------------------
;DISPLAY
;-------------------------------------------
PLAY:	JB ISTEN,TEN			;如果正在显示十位
		CLR P0.6				;就开始显示个位
		MOV A,R6
		MOVC A,@A+DPTR			;取个位字码
		MOV P1,A				;显示
		CPL ISTEN				;标志位取反
		RET
TEN:	SETB P0.6				;开始显示十位
		MOV A,R5				
		MOVC A,@A+DPTR			;取十位字码
		MOV P1,A				;显示
		CPL ISTEN				;标志位取反
		RET

TAB:	DB 0FCH,060H,0DAH,0F2H,066H
		DB 0B6H,0BEH,0E0H,0FEH,0F6H
		
;------------------------------------------
;系统初始化函数
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
