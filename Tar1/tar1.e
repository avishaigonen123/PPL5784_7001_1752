include std/console.e
include std/io.e
include std/sequence.e
include std/search.e
include std/filesys.e
include std/convert.e
include ./Handle.e

-- file desciprtor for output file
global integer fd_output


/*
  func that returns filenames in the path
*/
function find_files_in_current_dir(sequence _path)
	sequence files = dir(_path)
	sequence filenames = {}

	for i = 1 to length(files) do
		filenames = append(filenames,files[i][1]) -- reutrn filenames
	end for

	return filenames
end function

/*
  the func that do the tranlastion
  asums that the input is correct
*/

function translate(sequence line, sequence name)
	sequence command = split(line, " ")
	sequence asm = {}
 -- puts(fd_output, "@" & join(command, "_") & '\n')
	switch command[1] do
		case "pop" then
    		asm = handlePop(command, name)
		case "push" then
    		asm = handlePush(command, name)
		case "add" then
			asm = handleAdd(command)
		case "sub" then
      		asm = handleSub(command)
		case "eq" then
      		asm = handleEq(command)
		case "gt" then
			asm = handleGt(command)
		case "lt" then
			asm = handleLt(command)
		case "and" then
			asm = handleAnd(command)
		case "or" then
			asm = handleOr(command)
    	case "not" then
      		asm = handleNot(command)
		case "neg" then
			asm = handleNeg(command)
		case "label" then
			asm = handleLabel(command, name)
		case "goto"	then	
			asm = handleGoto(command, name)
		case "if-goto" then
			asm = handleIfGoto(command, name)
		case "call" then
            asm = handleCall(command, name)
		case "function" then
			asm = handleFunction(command, name)
		case "return" then
            asm = handleReturn(command, name)
		case else
			return -1
	end switch
	printToFile(asm)
	return 0
end function

sequence path
path = prompt_string("Give me path: ")
-- path = "C:\\Users\\avish\\OneDrive\\Desktop\\ekronot\\nand2tetris\\projects\\07\\MemoryAccess\\BasicTest"
sequence path_elems = split_path(path)
sequence name_dir = path_elems[length(path_elems)]
sequence output_filename = name_dir & ".asm"
fd_output = open(path & "\\" & output_filename, "w") -- create output file in Asm langauage

build() -- inisialize the asm file

if fd_output = -1 then
	printf(STDERR, "ERROR opening output file")
end if


-- brings only "vm" filenames in dir
sequence filenames = find_files_in_current_dir(path)
sequence only_vm_filenames ={}
for i=1 to length(filenames) do 
	sequence data_splited = split(filenames[i], ".")
	sequence ending = data_splited[2] 	
		if equal(ending, "vm") then 
		only_vm_filenames=append(only_vm_filenames,filenames[i])
	end if
end for
-- loop on every input file and to the translation
for i=1 to length(only_vm_filenames) do 
	integer fd_file_input = open(path & "\\"& only_vm_filenames[i],"r") 
	sequence data_splited = split(only_vm_filenames[i], ".")
	-- puts(fd_output, "\n" & data_splited[1] & ':' & '\n') -- only for debug
	sequence data = read_lines(fd_file_input)
	for line=1 to length(data) do
        if length(data[line]) = 0 or begins("//", data[line]) then 
            continue
        end if
        if translate(data[line], data_splited[1]) = -1 then
            printf(STDERR, "ERROR in line %d in file %s:\n%s\n\n", {line, only_vm_filenames[i], data[line]})
        end if
	end for
	close(fd_file_input)
end for


close(fd_output)
