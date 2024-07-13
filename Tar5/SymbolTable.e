include std/sequence.e
include std/io.e
include std/text.e

sequence ClassScopeST = {}
sequence SubrottinScopeST = {}

integer argIndex = 0
integer varIndex = 0
integer staticIndex = 0
integer fieldIndex = 0

public procedure startClass()
    ClassScopeST = {}
    SubrottinScopeST = {}
    argIndex = 0
    varIndex = 0
    staticIndex = 0
    fieldIndex = 0
end procedure

public procedure startSubroutine()
    SubrottinScopeST = {}
    argIndex = 0
    varIndex = 0
end procedure

-- add to the symbol table
-- name: the name of the identifier
-- IDType: the type of the identifier (int, string, etc)
-- kind: the kind of the identifier (STATIC, FIELD, ARG, VAR)
public procedure define(sequence name, sequence IDType, sequence kind)
    -- puts(STDOUT, name & " " & IDType & " " & kind & " " & "\n")
    switch upper(kind) do
        case "ARG" then
            SubrottinScopeST &= {{name, IDType, kind, argIndex}}
            argIndex += 1
            break
        case "VAR" then
            SubrottinScopeST &= {{name, IDType, kind, varIndex}}
            varIndex += 1
            break
        case "STATIC" then
            ClassScopeST &= {{name, IDType, kind, staticIndex}}
            staticIndex += 1
            break
        case "FIELD" then
            ClassScopeST &= {{name, IDType, kind, fieldIndex}}
            fieldIndex += 1
            break
    end switch
end procedure

-- function that counts the number of variables from given kind
public function varCount(sequence kind)
    switch upper(kind) do
        case "ARG" then
            return argIndex  

        case "VAR" then
            return varIndex
            
        case "STATIC" then
            return staticIndex 
            
        case "FIELD" then
            return fieldIndex
    end switch
end function

-- function that returns the kind of the identifier
public function kindOf(sequence name)
    for i = 1 to length(SubrottinScopeST) do
        if compare(SubrottinScopeST[i][1], name)=0 then
            return SubrottinScopeST[i][3]
        end if
    end for            

    for i = 1 to length(ClassScopeST) do
        if compare(ClassScopeST[i][1], name)=0 then
            return ClassScopeST[i][3]
        end if
    end for            

    return "NONE"
end function

-- function that returns the type of the identifier
public function typeOf(sequence name)
    for i = 1 to length(SubrottinScopeST) do
        if compare(SubrottinScopeST[i][1], name)=0 then
            return SubrottinScopeST[i][2]
        end if
    end for            

    for i = 1 to length(ClassScopeST) do
        if compare(ClassScopeST[i][1], name)=0 then
            return ClassScopeST[i][2]
        end if
    end for            

    return "NONE"
end function

-- function that returns the index of the identifier
public function indexOf(sequence name)
    for i = 1 to length(SubrottinScopeST) do
        if compare(SubrottinScopeST[i][1], name)=0 then
            return SubrottinScopeST[i][4]
        end if
    end for            

    for i = 1 to length(ClassScopeST) do
        if compare(ClassScopeST[i][1], name)=0 then
            return ClassScopeST[i][4]
        end if
    end for            

    return "NONE"
end function

public procedure printST()
    puts(STDOUT, "<ClassScopeST>:\n")
    for i = 1 to length(ClassScopeST) do
        for j = 1 to 3 do
            puts(STDOUT, ClassScopeST[i][j] & ", ")
        end for
        puts(STDOUT, sprintf("%d", ClassScopeST[i][4]) & "\n")
    end for
    puts(STDOUT, "</ClassScopeST>:\n")
    puts(STDOUT, "<SubrottinScopeST>:\n")
    
    for i = 1 to length(SubrottinScopeST) do
        for j = 1 to 3 do
            puts(STDOUT, SubrottinScopeST[i][j] & ", ")
        end for
        puts(STDOUT, sprintf("%d", SubrottinScopeST[i][4]) & "\n")
    end for           
    puts(STDOUT, "</SubrottinScopeST>:\n")
end procedure