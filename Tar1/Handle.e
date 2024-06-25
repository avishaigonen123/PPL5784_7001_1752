include std/io.e
include ./tar1.e
include ./enums.e
include std/convert.e
include std/sequence.e

integer counter = -1

public procedure build()
	/*printToFile(
		{
			"@256",
			"D = A",
			"@SP", -- 
			"M = D"

		} & handleCall({"call", "Sys.init", "0"}, "bla")
		)*/
end procedure

-- pop the value of D to the top of the stack
function push_D()
	return {
		"@" & labels[SP], 	-- A = SP
		"A = M", 			-- A = Ram[SP] -> a = *sp
		"M = D", 			-- Ram[SP] = x
				
		"@" & labels[SP], 	-- A = SP
		"M = M + 1" 		-- RAM[SP] = Ram[SP] + 1
	}
end function

-- push the value in A to the top of the stack
function push_A()
	return {
		"D = A" 			-- D = x
		} &
		push_D()
end function

-- pop the value from the stack to RAM[D]
function pop_D()
	return {
		"@" & labels[R1], 	-- 
		"M = D", 			-- R1 = D
				
		"@" & labels[SP], 	-- A = SP
		"A = M - 1", 		-- A = Ram[SP] - 1
		"D = M", 			-- D = Ram[Ram[SP] - 1]
				
		"@" & labels[R1], 	-- 
		"A = M", 			-- A = R1
				
		"M = D",             -- Ram[x + Ram[LCL]] = Ram[Ram[SP] - 1]

		"@" & labels[SP], 	-- A = SP
		"M = M - 1" 		-- RAM[SP] = Ram[SP] - 1
	}
end function


public function handlePush(sequence command, sequence name)

	sequence asm = {}
	switch command[2] do
		case "local", "that", "this", "argument" then
			asm = {
					"// " & join(command, " "),
					"@" & command[3], 		-- A = x
					"D = A", 				-- D = x
					"@" & labels[mapCommendToLabels(command[2])], 		-- A = LCL
					"A = M", 				-- A = Ram[LCL] -> a = *lcl
					"A = A + D", 			-- A = x + Ram[LCL]
					"D = M" 				-- D = Ram[x + Ram[LCL]]
				} & 
					push_D()

		case "temp" then
			asm = {
					"// " & join(command, " "),
					"@" & labels[TEMP0 + to_number(command[3])], 	-- A = TEMPx
					"D = M" 				-- D = Ram[x + TEMP]
				} & 
					push_D()

		case "static" then
			asm = {
					"// " & join(command, " "),
					"@" & name & "." & command[3], -- "filename.x"
					"D = M" 			-- D = Ram[filename.x]
				} & 
					push_D()

		case "pointer" then
			asm = {
					"// " & join(command, " "),
					"@" & labels[THIS + to_number(command[3])], 	-- A = this | that
					"D = M" 				-- D = Ram[this | that]
				} & 
					push_D()

		case "constant" then
			asm = {
					"// " & join(command, " "),
					"@" & command[3] 	-- A = x
				} &
					push_A()

		case else

	end switch
	return asm
	
end function

public function handlePop(sequence command, sequence name)
	sequence asm = {}
	switch command[2] do
		case "local", "that", "this", "argument" then
			asm = {
					"// " & join(command, " "),
					"@" & command[3],   -- A = x
					"D = A",            -- D = x
					"@" & labels[mapCommendToLabels(command[2])], 	-- A = LCL
					"A = M", 			-- A = Ram[LCL]
					"D = A + D"			-- D = x + Ram[LCL]
				} & 
					pop_D()
                
		case "temp" then
			asm = {
				"// " & join(command, " "),
				"@" & labels[TEMP0 + to_number(command[3])], 	-- A = TEMPx
				"D = A"   			-- TEMPx
				} & 
				pop_D()
				
		case "static" then
			asm = {
				"// " & join(command, " "),
				"@" & name & "." & command[3], -- "filename.x"
				"D = A" 			-- D = filename.x
				} & 
				pop_D()
				
		case "pointer" then
			asm = {
				"// " & join(command, " "),
				"@" & labels[THIS + to_number(command[3])], 
									-- A = THIS if 0, THAT if 1
				"D = A"				-- D = A
				} & 
				pop_D()
				
		case "constant" then
			printf(STDERR ,"ERROR: why do you think this will work!?!\n")
		case else

	end switch
	return asm

