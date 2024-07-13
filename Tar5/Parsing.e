include std/io.e
include std/types.e
include std/search.e
include std/sequence.e
include ./VMWriter.e
include ./SymbolTable.e

integer fd_file_output_xml
integer fd_file_output_vm
integer fd_file_input

sequence _className

integer index_label = 0

-- write to xml file
procedure writeToFile(sequence string, integer indent_size)
    sequence indent = ""
    for i = 1 to indent_size do
        indent &= "  "
    end for
    printf(fd_file_output_xml, indent & string)
    -- here, write to vm file
    ----------------------------------------------------------------
    ----------------------------------------------------------------
    -- handleWriting(fd_file_output_vm, string)

end procedure

-- this function take the next line, and return it. It procced to next line
function nextToken()
    return gets(fd_file_input)
end function

-- this function returns the content in the token
function getContent(sequence tok)
    sequence splited = split(tok, ' ')
    if length(splited) > 2 then
        return join(splited[2..$-1], ' ')
    else
        return ""
    end if
end function

-- this function see the next line, and return it. It doesn't procced to next line
function peek()
    integer pos = where(fd_file_input)
    if pos = -1 then
        return ""
    end if
    sequence tok = nextToken()
    seek(fd_file_input, pos)
    return getContent(tok)
end function

public procedure parsing(integer _fd_file_input, integer _fd_file_output_xml, integer _fd_file_output_vm)
    fd_file_input = _fd_file_input
    fd_file_output_xml = _fd_file_output_xml
    fd_file_output_vm = _fd_file_output_vm
    
    initialize(fd_file_output_vm)

    gets(fd_file_input)
    class(0)
    gets(fd_file_input)
end procedure


---------------------------------------------------------------------------------------------
-- dediction rules
---------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
-- Lexical elements
---------------------------------------------------------------------------------------------
-- deduction rule for keyward
procedure keyward(integer indent_number)
    writeToFile(nextToken(), indent_number)
end procedure

-- deduction rule for symbol
procedure symbol(integer indent_number)
    writeToFile(nextToken(), indent_number)
end procedure

-- deduction rule for integerConstant
procedure integerConstant(integer indent_number)
    writeToFile(nextToken(), indent_number)
end procedure

-- deduction rule for StringConstant
procedure StringConstant(integer indent_number)
    writeToFile(nextToken(), indent_number)
end procedure

-- deduction rule for identifier
function identifier(integer indent_number)
    sequence identifier = nextToken()
    writeToFile(identifier, indent_number)
    return getContent(identifier)
end function


---------------------------------------------------------------------------------------------
-- Program Structure
---------------------------------------------------------------------------------------------
-- dediction rule for class
-- class --> 'class' className '{' classVarDec* subroutineDec* '}'
procedure class(integer indent_number)
    writeToFile("<class>\n", indent_number)

    indent_number = indent_number + 1 -- increase indent number
    writeToFile(nextToken(), indent_number) -- 'class'
    _className = className(indent_number)
    
    writeToFile(nextToken(), indent_number) -- '{'
    
    sequence pek = peek()
     
    
    while compare(pek, "static")=0 or compare(pek, "field")=0 do
        classVarDec(indent_number) -- classVarDec
        pek = peek()
    end while

    while compare(pek, "constructor")=0 or compare(pek, "function")=0 or compare(pek, "method")=0 do
        subroutineDec(indent_number) -- subroutineDec
        pek = peek()
    end while
   

    writeToFile(nextToken(), indent_number) -- '}'
    writeToFile("</class>\n", indent_number -1)
end procedure


-- deduction rule for classVarDec
procedure classVarDec(integer indent_number)
    writeToFile("<classVarDec>\n", indent_number)

    indent_number = indent_number + 1 -- increase indent number

    sequence kind = nextToken()
    writeToFile(kind, indent_number) -- 'static' |  'field'
    
    sequence _type2 = _type(indent_number) -- _type
    sequence name = varName(indent_number) -- varName
    
    -- puts(STDOUT, "enter\n")
    define(name, _type2, getContent(kind))
    -- define("name1", "int", "STATIC")
    -- printST()

    sequence pek = peek()
    while compare(pek, ",")=0 do 
        writeToFile(nextToken(), indent_number) -- ','
        name = varName(indent_number) -- varName
        define(name, _type2, getContent(kind))
        pek = peek()
    end while

    writeToFile(nextToken(), indent_number) -- ';'
    
    writeToFile("</classVarDec>\n", indent_number - 1)
