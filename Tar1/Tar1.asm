@SP
A = M
A = A - 1
D = M
A = A - 1
A = M
D = A - D
@SP
M = M - 1
A = M - 1 
M = D
@SP
A = M - 1
D = M
@Lable0
D; JEQ
@0
D = A
@Lable1
0; JMP
(Lable0)
@0
D = A - 1
(Lable1)
@SP
A = M - 1
M = D
