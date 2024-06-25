(InputB.inputB.A)
@0
D = A
(Lable0)
@13
M = D
@Lable0
D; JNE
@0
D = A
@SP
A = M
M = D
@SP
M = M + 1
@13
D = M
D = D - 1
@3
D = A
@SP
A = M
M = D
@SP
M = M + 1
@2
D = A
@SP
A = M
M = D
@SP
M = M + 1
@SP
A = M
A = A - 1
D = M
A = A - 1
A = M
D = D + A
@SP
M = M - 1
A = M - 1 
M = D
@LCL
D = M
@14
M = D
@5
A = D - A
D = M
@15
M = D
@ARG
D = A
@13
M = D
@SP
A = M - 1
D = M
@13
A = M
M = D
@SP
M = M - 1
@ARG
D = M
D = D + 1
@SP
M = D
@14
D = M
@1
A = D - A
D = M
@THAT
M = D
@14
D = M
@2
A = D - A
D = M
@THIS
M = D
@14
D = M
@3
A = D - A
D = M
@ARG
M = D
@14
D = M
@4
A = D - A
D = M
@LCL
M = D
@15
A = M
0;JMP
@Lable1
D = A
@SP
A = M
M = D
@SP
M = M + 1
@LCL
A = M
D = A
@SP
A = M
M = D
@SP
M = M + 1
@ARG
A = M
D = A
@SP
A = M
M = D
@SP
M = M + 1
@THIS
A = M
D = A
@SP
A = M
M = D
@SP
M = M + 1
@THAT
A = M
D = A
@SP
A = M
M = D
@SP
M = M + 1
@0
D = A
@5
D = D + A
@SP
A = M
D = A - D
@ARG
M = D
@SP
D = M
@LCL
M = D
@InputC.inputB.A
0; JEQ
(Lable1)
@6
D = A
@13
M = D
@SP
A = M - 1
D = M
@13
A = M
M = D
@SP
M = M - 1