end procedure


-- deduction rule for type
function _type(integer indent_number)
    sequence pek = peek()
    if compare(pek, "int")=0 or compare(pek, "char")=0 or compare(pek, "boolean")=0 then -- 'int' or 'char' or 'boolean'
        sequence _type = nextToken()
        writeToFile(_type, indent_number)
        return getContent(_type) 
    else 
        return className(indent_number) -- className
    end if

end function

-- deduction rule for subroutineDec
procedure subroutineDec(integer indent_number)
    writeToFile("<subroutineDec>\n", indent_number)

    indent_number = indent_number + 1 -- increase indent number

    sequence subroutine = nextToken()
    writeToFile(subroutine, indent_number) -- 'constructor' | 'function' | 'method'

    startSubroutine()

    sequence pek = peek()
    if compare(pek, "void")=0 then  
        writeToFile(nextToken(), indent_number) -- 'void'
    else
        _type(indent_number) -- _type
    end if
    
    sequence subroutine_name = subroutineName(indent_number) -- substroutineName
    
    if compare(getContent(subroutine), "method")=0 then
        define("this", _className, "arg")
    end if
    
    writeToFile(nextToken(), indent_number) -- '('
    parameterList(indent_number) -- parameterList
    writeToFile(nextToken(), indent_number) -- ')'
    subroutineBody(indent_number, subroutine_name, getContent(subroutine)) -- subroutineBody

    writeToFile("</subroutineDec>\n", indent_number-1)
end procedure

-- deduction rule for parameterList
procedure parameterList(integer indent_number)
    writeToFile("<parameterList>\n", indent_number)
    
    indent_number = indent_number + 1 -- increase indent number
    
    sequence pek = peek() 
    if compare(pek,")")!=0 then -- ')', the follow
        sequence type2 = _type(indent_number) -- type
        sequence name = varName(indent_number) -- varName
        sequence kind = "arg"
        define(name, type2, kind)
        pek = peek()
        while compare(pek, ",")=0 do 
            writeToFile(nextToken(), indent_number) -- ','
            type2 = _type(indent_number) -- type
            name = varName(indent_number) -- varName
            define(name, type2, kind)
            pek = peek()
        end while
    end if

    writeToFile("</parameterList>\n", indent_number-1)
    
end procedure

-- deduction rule for subroutineBody
procedure subroutineBody(integer indent_number, sequence subroutine_name, sequence subroutine_type)
    writeToFile("<subroutineBody>\n", indent_number)

    indent_number = indent_number + 1 -- increase indent number

    writeToFile(nextToken(), indent_number) -- '{'
    sequence pek = peek()
    while compare(pek, "var") = 0 do 
        varDec(indent_number) -- varDec
        pek = peek()
    end while
    
    writeFunction(_className & "." & subroutine_name, sprintf("%d",varCount("VAR")))
    
    if compare(subroutine_type, "method")=0 then
        writePush("argument", "0")
        writePop("pointer", "0")
    elsif compare(subroutine_type, "constructor")=0 then
        printST()
        writePush("constant", sprintf("%d", varCount("FIELD")))
        writeCall("Memory.alloc", "1")
        writePop("pointer", "0")
    end if
    
    statements(indent_number) -- statements
    writeToFile(nextToken(), indent_number) -- '}'
    
    writeToFile("</subroutineBody>\n", indent_number - 1)
end procedure