end function


public function handleAdd(sequence command)
	return {
		"@" & labels[SP], 			-- A = SP
		"A = M", 					-- A = Ram[SP]
		"A = A - 1",
		"D = M", 					-- D = Ram[Ram[SP] - 1], arg1
        "A = A - 1",
		"A = M", 					-- A = Ram[Ram[SP] - 2], arg2
		"D = D + A", 				-- D = arg1 + arg2
		"@" & labels[SP], 			-- A = SP
		"M = M - 1", 				-- Ram[SP] = Ram[SP] - 1
		"A = M - 1 ",				-- A = Ram[SP] - 1
		"M = D" 					-- Ram[Ram[SP] - 1] = arg1 + arg2
		}
end function

public function handleSub(sequence command)
	return {
		"@" & labels[SP], 			-- A = SP
		"A = M", 					-- A = Ram[SP]
		"A = A - 1",
		"D = M", 					-- D = Ram[Ram[SP] - 1], arg1
        "A = A - 1",
		"A = M", 					-- A = Ram[Ram[SP] - 2], arg2
		"D = A - D", 				-- D = arg2 - arg1
		"@" & labels[SP], 			-- A = SP
		"M = M - 1", 				-- Ram[SP] = Ram[SP] - 1
		"A = M - 1 ",				-- A = Ram[SP] - 1
		"M = D" 					-- Ram[Ram[SP] - 1] = arg1 - arg2
		}
end function

public function handleEq(sequence command)
	sequence IS_EQUAL = newLable()
	sequence END = newLable()
	
	return 	handleSub({})
		&{
		"@" & labels[SP], 			-- A = SP
		"A = M - 1", 				-- A = Ram[SP] - 1
		"D = M",					-- A = Ram[Ram[SP] - 1]

		"@" & IS_EQUAL,				-- load label
		"D; JEQ",                   -- IF D=0 GOTO IS_EQUAL
		"@0",						-- 
		"D = A",					-- D = 0
		"@" & END,
		"0; JMP", 					-- JMP TO end
		"(" & IS_EQUAL & ")",
		"@0",
		"D = A - 1",				-- is TRUE
		"(" & END & ")",					-- D = 0 | -1

		"@" & labels[SP], 			-- A = SP
		"A = M - 1", 				-- A = Ram[SP] - 1
		"M = D" 					-- Ram[Ram[SP] - 1] = D
		
		}
end function

public function handleGt(sequence command)
	sequence IS_BIGGER = newLable()
	sequence END = newLable()
	return	handleSub({})
		&{
		"@" & labels[SP], 			-- A = SP
		"A = M - 1", 				-- A = Ram[SP] - 1
		"D = M",					-- A = Ram[Ram[SP] - 1]

		"@" & IS_BIGGER,				-- load label
		"D; JGT",                   -- IF D=0 GOTO IS_BIGGER
		"@0",						-- 
		"D = A",					-- D = 0
		"@" & END,
		"0; JMP", 					-- JMP TO end
		"(" & IS_BIGGER & ")",
		"@0",
		"D = A - 1",				-- is TRUE
		"(" & END & ")",					-- D = 0 | -1

		"@" & labels[SP], 			-- A = SP
		"A = M - 1", 				-- A = Ram[SP] - 1
		"M = D" 					-- Ram[Ram[SP] - 1] = D
		
		}
end function

