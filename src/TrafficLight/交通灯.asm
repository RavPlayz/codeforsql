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
              MOV       AX,DATA     ;初始化
              MOV       DS,AX
              MOV       AX,STACK
              MOV       SS,AX
              MOV       SP,TOP
              MOV       AL,88H      ;写入8255控制字,A,B,C口均工作于方式0,A,B口输出
              MOV       DX,CT_PORT  ;C口低四位输出,高四位输入
              OUT       DX,AL
              MOV       AL,0CH      ;初始化交通灯状态,东西南北路口的红灯亮
              MOV       DX,A_PORT
              OUT       DX,AL
              
              MOV       DX,MY8253_CT            ;8253初始化
              MOV       AL,00110111B            ;计数器0工作在方式3  时钟频率1.8432MHz
              OUT       DX,AL
              MOV       DX,CLOCK_0
              MOV       AL,00H      ;送计数初值的低8位
              OUT       DX,AL
              MOV       AL,10H      ;送计数初值的高8位
              OUT       DX,AL
              JMP       BEGIN
              
   ONESECOND  MACRO
              MOV       DX,MY8253_CT
              MOV       AL,01110001B            ;计数器1工作在方式0
              OUT       DX,AL
              MOV       DX,CLOCK_1
              MOV       AL,00H      ;送计数初值的低8位
              OUT       DX,AL
              MOV       AL,10H      ;送计数初值的高8位
              OUT       DX,AL
              ENDM

  HALFSECOND  MACRO
              MOV       DX,MY8253_CT
              MOV       AL,01110001B            ;计数器1工作在方式0
              OUT       DX,AL
              MOV       DX,CLOCK_1
              MOV       AL,50H      ;送计数初值的低8位
              OUT       DX,AL
              MOV       AL,00H      ;送计数初值的高8位
              OUT       DX,AL
              ENDM

      BUFFER  MACRO
              LOCAL     AGAIN
              MOV       DX,MY8253_CT
              MOV       AL,10110001B            ;计数器2工作在方式0
              OUT       DX,AL
              MOV       DX,CLOCK_2
              MOV       AL,00H      ;送计数初值的低8位
              OUT       DX,AL
              MOV       AL,10H      ;送计数初值的高8位
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
              
      BEGIN:  XOR       SI,SI       ;SI清零
              JMP       GIVE

  EMERGENCY:  INC       TRY
              MOV       DX,A_PORT
              MOV       AL,0CH
              OUT       DX,AL
        REP:  MOV       DX,C_PORT   ;选中数码管1
              MOV       AL,00H
              OUT       DX,AL
              MOV       DX,B_PORT   ;从TAB中选中对应的东西方向倒计时十位数字,予以数码管显示
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
              MOV       DX,C_PORT   ;选中数码管2
              MOV       AL,01H
              OUT       DX,AL
              MOV       DX,B_PORT   ;从TAB中选中对应的东西方向倒计时个位数字,予以数码管显示
              MOV       AX,MM
              AND       AL,0FH
              XLAT
              OUT       DX,AL
              ;DELAY
              BUFFER
              MOV       DX,C_PORT   ;选中数码管3
              MOV       AL,02H
              OUT       DX,AL
              MOV       DX,B_PORT   ;从TAB中选中对应的南北方向倒计时十位数字,予以数码管显示
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
              MOV       DX,C_PORT   ;选中数码管4
              MOV       AL,03H
              OUT       DX,AL
              MOV       DX,B_PORT   ;从TAB中选中对应的南北方向倒计时个位数字,予以数码管显示
              MOV       AX,MM_1
              AND       AL,0FH
              XLAT
              OUT       DX,AL
              ;DELAY
              BUFFER