-- deduction rule for varDec
procedure varDec(integer indent_number)
    writeToFile("<varDec>\n", indent_number)
    
    indent_number = indent_number + 1 -- increase indent number

    writeToFile(nextToken(), indent_number) -- "var"
    sequence type2 = _type(indent_number) -- type
    sequence name = varName(indent_number) -- varName
    sequence kind = "var" 
    define(name, type2, kind)
    sequence pek = peek()
    while compare(pek, ",") = 0 do 
        writeToFile(nextToken(), indent_number) -- ','
        name = varName(indent_number) -- varName
        define(name, type2, kind)    
        pek = peek()
    end while

    writeToFile(nextToken(), indent_number) -- ';'
    
    writeToFile("</varDec>\n", indent_number - 1)

end procedure

-- deduction rule for className
function className(integer indent_number)
    return identifier(indent_number) -- identifier
end function

-- deduction rule for subroutineName
function subroutineName(integer indent_number)
    return identifier(indent_number) -- identifier
end function

-- deduction rule for varName
function varName(integer indent_number)
    return identifier(indent_number) -- identifier
end function


---------------------------------------------------------------------------------------------
-- Statements
---------------------------------------------------------------------------------------------
-- deduction rule for statements
procedure statements(integer indent_number)
    writeToFile("<statements>\n", indent_number)
    indent_number = indent_number + 1 -- increase indent number
    sequence pek = peek()
    while compare(pek, "let")=0 or compare(pek, "if")=0 or compare(pek, "while")=0 or compare(pek, "do")=0 or compare(pek, "return")=0 do 
        statement(indent_number) -- statement
        if compare(pek, "do")=0 then
            writePop("temp", "0")
        end if
        pek = peek()
    end while
    
    writeToFile("</statements>\n", indent_number - 1)
end procedure

-- deduction rule for statement
procedure statement(integer indent_number)
    
    sequence pek = peek()
    if compare(pek, "let")=0 then
        letStatement(indent_number)
    elsif compare(pek, "if")=0 then
        ifStatement(indent_number)
    elsif compare(pek, "while")=0 then
        whileStatement(indent_number)
    elsif compare(pek, "do")=0 then
        doStatement(indent_number)
    elsif compare(pek, "return")=0 then
        ReturnStatement(indent_number)
    end if

end procedure

-- deduction rule for letStatement
procedure letStatement(integer indent_number)
    writeToFile("<letStatement>\n", indent_number)

    indent_number = indent_number + 1 -- increase indent number
    
    writeToFile(nextToken(), indent_number) -- 'let'
    sequence name = varName(indent_number) -- 'varName'
    
    sequence pek = peek()
    if compare(pek, "[")=0 then 
        writeToFile(nextToken(), indent_number) -- '['
        writePushName(name)
        expression(indent_number)
        writeArithmetic("add")
        
        writeToFile(nextToken(), indent_number) -- ']'
    end if

    writeToFile(nextToken(), indent_number) -- '='

    expression(indent_number)
    
    if compare(pek, "[")!=0 then 
        writePopName(name)
    else
        writePop("temp", "0")
        writePop("pointer", "1")
        writePush("temp", "0")
        writePop("that", "0")
    end if
    
    writeToFile(nextToken(), indent_number) -- ';'

    writeToFile("</letStatement>\n", indent_number - 1)
end procedure

-- deduction rule for ifStatement
procedure ifStatement(integer indent_number)
    writeToFile("<ifStatement>\n", indent_number)
    indent_number = indent_number + 1 -- increase indent number

    writeToFile(nextToken(), indent_number) -- 'if'
    writeToFile(nextToken(), indent_number) -- '('
    expression(indent_number) -- expression

    integer inner_index_label = index_label

    writeArithmetic("not") -- ~ operator
    writeIf("L" & sprintf("%d", inner_index_label)) -- if-goto Lx
    writeToFile(nextToken(), indent_number) -- ')'
    writeToFile(nextToken(), indent_number) -- '{'

    index_label += 2
    statements(indent_number) -- statements 
    writeToFile(nextToken(), indent_number) -- '}'
    writeGoto("L" & sprintf("%d", inner_index_label+1)) -- goto L(x+1)
    writeLabel("L" & sprintf("%d", inner_index_label)) -- label Lx

    sequence pek = peek()
    if compare(pek, "else")=0 then 
        writeToFile(nextToken(), indent_number) -- 'else'
        writeToFile(nextToken(), indent_number) -- '{'
        statements(indent_number)
        writeToFile(nextToken(), indent_number) -- '}'
    end if
    writeLabel("L" & sprintf("%d", inner_index_label+1)) -- label L(x+1)
    index_label += 1

    writeToFile("</ifStatement>\n", indent_number-1)