public function handleLt(sequence command)
	sequence IS_SMALLER = newLable()
	sequence END = newLable()
	return 	handleSub({})
		&{
		"@" & labels[SP], 			-- A = SP
		"A = M - 1", 				-- A = Ram[SP] - 1
		"D = M",					-- A = Ram[Ram[SP] - 1]

		"@" & IS_SMALLER,				-- load label
		"D; JLT",                   -- IF D=0 GOTO IS_SMALLER
		"@0",						-- 
		"D = A",					-- D = 0
		"@" & END,
		"0; JMP", 					-- JMP TO end
		"(" & IS_SMALLER & ")",
		"@0",						
		"D = A - 1",				-- is TRUE
		"(" & END & ")",					-- D = 0 | -1

		"@" & labels[SP], 			-- A = SP
		"A = M - 1", 				-- A = Ram[SP] - 1
		"M = D" 					-- Ram[Ram[SP] - 1] = D
		
		}
end function

public function handleAnd(sequence command)
	return {
		"@" & labels[SP], 			-- A = SP
		"A = M", 					-- A = Ram[SP]
		"A = A - 1",
		"D = M", 					-- D = Ram[Ram[SP] - 1], arg1
        "A = A - 1",
		"A = M", 					-- A = Ram[Ram[SP] - 2], arg2
		"D = D & A", 				-- D = arg1 & arg2
		"@" & labels[SP], 			-- A = SP
		"M = M - 1", 				-- Ram[SP] = Ram[SP] - 1
		"A = M - 1 ",				-- A = Ram[SP] - 1
		"M = D" 					-- Ram[Ram[SP] - 1] = arg1 * arg2
		}
end function

public function handleOr(sequence command)
	return {
		"@" & labels[SP], 			-- A = SP
		"A = M", 					-- A = Ram[SP]
		"A = A - 1",
		"D = M", 					-- D = Ram[Ram[SP] - 1], arg1
        "A = A - 1",
		"A = M", 					-- A = Ram[Ram[SP] - 2], arg2
		"D = D | A", 				-- D = arg1 | arg2
		"@" & labels[SP], 			-- A = SP
		"M = M - 1", 				-- Ram[SP] = Ram[SP] - 1
		"A = M - 1 ",				-- A = Ram[SP] - 1
		"M = D" 					-- Ram[Ram[SP] - 1] = arg1 | arg2
		}
end function

public function handleNot(sequence command)
	return {
		"@" & labels[SP], 			-- A = SP
		"A = M - 1",				-- A = Ram[SP] - 1
		"M = !M" 					-- Ram[Ram[SP] - 1] = !Ram[Ram[SP] - 1]
		}
end function

public function handleNeg(sequence command)
	return {
		"@" & labels[SP], 			-- A = SP
		"A = M - 1",				-- A = Ram[SP] - 1
		"M = -M" 					-- Ram[Ram[SP] - 1] = -Ram[Ram[SP] - 1]
		}
end function

public function handleLabel(sequence command, sequence name)
	return {
		"(" & command[2] & ")"
	}
end function

public function handleGoto(sequence command, sequence name)
	return {
		"// " & join(command, " "),
 		"@" & command[2],
		"0; JEQ" 					-- jmp to A
	}
end function

public function handleIfGoto(sequence command, sequence name)
	return {
		"// " & join(command, " "),
		"@SP",  			 
		"M = M - 1", 				-- Ram[SP] = Ram[SP] - 1
		"A = M", 					-- A = Ram[SP] - 1
		"D = M",            		-- D = Ram[Ram[SP] - 1]
 		"@" & command[2],
		"D; JNE" 					-- jmp to C if D!=0 
	}
end function

public function handleCall(sequence command, sequence name)
	sequence RETURN_ADDRESS =  newLable()
	return {
		"// " & join(command, " "),
-- push return-address
			"@" & RETURN_ADDRESS 
		}& 
			push_A()
		&{
-- push LCL
			"@LCL",
			"A = M"
		}& 
			push_A()
		&{
-- puch ARG
			"@ARG",
			"A = M"
		}& 
			push_A()
		&{
-- push THIS
			"@THIS",
			"A = M"
		}& 
			push_A()
		&{
-- push THAT
			"@THAT",
			"A = M"
		}& 
			push_A()
		&{
-- ARG=SP-n-5
			"@" & command[3], 
			"D = A", 				-- D = n
			"@5",					-- A = 5
			"D = D + A",            -- D = n + 5
			"@SP",
			"A = M",				-- A = Ram[SP]
			"D = A - D",            -- D = Ram[SP] - (n + 5)
			"@ARG", 
			"M = D",				-- Ram[ARG] = Ram[SP] - (n + 5)
-- LCL=SP
			"@SP", 
			"D = M", 				-- D = Ram[SP]
			"@LCL",					
			"M = D"	            	-- Ram[LCL] = Ram[SP]
		}& 
