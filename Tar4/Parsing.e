include std/io.e
include std/types.e
include std/search.e
include std/sequence.e

integer fd_file_output
integer fd_file_input

-- write to xml file
procedure writeToFile(sequence string, integer indent_size)
    sequence indent = ""
    for i = 1 to indent_size do
        indent &= "  "
    end for
    printf(fd_file_output, indent & string)
end procedure

-- this function take the next line, and return it. It procced to next line
function nextToken()
    return gets(fd_file_input)
end function

-- this function see the next line, and return it. It doesn't procced to next line
function peek()
    integer pos = where(fd_file_input)
    if pos = -1 then
        return ""
    end if
    sequence tok = nextToken()
    sequence res = split(tok, ' ') -- get the value of the token
    seek(fd_file_input, pos)
    return res[2]
end function

public procedure parsing(integer _fd_file_input, integer _fd_file_output)
    fd_file_input = _fd_file_input
    fd_file_output = _fd_file_output

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
procedure identifier(integer indent_number)
    writeToFile(nextToken(), indent_number)
end procedure


---------------------------------------------------------------------------------------------
-- Program Structure
---------------------------------------------------------------------------------------------
-- dediction rule for class
-- class --> 'class' className '{' classVarDec* subroutineDec* '}'
procedure class(integer indent_number)
    writeToFile("<class>\n", indent_number)

    indent_number = indent_number + 1 -- increase indent number
    writeToFile(nextToken(), indent_number) -- 'class'
    className(indent_number)
    
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

    writeToFile(nextToken(), indent_number) -- 'static' |  'field'

    _type(indent_number) -- _type
    varName(indent_number) -- varName

    sequence pek = peek()
    while compare(pek, ",")=0 do 
        writeToFile(nextToken(), indent_number) -- ','
        varName(indent_number) -- varName
        pek = peek()
    end while

    writeToFile(nextToken(), indent_number) -- ';'
    
    writeToFile("</classVarDec>\n", indent_number - 1)
end procedure


-- deduction rule for type
procedure _type(integer indent_number)
    sequence pek = peek()
    if compare(pek, "int")=0
         or compare(pek, "char")=0 or compare(pek, "boolean")=0 then -- 'int' or 'char' or 'boolean'
        writeToFile(nextToken(), indent_number) 
    else 
        className(indent_number) -- className
    end if

end procedure

-- deduction rule for subroutineDec
procedure subroutineDec(integer indent_number)
    writeToFile("<subroutineDec>\n", indent_number)

    indent_number = indent_number + 1 -- increase indent number

    writeToFile(nextToken(), indent_number) -- 'constructor' | 'function' | 'method'

    sequence pek = peek()
    if compare(pek, "void")=0 then
        writeToFile(nextToken(), indent_number) -- 'void'
    else
        _type(indent_number) -- _type
    end if
    
    subroutineName(indent_number) -- substroutineName
    
    writeToFile(nextToken(), indent_number) -- '('
    parameterList(indent_number) -- parameterList
    writeToFile(nextToken(), indent_number) -- ')'
    subroutineBody(indent_number) -- subroutineBody

    writeToFile("</subroutineDec>\n", indent_number-1)
end procedure

-- deduction rule for parameterList
procedure parameterList(integer indent_number)
    writeToFile("<parameterList>\n", indent_number)
    
    indent_number = indent_number + 1 -- increase indent number
    
    sequence pek = peek() 
    if compare(pek,")")!=0 then -- ')', the follow
        _type(indent_number) -- type
        varName(indent_number) -- varName

        pek = peek()
        while compare(pek, ",")=0 do 
            writeToFile(nextToken(), indent_number) -- ','
            _type(indent_number) -- type
            varName(indent_number) -- varName
            pek = peek()
        end while
    end if

    writeToFile("</parameterList>\n", indent_number-1)
    
end procedure

-- deduction rule for subroutineBody
procedure subroutineBody(integer indent_number)
    writeToFile("<subroutineBody>\n", indent_number)

    indent_number = indent_number + 1 -- increase indent number

    writeToFile(nextToken(), indent_number) -- '{'
    sequence pek = peek()
    while compare(pek, "var") = 0 do 
        varDec(indent_number) -- varDec
        pek = peek()
    end while

    statements(indent_number) -- statements
    writeToFile(nextToken(), indent_number) -- '}'
    
    writeToFile("</subroutineBody>\n", indent_number - 1)
end procedure

-- deduction rule for varDec
procedure varDec(integer indent_number)
    writeToFile("<varDec>\n", indent_number)
    
    indent_number = indent_number + 1 -- increase indent number

    writeToFile(nextToken(), indent_number) -- "var"
    _type(indent_number) -- type
    varName(indent_number) -- varName

    sequence pek = peek()
    while compare(pek, ",") = 0 do 
        writeToFile(nextToken(), indent_number) -- ','
        varName(indent_number) -- varName
        pek = peek()
    end while

    writeToFile(nextToken(), indent_number) -- ';'
    
    writeToFile("</varDec>\n", indent_number - 1)

