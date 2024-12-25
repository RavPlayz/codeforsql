     CT_PORT  EQU       006H
      A_PORT  EQU       000H
      B_PORT  EQU       002H
      C_PORT  EQU       004H
   MY8253_CT  EQU       19H
     CLOCK_0  EQU       01H
     CLOCK_1  EQU       09H
     CLOCK_2  EQU       11H
       
        DATA  SEGMENT
         LED  DB        0CH,09H,0AH,24H,14H
        TIME  DB        02H,55H,05H,42H,07H
      TIME_2  DB        62H,60H,05H,35H,05H
         TAB  DB        3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH
          MM  DW        ?
        MM_1  DW        ?
        MM_2  DW        01H
        MM_3  DB        57
        MM_4  DB        35
          N1  DB        00
          N2  DB        10
         TRY  DB        00H
        
       DTIME  DW        50H
        DATA  ENDS
       
       
       
       
       STACK  SEGMENT   'STACK'
              DW        50 DUP(?)
         TOP  LABEL     WORD
       STACK  ENDS
       
       
       
       
        CODE  SEGMENT
              ASSUME    CS:CODE,DS:DATA,SS:STACK
      START:
              MOV       AX,DATA     ;��ʼ��
              MOV       DS,AX
              MOV       AX,STACK
              MOV       SS,AX
              MOV       SP,TOP
              MOV       AL,88H      ;д��8255������,A,B,C�ھ������ڷ�ʽ0,A,B�����
              MOV       DX,CT_PORT  ;C�ڵ���λ���,����λ����
              OUT       DX,AL
              MOV       AL,0CH      ;��ʼ����ͨ��״̬,�����ϱ�·�ڵĺ����
              MOV       DX,A_PORT
              OUT       DX,AL
              
              MOV       DX,MY8253_CT            ;8253��ʼ��
              MOV       AL,00110111B            ;������0�����ڷ�ʽ3  ʱ��Ƶ��1.8432MHz
              OUT       DX,AL
              MOV       DX,CLOCK_0
              MOV       AL,00H      ;�ͼ�����ֵ�ĵ�8λ
              OUT       DX,AL
              MOV       AL,10H      ;�ͼ�����ֵ�ĸ�8λ
              OUT       DX,AL
              JMP       BEGIN
              
   ONESECOND  MACRO
              MOV       DX,MY8253_CT
              MOV       AL,01110001B            ;������1�����ڷ�ʽ0
              OUT       DX,AL
              MOV       DX,CLOCK_1
              MOV       AL,00H      ;�ͼ�����ֵ�ĵ�8λ
              OUT       DX,AL
              MOV       AL,10H      ;�ͼ�����ֵ�ĸ�8λ
              OUT       DX,AL
              ENDM

  HALFSECOND  MACRO
              MOV       DX,MY8253_CT
              MOV       AL,01110001B            ;������1�����ڷ�ʽ0
              OUT       DX,AL
              MOV       DX,CLOCK_1
              MOV       AL,50H      ;�ͼ�����ֵ�ĵ�8λ
              OUT       DX,AL
              MOV       AL,00H      ;�ͼ�����ֵ�ĸ�8λ
              OUT       DX,AL
              ENDM

      BUFFER  MACRO
              LOCAL     AGAIN
              MOV       DX,MY8253_CT
              MOV       AL,10110001B            ;������2�����ڷ�ʽ0
              OUT       DX,AL
              MOV       DX,CLOCK_2
              MOV       AL,00H      ;�ͼ�����ֵ�ĵ�8λ
              OUT       DX,AL
              MOV       AL,10H      ;�ͼ�����ֵ�ĸ�8λ
              OUT       DX,AL
              MOV       DX,C_PORT
      AGAIN:  IN        AL,DX
              TEST      AL,20H
              JZ        AGAIN
              ENDM

       DELAY  MACRO
              LOCAL     LOOPER
              MOV       CX,DTIME
     LOOPER:  LOOP      LOOPER
              ENDM
              
      BEGIN:  XOR       SI,SI       ;SI����
              JMP       GIVE

  EMERGENCY:  INC       TRY
              MOV       DX,A_PORT
              MOV       AL,0CH
              OUT       DX,AL
        REP:  MOV       DX,C_PORT   ;ѡ�������1
              MOV       AL,00H
              OUT       DX,AL
              MOV       DX,B_PORT   ;��TAB��ѡ�ж�Ӧ�Ķ������򵹼�ʱʮλ����,�����������ʾ
              LEA       BX,TAB
              MOV       AX,MM
              PUSH      CX
              MOV       CL,04H
              SHR       AL,CL
              XLAT
              OUT       DX,AL
              POP       CX
              ;DELAY
              BUFFER
              MOV       DX,C_PORT   ;ѡ�������2
              MOV       AL,01H
              OUT       DX,AL
              MOV       DX,B_PORT   ;��TAB��ѡ�ж�Ӧ�Ķ������򵹼�ʱ��λ����,�����������ʾ
              MOV       AX,MM
              AND       AL,0FH
              XLAT
              OUT       DX,AL
              ;DELAY
              BUFFER
              MOV       DX,C_PORT   ;ѡ�������3
              MOV       AL,02H
              OUT       DX,AL
              MOV       DX,B_PORT   ;��TAB��ѡ�ж�Ӧ���ϱ����򵹼�ʱʮλ����,�����������ʾ
              LEA       BX,TAB
              MOV       AX,MM_1
              PUSH      CX
              MOV       CL,04H
              SHR       AL,CL
              XLAT
              OUT       DX,AL
              POP       CX
              ;DELAY
              BUFFER
              MOV       DX,C_PORT   ;ѡ�������4
              MOV       AL,03H
              OUT       DX,AL
              MOV       DX,B_PORT   ;��TAB��ѡ�ж�Ӧ���ϱ����򵹼�ʱ��λ����,�����������ʾ
              MOV       AX,MM_1
              AND       AL,0FH
              XLAT
              OUT       DX,AL
              ;DELAY
              BUFFER
