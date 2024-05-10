include std/io.e
include ./tar1.e
include ./enums.e
include std/convert.e

integer counter = 0

public procedure build()
	printToFile({
		-- intialize the SP to address 256 
				"@" & address[SP], 		-- A = 256
				"D = A", 				-- D = 256
				"@" & labels[SP], 		-- A = label[SP]
				"M = D", 				-- Ram[SP] = address[SP]
		-- intialize the LCL to addrss 
				"@" & address[LCL], 	-- A = ...
				"D = A", 				-- D = 256
				"@" & labels[LCL], 		-- A = label[LCL]
				"M = D", 				-- Ram[LCL] = address[LCL]
		-- intialize the ARG
				"@" & address[ARG], 	-- A = ...
				"D = A", -- D = 256
				"@" & labels[ARG], 		-- A = label[ARG]
				"M = D", 				-- Ram[ARG] = address[ARG]
		-- intialize the this
				"@" & address[THIS], 	-- A = ...
				"D = A", -- D = A
				"@" & labels[THIS], 	-- A = label[THIS]
				"M = D", 				-- Ram[THIS] = address[THIS]
		-- intialize the that
				"@" & address[THAT], 	-- A = ...
				"D = A", -- D = A
				"@" & labels[THAT], 	-- A = label[THAT]
				"M = D" 				-- Ram[THAT] = address[THAT]
				})
end procedure

public procedure handlePush(sequence command, sequence name)
	switch command[2] do
		case "local", "that", "this", "argument" then
			printToFile({
				"@" & command[3], 		-- A = x
				"D = A", 				-- D = x
				"@" & labels[mapCommendToLabels(command[2])], 		-- A = LCL
				"A = M", 				-- A = Ram[LCL] -> a = *lcl
				"A = A + D", 			-- A = x + Ram[LCL]
				"D = M", 				-- D = Ram[x + Ram[LCL]]
				"@" & labels[SP], 		-- A = SP
				"A = M", 				-- A = Ram[SP] -> a = *sp
				"M = D", 				-- RAM[SP] = Ram[x + Ram[LCL]]
				
				"@" & labels[SP], 		-- A = SP
				"M = M + 1" 			-- RAM[SP] = Ram[SP] + 1
				})
		case "temp" then
			printToFile({
				"@" & command[3], 		-- A = x
				"D = A", 				-- D = x
				"@" & labels[TEMP], 	-- A = TEMP
				"A = A + D", 			-- A = x + TEMP
				"D = M", 				-- D = Ram[x + TEMP]
				"@" & labels[SP], 		-- A = SP
				"A = M", 				-- A = Ram[SP] -> a = *sp
				"M = D", 				-- RAM[SP] = Ram[x + Ram[TEMP]]
				
				"@" & labels[SP], 		-- A = SP
				"M = M + 1" 			-- RAM[SP] = Ram[SP] + 1
				})
		case "static" then
			printToFile({
				"@" & command[3], 		-- A = x
				"D = A", 				-- D = x
				"@" & labels[TEMP], 	-- A = TEMP
				"A = A + D", 			-- A = x + TEMP
				"D = M", 				-- D = Ram[x + TEMP]
				"@" & labels[SP], 		-- A = SP
				"A = M", 				-- A = Ram[SP] -> a = *sp
				"M = D", 				-- RAM[SP] = Ram[x + Ram[TEMP]]
				
				"@" & labels[SP], 		-- A = SP
				"M = M + 1" 			-- RAM[SP] = Ram[SP] + 1
				})
		case "pointer" then
			printToFile({
				"@" & labels[THIS + to_number(command[3])], 	-- A = this | that
				"D = M", 				-- D = Ram[this | that]
				"@" & labels[SP], 		-- A = SP
				"A = M", 				-- A = Ram[SP] -> a = *sp
				"M = D", 				-- RAM[SP] = Ram[x + Ram[TEMP]]
				
				"@" & labels[SP], 		-- A = SP
				"M = M + 1" 			-- RAM[SP] = Ram[SP] + 1
				})
		case "constant" then
			printToFile({
				"@" & command[3], 	-- A = x
				"D = A", 			-- D = x
				"@" & labels[SP], 	-- A = SP
				"A = M", 			-- A = Ram[SP] -> a = *sp
				"M = D", 			-- Ram[SP] = x
				
				"@" & labels[SP], 	-- A = SP
				"M = M + 1" 		-- RAM[SP] = Ram[SP] + 1
				})
		case else

	end switch
	