end procedure

-- deduction rule for className
procedure className(integer indent_number)
    identifier(indent_number) -- identifier
end procedure

-- deduction rule for subroutineName
procedure subroutineName(integer indent_number)
    identifier(indent_number) -- identifier
end procedure

-- deduction rule for varName
procedure varName(integer indent_number)
    identifier(indent_number) -- identifier
end procedure


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
    varName(indent_number) -- 'varName'
    
    sequence pek = peek()
    if compare(pek, "[")=0 then 
        writeToFile(nextToken(), indent_number) -- '['
        expression(indent_number)
        writeToFile(nextToken(), indent_number) -- ']'
    end if
    writeToFile(nextToken(), indent_number) -- '='
    expression(indent_number)
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
    writeToFile(nextToken(), indent_number) -- ')'
    writeToFile(nextToken(), indent_number) -- '{'
    statements(indent_number) -- statements 
    writeToFile(nextToken(), indent_number) -- '}'

    sequence pek = peek()
    if compare(pek, "else")=0 then 
        writeToFile(nextToken(), indent_number) -- 'else'
        writeToFile(nextToken(), indent_number) -- '{'
        statements(indent_number)
        writeToFile(nextToken(), indent_number) -- '}'
    end if


    writeToFile("</ifStatement>\n", indent_number-1)
end procedure

-- deduction rule for whileStatement
procedure whileStatement(integer indent_number)
    writeToFile("<whileStatement>\n", indent_number)
    indent_number = indent_number + 1 -- increase indent number

    writeToFile(nextToken(), indent_number) -- 'while'
    writeToFile(nextToken(), indent_number) -- '('
    expression(indent_number) -- expression
    writeToFile(nextToken(), indent_number) -- ')'
    writeToFile(nextToken(), indent_number) -- '{'
    statements(indent_number) -- statements
    writeToFile(nextToken(), indent_number) -- '}'

    
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
    end if
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
        op(indent_number) -- op
        term(indent_number) -- term
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
        unaryOp(indent_number) -- unaryOp
        term(indent_number) -- term
    
    else -- all other :(
        sequence res = nextToken() -- nextToken, "not" plaster
        pek = peek()
        if compare(pek,"[")=0 then -- '['
            writeToFile(res, indent_number) -- write res to file

            writeToFile(nextToken(), indent_number) -- '['
            expression(indent_number)
            writeToFile(nextToken(), indent_number) -- ']'
        elsif compare(pek, "(")=0 or compare(pek, ".")=0 then -- '(' or '.'
            subroutineCall(indent_number, res)
        else
            writeToFile(res, indent_number) -- write res to file
        end if
    end if
        
    writeToFile("</term>\n", indent_number-1)
end procedure

-- deduction rule for subroutineCall
procedure subroutineCall(integer indent_number, sequence cheetim = "")
    if compare(cheetim, "")=0 then
        identifier(indent_number) -- class name var name and subrottin name is identifier
    else 
        writeToFile(cheetim, indent_number) -- '{'
    end if
    
    sequence pek = peek()
    if compare(pek, ".") = 0 then
        writeToFile(nextToken(), indent_number) -- '.'
        subroutineName(indent_number)
    end if
    writeToFile(nextToken(), indent_number) -- '('
    expressionList(indent_number)
    writeToFile(nextToken(), indent_number) -- ')'
end procedure

-- deduction rule for expressionList
procedure expressionList(integer indent_number)
    writeToFile("<expressionList>\n", indent_number)

    indent_number = indent_number + 1 -- increase indent number
    
    sequence pek = peek()
    if compare(pek, ")") != 0 then -- follow is )
    
        expression(indent_number) -- expression
        pek = peek()
        while compare(pek, ",")=0 do 
            writeToFile(nextToken(), indent_number) -- ','
            expression(indent_number) -- expression
            pek = peek()
        end while
    end if
    
    writeToFile("</expressionList>\n", indent_number-1)
end procedure

-- deduction rule for op
procedure op(integer indent_number)
    writeToFile(nextToken(), indent_number) -- '+' or '-' or '* or '/' or '&' or '|' or '<' or '>' or '='   
end procedure

-- deduction rule for unaryOp
procedure unaryOp(integer indent_number)    
    writeToFile(nextToken(), indent_number) -- '-' or '~'
end procedure

-- deduction rule for KeywordConstant
procedure KeywordConstant(integer indent_number)
    writeToFile("<KeywordConstant>\n", indent_number)

    indent_number = indent_number + 1 -- increase indent number
    
    writeToFile(nextToken(), indent_number) -- 'true' or 'false' or 'null' or 'this'

    writeToFile("</KeywordConstant>\n", indent_number-1)
end procedure


