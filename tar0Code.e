include std/filesys.e
include std/search.e
include std/io.e
include std/convert.e

sequence e = command_line()
integer outputFileNum = open(filename(e[3]) & ".asm", "w")

atom sellSum = 0
atom buySum = 0

function HandleBuy(sequence ProductName, integer Amount, atom Price)
    printf(outputFileNum, "### BUY %s ###\n%.2f\n", {ProductName, Amount * Price})
    buySum = buySum + Amount * Price
    return 0
end function

function HandleCell(sequence ProductName, integer Amount, atom Price)
    printf(outputFileNum, "$$$ CELL %s $$$\n%.2f\n", {ProductName, Amount * Price})
    sellSum = sellSum + Amount * Price
    return 0
end function

procedure manipulate(sequence path, sequence name)
    puts(outputFileNum, name[1 .. length(name)-3] & "\n")
    sequence fpath = join_path({path, name})
    fpath = fpath[2 .. length(fpath)]
    integer ifile = open(fpath , "r")
    if ifile < 0 then
        printf(2, "Could not open file %s", {fpath})
    end if
    object lines = read_lines(ifile)
    for i = 1 to length(lines) do
        sequence seperators = find_all(' ', lines[i])
        if equal(lines[i][1 .. seperators[1] - 1], "buy") then
            HandleBuy(
                lines[i][seperators[1] + 1 .. seperators[2] - 1],
                to_number(lines[i][seperators[2] + 1 .. seperators[3] - 1]),
                to_number(lines[i][seperators[3] + 1 .. length(lines[i])]))
        elsif equal(lines[i][1 .. seperators[1] - 1], "cell") then
            HandleCell(
                lines[i][seperators[1] + 1 .. seperators[2] - 1],
                to_number(lines[i][seperators[2] + 1 .. seperators[3] - 1]),
                to_number(lines[i][seperators[3] + 1 .. length(lines[i])]))
        end if
    end for
end procedure

-----------------------------------------------------------------------------------------------

sequence d = dir(e[3]) 

for i = 1 to length(d) do
    if ends(".vm", d[i][D_NAME]) then
        manipulate(e[3], d[i][D_NAME])
    end if
end for

printf(outputFileNum, "TOTAL BUY: %.2f\n", {buySum})
printf(outputFileNum, "TOTAL CELL: %.2f\n", {sellSum})
printf(1, "TOTAL BUY: %.2f\n", {buySum})
printf(1, "TOTAL CELL: %.2f\n", {sellSum})
