.MODEL SMALL
.STACK 100h
.DATA
    inputBuffer DB 16 , 0 , 14 DUP(?)
    outStringInput DB 0AH,0DH,"Enter a Number:(B for binary, H for hex, D for decimal): ",0AH,0DH,'$'
    outStringError DB 0AH,0DH,"Invalid Input. Please try again.",0AH,0DH,'$'
    outStringChoose DB 0AH,0DH,"Choose output format: B for binary, H for hex, D for decimal:",0AH,0DH,' $'
    decimalResult DB 6 DUP(?), '$' 
    hexResult DB 6 DUP(?), '$' 
    binResult DB 17 DUP(?),'$'  
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV AH, 09H
    LEA DX, outStringInput
    INT 21H
   
    CALL GETINPUT
   
    MOV CL, [inputBuffer + 1]
    LEA SI, [inputBuffer + 2]
    MOV CX, 0
    MOV CL, [inputBuffer + 1] 
    ADD SI, CX               
    DEC SI                
    MOV AL, [SI]           
    CMP AL, 'B'
    CALL ConvertBinaryToDecimal 
    CMP AL, 'H'
    JE ConvertHexToDecimal    
    CMP AL, 'D'
    JE ConvertDecimalToDecimal
    JMP ERRORINPUT      
ConvertBinaryToDecimal:
    XOR CX, CX
    MOV CL, [inputBuffer + 1] 
    DEC CL                   
    JZ  ERRORINPUT            
    LEA SI, [inputBuffer + 2] 
    MOV BX, 0                 
ConvertLoop:
    CMP CL, 0
    JZ ChooseOutputFormat     
    MOV AL, [SI]              
    CMP AL, '0'
    JB ERRORINPUT             
    CMP AL, '1'
    JA ERRORINPUT           
    SUB AL, '0'              
    MOV AH, 0
    SHL BX, 1                
    OR BX, AX                 
    INC SI                    
    DEC CL                    
    JMP ConvertLoop           
ConvertHexToDecimal:
    XOR CX, CX
    XOR BX, BX
    XOR DX, DX
    XOR AX, AX
    MOV CX, 0
    MOV CL, [inputBuffer + 1] 
    DEC CX                 
    JZ  ERRORINPUT            
    LEA SI, [inputBuffer + 2]
    MOV DH, 16
HexConvertLoop:
    CMP CX, 1
    JZ HexLastLoop
    MOV AL, [SI]             
    CMP AL, '0'
    JB ERRORINPUT            
    CMP AL, '9'
    JBE hexnumToDecimal      
    CMP AL, 'A'
    JB ERRORINPUT            
    CMP AL, 'F'
    JBE hexCharToDecimal      
hexnumToDecimal:
    SUB AL, '0'               
    JMP DECStore
hexCharToDecimal:
    SUB AL, 'A' - 10          
DECStore:
    MOV AH, 0
    DEC CX
    PUSH CX
MULLOOP:      
    MUL DH
    DEC CX
    CMP CX, 0
    JNE MULLOOP 
    POP CX
    ADD BX, AX
    INC SI
    JMP HexConvertLoop      
HexLastLoop:
    MOV AL, [SI]            
    CMP AL, '0'
    JB ERRORINPUT
    CMP AL, '9'
    jbe hexlastnumToDecimal
    CMP AL, 'A'
    JB ERRORINPUT
    CMP AL, 'F'
    JBE hexlastCharToDecimal
hexlastnumToDecimal:
    SUB AL, '0'
    JMP hexlastStore
hexlastCharToDecimal:
    SUB AL, 'A' - 10
hexlastStore:
    MOV AH, 0
    MOV AH, 0
    ADD BX, AX
    JMP ChooseOutputFormat
ConvertDecimalToDecimal:
    XOR CX, CX
    XOR BX, BX
    XOR DX, DX
    XOR AX, AX
    MOV CX, 0
    MOV CL, [inputBuffer + 1] 
    DEC CL                    
    JZ  ERRORINPUT            
    LEA SI, [inputBuffer + 2]
    MOV AX, 0                 
    MOV DH, 10                
DecimalConvertLoop:
    CMP CX, 1
    JZ Declastadd     
    MOV AL, [SI]              
    SUB AL, '0'   
    MOV AH, 0
    DEC CX
    PUSH CX
MULLOOPDEC:      
    MUL DH
    DEC CX
    CMP CX, 0
    JNE MULLOOPDEC
    POP CX
    ADD BX, AX
    INC SI
    JMP DecimalConvertLoop    
Declastadd:
    MOV AL, [SI]            
    SUB AL, '0'             
    MOV AH, 0
    ADD BX, AX
    JMP ChooseOutputFormat
ChooseOutputFormat:
    LEA DX, outStringChoose
    MOV AH, 09H
    INT 21H
    CALL GETINPUT
    MOV CL, [inputBuffer + 1] 
    LEA SI, [inputBuffer + 2] 
    ADD SI, CX               
    DEC SI                   
    MOV AL, [SI]             
    CMP AL, 'B'
    JE PrintBinary
    CMP AL, 'H'
    JE PrintHex
    CMP AL, 'D'
    JE PrintDecimal	
    JMP ERRORINPUT         
PrintBinary:
    MOV CX, BX
    MOV AX,CX
    MOV DI, OFFSET binResult + 16
    MOV BX, 2                    
BinLoop:
    XOR DX, DX                 
    DIV BX                       
    ADD DL, '0'                   
    DEC DI
    MOV [DI], DL                 
    CMP AX, 0
    JNE BinLoop                  
    LEA DX, [DI]                 
    MOV AH, 09H                  
    INT 21H
    JMP ENDALL                  
PrintHex:
    MOV CX, BX
    MOV AX,CX
    MOV DI, OFFSET hexResult + 5 
    MOV BX, 16                  
HexLoop:
    XOR DX, DX                  
    DIV BX                       
    ADD DL, '0'                 
    CMP DL, '9'
    JBE HexStore
    ADD DL, 'A' - '9' - 1
HexStore:
    DEC DI
    MOV [DI], DL                
    CMP AX, 0
    JNE HexLoop                 
    LEA DX, [DI]
    MOV AH, 09H
    INT 21H
    JMP ENDALL
PrintDecimal:
    MOV CX,BX 
    MOV AX,CX
    MOV DI, OFFSET decimalResult + 5 
    MOV BX, 10                      
DecimalPrintLoop:
    XOR DX, DX                      
    DIV BX                           
    ADD DL, '0'                     
    DEC DI
    MOV [DI], DL                    
    CMP AX, 0
    JNE DecimalPrintLoop            
    LEA DX, [DI]
    MOV AH, 09H
    INT 21H
    CALL ENDALL
ERRORINPUT:
    LEA DX, outStringError
    MOV AH, 09H
    INT 21H
    JMP START
GETINPUT PROC 
    LEA DX, inputBuffer
    MOV AH, 0AH
    INT 21H
    RET
GETINPUT ENDP
ENDALL PROC 
    MOV AH, 4CH
    INT 21H
ENDALL ENDP
END START