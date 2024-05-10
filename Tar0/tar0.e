include std/console.e
include std/io.e
include std/sequence.e
include std/search.e
include std/filesys.e
include std/convert.e

  
function HandleBuy(sequence ProductName, integer Amount, atom Price)
 printf(fd_output, "### BUY %s ###\n%.1f\n", {ProductName,Amount*Price})
  return Amount*Price
end function

function HandleCell(sequence ProductName, integer Amount, atom Price)
  printf(fd_output, "$$$ CELL %s $$$\n%.1f\n", {ProductName,Amount*Price})
  return Amount*Price
end function

function find_files_in_current_dir(sequence _path)
  sequence files = dir(_path)
  sequence filenames = {}

  for i = 1 to length(files) do
      filenames = append(filenames,files[i][1])
  end for

  return filenames
end function

sequence path
path = prompt_string("Give me path: ")

sequence path_elems = split_path(path)
sequence name_dir = path_elems[length(path_elems)]
sequence output_filename = name_dir & ".asm"

global integer fd_output = open(output_filename, "w")

if fd_output = -1 then
  printf(STDERR, "ERROR opening output file")
end if

sequence filenames = find_files_in_current_dir(path)
sequence only_vm_filenames ={}
for i=1 to length(filenames) do 
  sequence data_splited = split(filenames[i], ".")
  sequence ending = data_splited[2]
    if equal(ending, "vm") then 
    only_vm_filenames=append(only_vm_filenames,filenames[i])
  end if
end for
atom purchases = 0
atom sales = 0

for i=1 to length(only_vm_filenames) do 
  integer fd_file_input = open(only_vm_filenames[i],"r")
  sequence data_splited = split(only_vm_filenames[i], ".")
  puts(fd_output, data_splited[1]&'\n')
  sequence data=read_lines(fd_file_input)

  for j=1 to length(data) do
    data_splited = split(data[j], " ")
    if equal(data_splited[1], "buy") then
      purchases += HandleBuy(data_splited[2],to_number(data_splited[3]),to_number(data_splited[4]))

    elsif equal(data_splited[1], "cell") then
      sales += HandleCell(data_splited[2],to_number(data_splited[3]),to_number(data_splited[4]))
    end if
  
  end for
  close(fd_file_input)
end for

printf(fd_output, "total purchases: %.1f\n", purchases)
printf(fd_output, "total sales: %.1f\n", sales)

close(fd_output)

-- comment