end procedure

public procedure handlePop(sequence command, sequence name)
	switch command[2] do
		case "local", "that", "this", "argument" then
			printToFile({
				"@" & command[3],   -- A = x
				"D = A",            -- D = x
				"@" & labels[mapCommendToLabels(command[2])], 	-- A = LCL
				"A = M", 			-- A = Ram[LCL]
				"D = A + D",		-- D = x + Ram[LCL]

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
				})
		case "temp" then
			printToFile({
				"@" & command[3],   -- A = x
				"D = A",            -- D = x
				"@" & labels[TEMP], -- A = TEMP
				"D = A + D",		-- D = x + TEMP

				"@" & labels[R1], 	-- 
				"M = D", 			-- R1 = D
				
				"@" & labels[SP], 	-- A = SP
				"A = M - 1", 		-- A = Ram[SP] - 1
				"D = M", 			-- D = Ram[Ram[SP] - 1]
				
				"@" & labels[R1], 	-- 
				"A = M", 			-- A = R1
				
				"M = D",             -- Ram[x + TEMP] = Ram[Ram[SP] - 1]

				"@" & labels[SP], 	-- A = SP
				"M = M - 1" 		-- RAM[SP] = Ram[SP] - 1
				})
		case "static" then
		case "pointer" then
			printToFile({
				"@" & labels[THIS + to_number(command[3])], 
									-- A = THIS if 0, THAT if 1
				"D = A",			-- D = A

				"@" & labels[R1], 	-- 
				"M = D", 			-- R1 = D
				
				"@" & labels[SP], 	-- A = SP
				"A = M - 1", 		-- A = Ram[SP] - 1
				"D = M", 			-- D = Ram[Ram[SP] - 1]
				
				"@" & labels[R1], 	-- 
				"A = M", 			-- A = R1
				
				"M = D",             -- Ram[THIS or THAT] = Ram[Ram[SP] - 1]

				"@" & labels[SP], 	-- A = SP
				"M = M - 1" 		-- RAM[SP] = Ram[SP] - 1
				})
		case "constant" then
			printf(STDERR ,"ERROR: why do you think this will work!?!\n")
		case else

	end switch

end procedure


public procedure handleAdd(sequence command)
	printToFile({
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
		})
end procedure

public procedure handleSub(sequence command)
	printToFile({
		"@" & labels[SP], 			-- A = SP
		"A = M", 					-- A = Ram[SP]
		"A = A - 1",
		"D = M", 					-- D = Ram[Ram[SP] - 1], arg1
        "A = A - 1",
		"A = M", 					-- A = Ram[Ram[SP] - 2], arg2
		"D = D - A", 				-- D = arg1 - arg2
		"@" & labels[SP], 			-- A = SP
		"M = M - 1", 				-- Ram[SP] = Ram[SP] - 1
		"A = M - 1 ",				-- A = Ram[SP] - 1
		"M = D" 					-- Ram[Ram[SP] - 1] = arg1 - arg2
		})
end procedure

public procedure handleMult(sequence command)  
end procedure

public procedure handleDiv(sequence command)  
end procedure

public procedure handleEq(sequence command)
	handleSub({})
	printToFile({
		"@" & labels[SP], 			-- A = SP
		"A = M", 					-- A = Ram[SP]
		"D = M",						-- A = Ram[Ram[SP]]
		""
		})
end procedure

public procedure handleGt(sequence command)
end procedure

public procedure handleLt(sequence command)
end procedure

public procedure handleAnd(sequence command)
end procedure

public procedure handleOr(sequence command)
end procedure

public procedure handleNot(sequence command)
end procedure

procedure printToFile(sequence asmCommands)
	for i = 1 to length(asmCommands) do
		printf(fd_output, asmCommands[i] & "\n")
	end for
end procedure

public function newClassLabel(sequence name)
	sequence res = "@" & name & to_string(counter)
	counter = counter + 1
	return res
end function
/*
implementing all the command functions
*/