end procedure

-- deduction rule for whileStatement
procedure whileStatement(integer indent_number)
    writeToFile("<whileStatement>\n", indent_number)
    indent_number = indent_number + 1 -- increase indent number
 
    integer inner_index_label = index_label

    writeLabel("L" & sprintf("%d", inner_index_label)) -- Label Lx
    writeToFile(nextToken(), indent_number) -- 'while'
    writeToFile(nextToken(), indent_number) -- '('
    expression(indent_number) -- expression
    writeToFile(nextToken(), indent_number) -- ')'
    writeArithmetic("not")
    writeIf("L" & sprintf("%d", inner_index_label+1)) -- if-goto L(x+1)
    writeToFile(nextToken(), indent_number) -- '{'

    index_label += 2
    statements(indent_number) -- statements
    writeToFile(nextToken(), indent_number) -- '}'
    writeGoto("L" & sprintf("%d", inner_index_label)) -- goto Lx
    writeLabel("L" & sprintf("%d", inner_index_label+1)) -- Label L(x+1)
    

    writeToFile("</whileStatement>\n", indent_number-1)
end procedure

-- deduction rule for doStatement
procedure doStatement(integer indent_number)
    writeToFile("<doStatement>\n", indent_number)
    indent_number = indent_number + 1 -- increase indent number

    writeToFile(nextToken(), indent_number) -- 'do'
    subroutineCall(indent_number) -- subroutineCall
    writeToFile(nextToken(), indent_number) -- ';'

    writeToFile("</doStatement>\n", indent_number-1)
end procedure

-- deduction rule for ReturnStatement
procedure ReturnStatement(integer indent_number)
    writeToFile("<returnStatement>\n", indent_number)
    indent_number = indent_number + 1 -- increase indent number

    writeToFile(nextToken(), indent_number) -- "return"

    sequence pek = peek()
    if compare(pek, ";")!=0 then
        expression(indent_number)
    else
        writePush("constant", "0")
    end if
    writeReturn()

    writeToFile(nextToken(), indent_number) -- ';'
    writeToFile("</returnStatement>\n", indent_number-1)
end procedure

---------------------------------------------------------------------------------------------
-- Expressions
---------------------------------------------------------------------------------------------

-- deduction rule for expression
procedure expression(integer indent_number)
    writeToFile("<expression>\n", indent_number)
    indent_number = indent_number + 1 -- increase indent number
    
    term(indent_number) -- term
    sequence pek = peek()
    while compare(pek, "+")=0 or compare(pek, "-")=0 or compare(pek, "*")=0 or compare(pek, "/")=0 or compare(pek, "&amp;")=0 or compare(pek, "|")=0 or compare(pek, "&lt;")=0 or compare(pek, "&gt;")=0 or compare(pek, "=")=0 
    do 
        sequence _op = op(indent_number) -- op
        term(indent_number) -- term
        writeArithmetic(_op)
        pek = peek()
    end while
    
    writeToFile("</expression>\n", indent_number-1)
end procedure