;意外事件
              MOV       DX,C_PORT
              IN        AL,DX
              TEST      AL,40H
              JZ        RESTORE
              JMP       EMERGENCY
    RESTORE:  SUB       TRY,00H
              JZ        REP_
              DEC       SI
              LEA       BX,LED      ;从LED表中取出各状态东西南北灯亮的情况
              MOV       AX,SI
              XLAT
              MOV       DX,A_PORT
              OUT       DX,AL
              MOV       TRY,00H
              INC       SI
       REP_:  MOV       AX,MM_1     ;判断南北方向计时个位数是否为0,是则减去6
              PUSH      CX
              MOV       CL,12
              SHL       AX,CL
              POP       CX
              SUB       AH,0F0H
              JZ        SUB_6_1
              MOV       AX,MM       ;判断东西方向计时个位数是否为0,是则减去6
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
       NEXT:  MOV       DX,C_PORT   ;测试out1的电平是否变高
              IN        AL,DX
              TEST      AL,10H
              JNZ       DEC_1       ;变高说明时间到
              JMP       REP         ;否则断续
              
      SUB_6:  XOR       AX,AX       ;东西方向计时减6程序
              SUB       MM,06H
              JMP       REP
    SUB_6_1:  XOR       AX,AX       ; 南北方向计时减6程序
              SUB       MM_1,06H
              JMP       REP_
      DEC_1:  CMP       SI,03H      ;前三个状态通过东西方向的时间控制转换状态
              JA        DE_1        ;后两个状态通过南北方向的时间控制转换状态
       DE_0:  DEC       MM_3        ;东西方向绿灯闪烁程序
              CMP       SI,02H      ;东西绿，南北红为第二状态
              JZ        NS
              JMP       NORM_1
         NS:  CMP       MM_3,05H    ;判定是否已到计时最后5秒
              JNA       CHO
              JMP       NORM_1
        CHO:  MOV       AL,MM_3     ;倒计时5秒,奇数码灭,偶数亮
              MOV       BL,02H
              DIV       BL
              CMP       AH,00H
              JZ        HIGH_1
      LOW_1:  MOV       DX,A_PORT   ;南北方向红灯亮,东西方向熄灭
              MOV       AL,08H
              OUT       DX,AL
              JMP       NORM_1
     HIGH_1:  MOV       DX,A_PORT   ;正常,状态2
              MOV       AL,09H
              OUT       DX,AL
     NORM_1:  MOV       MM_2,01H    ;这里哦
              DEC       MM_1
              DEC       MM
              CMP       MM,00H
              JZ        GIVE        ;某状态计时结束，重新赋计数值
              JMP       REP         ;否则继续计数
       DE_1:  DEC       MM_4        ;南北方向绿灯闪烁程序
              CMP       SI,04H
              JZ        EW
              JMP       NORM_2
         EW:  CMP       MM_4,05H    ;判定是否已到计时最后5秒
              JNA       CHO_2
              JMP       NORM_2
      CHO_2:  MOV       AL,MM_4     ;倒计时5秒,奇数码灭,偶数亮
              MOV       BL,02H
              DIV       BL
              CMP       AH,00H
              JZ        HIGH_2
      LOW_2:  MOV       DX,A_PORT   ;东西方向红灯亮,南北方向熄灭
              MOV       AL,04H
              OUT       DX,AL
              JMP       NORM_2
     HIGH_2:  MOV       DX,A_PORT   ;正常,状态2
              MOV       AL,24H
              OUT       DX,AL
              JMP       NORM_2
     NORM_2:  MOV       MM_2,01H    ;这里哦
              DEC       MM
              DEC       MM_1
              CMP       MM_1,00H
              JZ        GIVE        ;某状态计时结束，重新赋计数值
              JMP       REP         ;否则继续计数
     GIVE_1:  XOR       SI,SI       ;一次循环结束，各状态复位
              MOV       MM_3,57
              MOV       MM_4,35
       GIVE:  LEA       BX,TIME     ;从TIME表中取出南北方向各状态灯亮的时间
              MOV       AX,SI
              XLAT
              MOV       MM,AX
              LEA       BX,TIME_2   ;从TIME_2表中取出东西方向各状态灯亮的时间
              MOV       AX,SI
              XLAT
              MOV       MM_1,AX
              LEA       BX,LED      ;从LED表中取出各状态东西南北灯亮的情况
              MOV       AX,SI
              XLAT
              MOV       DX,A_PORT
              OUT       DX,AL
              INC       SI          ;SI自加1,使其在下次调用时指向下一状态
              MOV       AX,SI       ;通过SI判断是否一次循环结束 ，若是，则各状态复位
              SUB       AX,06H
              JZ        GIVE_1
              JMP       REP         ;若循环未结束,则转至数码管刷新程序
         
        CODE  ENDS
              END       START
