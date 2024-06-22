include std/console.e
include std/io.e
include std/sequence.e
include std/search.e
include std/filesys.e
include std/convert.e
include ./Tokenizing.e

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

sequence path
path = prompt_string("Give me path: ")
-- path = "C:\\Users\\avish\\OneDrive\\Desktop\\ekronot\\nand2tetris\\projects\\07\\MemoryAccess\\BasicTest"
sequence path_elems = split_path(path)
sequence name_dir = path_elems[length(path_elems)]

-- brings only "jack" filenames in dir
sequence filenames = find_files_in_current_dir(path)
sequence only_jack_filenames = {}
for i=1 to length(filenames) do 
	sequence data_splited = split(filenames[i], ".")
	sequence ending = data_splited[2] 	
		if equal(ending, "jack") then 
            only_jack_filenames=append(only_jack_filenames,data_splited[1])
	end if
end for



-- loop on every input file and to the tokenizing
for i=1 to length(only_jack_filenames) do 

	integer fd_file_input = open(path & "\\" & only_jack_filenames[i] & ".jack","r") 
	
    sequence output_filename = only_jack_filenames[i] & "Tour.xml"
    fd_output = open(path & "\\" & output_filename, "w") -- create output file in xml format

    if fd_output = -1 then
        printf(STDERR, "ERROR opening output file")
    end if

    tokenizeAnalyser(fd_file_input, fd_output)
    -- pasrsing(fd_file_input, fd_output)  

	close(fd_file_input)
    close(fd_output)
end for


