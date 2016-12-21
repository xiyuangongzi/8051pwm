for i in range(10):
    print('ANN'+str(i)+':   MOV  R3, #00H\n\t\tMOV  R6, #'+str(i)+'\n\t\tJNB SET10,TO20'+str(i)+'\n\t\tMOV  R2, #'+hex(10+i)+'H\n\t\tMOV  R5, #1\n\t\tCLR  SET10\n\t\tAJMP BACT5')
    print('TO20'+str(i)+':  JNB SET20,TO30'+str(i)+'\n\t\tMOV  R2, #'+hex(20+i)+'H\n\t\tMOV  R5, #2\n\t\tCLR  SET20\n\t\tAJMP BACT5')
    if i >1:
        print('TO30'+str(i)+':  JNB SET30,TO00'+str(i)+'\n\t\tCLR  SET30\n\t\tAJMP BACT5')    	
    else:
    	print('TO30'+str(i)+':  JNB SET30,TO00'+str(i)+'\n\t\tMOV  R2, #'+hex(30+i)+'H\n\t\tMOV  R5, #3\n\t\tCLR  SET30\n\t\tAJMP BACT5')

    print('TO00'+str(i)+':	MOV  R2, #00H\n\t\tMOV  R5, #0\n\t\tAJMP BACT5')