;�����¼�
              MOV       DX,C_PORT
              IN        AL,DX
              TEST      AL,40H
              JZ        RESTORE
              JMP       EMERGENCY
    RESTORE:  SUB       TRY,00H
              JZ        REP_
              DEC       SI
              LEA       BX,LED      ;��LED����ȡ����״̬�����ϱ����������
              MOV       AX,SI
              XLAT
              MOV       DX,A_PORT
              OUT       DX,AL
              MOV       TRY,00H
              INC       SI
       REP_:  MOV       AX,MM_1     ;�ж��ϱ������ʱ��λ���Ƿ�Ϊ0,�����ȥ6
              PUSH      CX
              MOV       CL,12
              SHL       AX,CL
              POP       CX
              SUB       AH,0F0H
              JZ        SUB_6_1
              MOV       AX,MM       ;�ж϶��������ʱ��λ���Ƿ�Ϊ0,�����ȥ6
              PUSH      CX
              MOV       CL,12
              SHL       AX,CL
              POP       CX
              SUB       AH,0F0H
              JZ        SUB_6
              XOR       AX,AX

              DEC       MM_2
              JNZ       NEXT
              ONESECOND
       NEXT:  MOV       DX,C_PORT   ;����out1�ĵ�ƽ�Ƿ���
              IN        AL,DX
              TEST      AL,10H
              JNZ       DEC_1       ;���˵��ʱ�䵽
              JMP       REP         ;�������
              
      SUB_6:  XOR       AX,AX       ;���������ʱ��6����
              SUB       MM,06H
              JMP       REP
    SUB_6_1:  XOR       AX,AX       ; �ϱ������ʱ��6����
              SUB       MM_1,06H
              JMP       REP_
      DEC_1:  CMP       SI,03H      ;ǰ����״̬ͨ�����������ʱ�����ת��״̬
              JA        DE_1        ;������״̬ͨ���ϱ������ʱ�����ת��״̬
       DE_0:  DEC       MM_3        ;���������̵���˸����
              CMP       SI,02H      ;�����̣��ϱ���Ϊ�ڶ�״̬
              JZ        NS
              JMP       NORM_1
         NS:  CMP       MM_3,05H    ;�ж��Ƿ��ѵ���ʱ���5��
              JNA       CHO
              JMP       NORM_1
        CHO:  MOV       AL,MM_3     ;����ʱ5��,��������,ż����
              MOV       BL,02H
              DIV       BL
              CMP       AH,00H
              JZ        HIGH_1
      LOW_1:  MOV       DX,A_PORT   ;�ϱ���������,��������Ϩ��
              MOV       AL,08H
              OUT       DX,AL
              JMP       NORM_1
     HIGH_1:  MOV       DX,A_PORT   ;����,״̬2
              MOV       AL,09H
              OUT       DX,AL
     NORM_1:  MOV       MM_2,01H    ;����Ŷ
              DEC       MM_1
              DEC       MM
              CMP       MM,00H
              JZ        GIVE        ;ĳ״̬��ʱ���������¸�����ֵ
              JMP       REP         ;�����������
       DE_1:  DEC       MM_4        ;�ϱ������̵���˸����
              CMP       SI,04H
              JZ        EW
              JMP       NORM_2
         EW:  CMP       MM_4,05H    ;�ж��Ƿ��ѵ���ʱ���5��
              JNA       CHO_2
              JMP       NORM_2
      CHO_2:  MOV       AL,MM_4     ;����ʱ5��,��������,ż����
              MOV       BL,02H
              DIV       BL
              CMP       AH,00H
              JZ        HIGH_2
      LOW_2:  MOV       DX,A_PORT   ;������������,�ϱ�����Ϩ��
              MOV       AL,04H
              OUT       DX,AL
              JMP       NORM_2
     HIGH_2:  MOV       DX,A_PORT   ;����,״̬2
              MOV       AL,24H
              OUT       DX,AL
              JMP       NORM_2
     NORM_2:  MOV       MM_2,01H    ;����Ŷ
              DEC       MM
              DEC       MM_1
              CMP       MM_1,00H
              JZ        GIVE        ;ĳ״̬��ʱ���������¸�����ֵ
              JMP       REP         ;�����������
     GIVE_1:  XOR       SI,SI       ;һ��ѭ����������״̬��λ
              MOV       MM_3,57
              MOV       MM_4,35
       GIVE:  LEA       BX,TIME     ;��TIME����ȡ���ϱ������״̬������ʱ��
              MOV       AX,SI
              XLAT
              MOV       MM,AX
              LEA       BX,TIME_2   ;��TIME_2����ȡ�����������״̬������ʱ��
              MOV       AX,SI
              XLAT
              MOV       MM_1,AX
              LEA       BX,LED      ;��LED����ȡ����״̬�����ϱ����������
              MOV       AX,SI
              XLAT
              MOV       DX,A_PORT
              OUT       DX,AL
              INC       SI          ;SI�Լ�1,ʹ�����´ε���ʱָ����һ״̬
              MOV       AX,SI       ;ͨ��SI�ж��Ƿ�һ��ѭ������ �����ǣ����״̬��λ
              SUB       AX,06H
              JZ        GIVE_1
              JMP       REP         ;��ѭ��δ����,��ת�������ˢ�³���
         
        CODE  ENDS
              END       START
