include ./SymbolTable.e
include std/io.e
include std/text.e
integer fd_file_output_vm

public procedure initialize(integer _fd_file_output)
    fd_file_output_vm = _fd_file_output
end procedure

public procedure writePush(sequence Segment, sequence index)
    printf(fd_file_output_vm, "push " & Segment & " " & index & "\n")
end procedure

public procedure writePop(sequence Segment, sequence index)
    printf(fd_file_output_vm, "pop " & Segment & " " & index & "\n")
end procedure

public procedure writeArithmetic(sequence command)
    switch command do
        case "+" then
            printf(fd_file_output_vm, "add" & "\n")
            break
        case "-" then
            printf(fd_file_output_vm, "sub" & "\n")
            break
        case "*" then
            printf(fd_file_output_vm, "call Math.multiply 2\n")
            break
        case "/" then
            printf(fd_file_output_vm, "call Math.divide 2" & "\n")
            break
        case "&amp;" then
            printf(fd_file_output_vm, "and" & "\n")
            break
        case "|" then
            printf(fd_file_output_vm, "or" & "\n")
            break
        case "&lt;" then
            printf(fd_file_output_vm, "lt" & "\n")
            break
        case "&gt;" then
            printf(fd_file_output_vm, "gt" & "\n")
            break
        case "=" then
            printf(fd_file_output_vm, "eq" & "\n")
            break
        case "-()" then
            printf(fd_file_output_vm, "neg" & "\n")
            break
        case "~" then
            printf(fd_file_output_vm, "not" & "\n")
            break
    case else
        printf(fd_file_output_vm, command & "\n")
    end switch
end procedure

public procedure writeLabel(sequence _label)
    printf(fd_file_output_vm, "label " & _label & "\n")
end procedure

public procedure writeGoto(sequence _label)
    printf(fd_file_output_vm, "goto " & _label & "\n")
end procedure

public procedure writeIf(sequence _label)
    printf(fd_file_output_vm, "if-goto " & _label & "\n")
end procedure

public procedure writeCall(sequence name, sequence nArgs)
    printf(fd_file_output_vm, "call " & name & " " & nArgs & "\n")
end procedure

public procedure writeFunction(sequence name, sequence nArgs)
    printf(fd_file_output_vm, "function " & name & " " & nArgs & "\n")
end procedure

public procedure writeReturn()
    printf(fd_file_output_vm, "return\n")
end procedure

public function writePushName(sequence name)
    sequence kind = kindOf(name)
    -- puts(STDOUT, kind)
    -- puts(STDOUT, name & "\n")
    -- puts(STDOUT, kind)
    if compare(kind, "NONE") !=0 then -- it is found in the symbol table
        sequence index = sprintf("%d", indexOf(name))
        switch upper(kind) do
            case "ARG" then
                writePush("argument", index)
                break
            case "VAR" then
                writePush("local", index)
                break
            case "STATIC" then
                writePush("static", index)
                break
            case "FIELD" then
                writePush("this", index)
                break
        end switch
        return 1
    end if
    return 0
end function

public function writePopName(sequence name)
    sequence kind = kindOf(name)
    -- puts(STDOUT, kind)
    -- puts(STDOUT, name & "\n")
    -- puts(STDOUT, kind)
    if compare(kind, "NONE") !=0 then -- it is found in the symbol table
        sequence index = sprintf("%d", indexOf(name))
        switch upper(kind) do
            case "ARG" then
                writePop("argument", index)
                break
            case "VAR" then
                writePop("local", index)
                break
            case "STATIC" then
                writePop("static", index)
                break
            case "FIELD" then
                writePop("this", index)
                break
        end switch
        return 1
    end if
    return 0
end function

public procedure writeString(sequence name)

    writePush("constant", sprintf("%d", length(name)))
    printf(fd_file_output_vm, "call String.new 1\n")
    for i = 1 to length(name) do
        sequence temp = sprintf("%d", name[i])
        writePush("constant", temp)
        printf(fd_file_output_vm, "call String.appendChar 2\n")
    end for

end procedure