-- goto f
			handleGoto(command, name)		
		&{
-- (return-address)
			"(" & RETURN_ADDRESS & ")"
		}
end function

public function handleFunction(sequence command, sequence name)
	sequence LOOP =  newLable()
	sequence AFTER =  newLable()
    return {		
		"// " & join(command, " "),
			"(" & command[2] & ")",
			"@" & command[3],
			"D = A",
-- (LOOP)
            "(" & LOOP & ")",						-- repeat k times
			"@" & labels[R1], 					-- 
			"M = D",							-- R1 = D
			"@" & AFTER, 							-- if D isn't zero, repeat.
			"D; JEQ" 				
        }& 
-- PUSH 0
          	handlePush({"push", "constant", "0"}, name)
		&{
-- repeat k times
			"@" & labels[R1], 	-- 
			"D = M", 			-- A = R1"	
			"D = D - 1",
			"@" & LOOP, 							-- if D isn't zero, repeat.
			"0; JMP", 
			"(" & AFTER & ")"						-- after loop
		}
        
end function


public function handleReturn(sequence command, sequence name)
	return {
			"// " & join(command, " "),
-- FRAME=LCL									-- R2 will be FRAME
			"@LCL", 							
			"D = M", 							-- D = Ram[LCL]
			"@" & labels[R2], 					-- 
			"M = D", 							-- FRAME = D

-- RET=*(FRAME-5)								-- R3 will be RET
			"@5",								
			"A = D - A",						-- A = FRAME - 5
			"D = M",							-- D = *(FRAME - 5)
			"@" & labels[R3], 					-- 
			"M = D",							-- RET = D
			
-- *ARG=POP()
            "@ARG",
			"D = M"                            -- D = ARG
		}&
        	pop_D()
		&{
			
-- SP=ARG+1
			"@ARG", 
			"D = M", 							-- D = Ram[ARG]
			"D = D + 1",
			"@SP",					
			"M = D",	            			-- Ram[SP] = Ram[ARG] + 1
			
-- THAT=*(FRAME-1)
			"@" & labels[R2], 					-- 
			"D = M", 							-- D = FRAME
		
			"@1",								
			"A = D - A",						-- A = FRAME - 1
			"D = M",							-- D = *(FRAME - 1)
			"@THAT",
			"M = D",							-- THAT=D
				
-- THIS=*(FRAME-2)	
			"@" & labels[R2], 					-- 
			"D = M", 							-- D = FRAME

			"@2",								
			"A = D - A",						-- A = FRAME - 2
			"D = M",							-- D = *(FRAME - 2)
			"@THIS",
			"M = D",							-- THIS=D
-- ARG=*(FRAME-3)
			"@" & labels[R2], 					-- 
			"D = M", 							-- D = FRAME

			"@3",								
			"A = D - A",						-- A = FRAME - 3
			"D = M",							-- D = *(FRAME - 3)
			"@ARG",
			"M = D",							-- ARG=D
-- LCL=*(FRAME-4)	
			"@" & labels[R2], 					-- 
			"D = M", 							-- D = FRAME
		
			"@4",								
			"A = D - A",						-- A = FRAME - 4
			"D = M",							-- D = *(FRAME - 4)
			"@LCL",
			"M = D",							-- LCL=D
-- goto RET
			"@" & labels[R3], 					-- 
			"A = M",							-- A = RET
			"0;JMP"								-- goto RET
		}						
end function

public procedure printToFile(sequence asmCommands)
	for i = 1 to length(asmCommands) do
		printf(fd_output, asmCommands[i] & "\n")
	end for
end procedure

function newLable()
	counter = counter + 1
	return "Lable" & to_string(counter)
end function

/*
implementing all the command functions
*/