-- deduction rule for term
procedure term(integer indent_number)
    writeToFile("<term>\n", indent_number)

    indent_number = indent_number + 1 -- increase indent number
    
    sequence pek = peek()
    if compare(pek, "(")=0 then 
        writeToFile(nextToken(), indent_number) -- '('
        expression(indent_number) -- expression
        writeToFile(nextToken(), indent_number) -- ')'
        
    elsif compare(pek,"-")=0 or compare(pek,"~")=0 then -- '-' or '~'
        sequence _unary_op = unaryOp(indent_number) -- unaryOp
        term(indent_number) -- term
        if compare(_unary_op, "-")=0 then
            _unary_op &= "()"
        end if
        writeArithmetic(_unary_op)
    else -- all other :(
        sequence res = nextToken() -- nextToken, "not" plaster
        sequence content = getContent(res)
        pek = peek()
        if compare(pek,"[")=0 then -- '['
            writeToFile(res, indent_number) -- write res to file
            writePushName(content)
            writeToFile(nextToken(), indent_number) -- '['
            expression(indent_number)
            writeArithmetic("add")
            writeToFile(nextToken(), indent_number) -- ']'
            writePop("pointer", "1")
            writePush("that", "0")
        elsif compare(pek, "(")=0 or compare(pek, ".")=0 then -- '(' or '.'
            subroutineCall(indent_number, getContent(res))
        else
            if t_digit(content) then
                writePush("constant", content)
            else
                integer valid = writePushName(content)
                if valid=0 then
                    switch content do
                        case "true" then
                            writePush("constant", "0")
                            writeArithmetic("~")
                            break
                        case "false" then
                            writePush("constant", "0")
                            break
                        case "null" then
                            writePush("constant", "0")
                            break
                        case "this" then
                            writePush("pointer", "0")
                            break
                        case else
                            writeString(content)
                            break
                    end switch
                end if
            end if
            writeToFile(res, indent_number) -- write res to file
        end if
    end if
        
    writeToFile("</term>\n", indent_number-1)
end procedure

-- deduction rule for subroutineCall
procedure subroutineCall(integer indent_number, sequence cheetim = "")
    sequence firstTok
    if compare(cheetim, "")=0 then
        firstTok = identifier(indent_number) -- class name var name and subrottin name is identifier
    else 
        firstTok = cheetim
        writeToFile(firstTok, indent_number) -- '{'
    end if

    
    sequence pek = peek()
    sequence name = firstTok 
    integer objPush = 0
    if compare(pek, ".") = 0 then
        writeToFile(nextToken(), indent_number) -- '.'
        sequence  _subroutineName = subroutineName(indent_number)
        -- check if firstTok is an object from the symbol table
        
        if writePushName(firstTok)=1 then
            name = typeOf(firstTok) & "." & _subroutineName
            objPush = 1
        else
            name = firstTok & "." & _subroutineName
        end if
    else
        name = _className & "." & firstTok
        writePush("pointer", "0")
        objPush = 1
    end if
    writeToFile(nextToken(), indent_number) -- '('
    integer nArgs = expressionList(indent_number)
    
    writeCall(name, sprintf("%d", nArgs + objPush))

    writeToFile(nextToken(), indent_number) -- ')'
end procedure

-- deduction rule for expressionList
function expressionList(integer indent_number)
    writeToFile("<expressionList>\n", indent_number)

    indent_number = indent_number + 1 -- increase indent number
    integer counter = 0
    sequence pek = peek()
    if compare(pek, ")") != 0 then -- follow is )
        counter += 1
        expression(indent_number) -- expression
        pek = peek()
        while compare(pek, ",")=0 do 
            counter += 1
            writeToFile(nextToken(), indent_number) -- ','
            expression(indent_number) -- expression
            pek = peek()
        end while
    end if
    
    writeToFile("</expressionList>\n", indent_number-1)
    return counter
end function

-- deduction rule for op
function op(integer indent_number)
    sequence _op = nextToken()
    writeToFile(_op, indent_number) -- '+' or '-' or '* or '/' or '&' or '|' or '<' or '>' or '='   
    return getContent(_op)
end function

-- deduction rule for unaryOp
function unaryOp(integer indent_number)   
    sequence unary_op = nextToken() 
    writeToFile(unary_op, indent_number) -- '-' or '~'
    return getContent(unary_op)
end function

-- deduction rule for KeywordConstant
function KeywordConstant(integer indent_number)
    writeToFile("<KeywordConstant>\n", indent_number)

    indent_number = indent_number + 1 -- increase indent number
    
    sequence keyward_constant = nextToken()
    writeToFile(keyward_constant, indent_number) -- 'true' or 'false' or 'null' or 'this'

    writeToFile("</KeywordConstant>\n", indent_number-1)
    return getContent(keyward_constant)
end function