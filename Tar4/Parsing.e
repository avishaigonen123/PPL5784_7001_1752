include std/io.e
include std/types.e
include std/search.e

/*sequence keywords = {
    "class", "constructor", "function", "method", "field", "static", "var", "int", "char", "boolean", "void", "true", "false", "null", "this", "let", "do", "if", "else", "while", "return"
}

sequence symbol = {
    '{', '}', '(', ')', '[', ']', '.', ',', ';', '+', '-', '*', '/', '&', '|', '<', '>', '=', '~'
}*/

integer fd_file_output
integer fd_file_input

-- write to xml file
procedure writeToFile(sequence string, integer indent_size)
    indent = '\t' * indent_size
    printf(fd_file_output, indent & string)
end procedure

-- this function take the next line, and return it. It procced to next line
function nextToken()
    return ""
end function

-- this function see the next line, and return it. It doesn't procced to next line
function peek()
    return ""
end function

public procedure parsing(integer _fd_file_input, integer _fd_file_output)
    fd_file_input = _fd_file_input
    fd_file_output = _fd_file_output

    class(0)

end procedure


---------------------------------------------------------------------------------------------
-- dediction rules
---------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
-- Lexical elements
---------------------------------------------------------------------------------------------
-- deduction rule for keyward
procedure keyward(integer indent_number)
end procedure

-- deduction rule for symbol
procedure symbol(integer indent_number)
end procedure

-- deduction rule for integerConstant
procedure integerConstant(integer indent_number)
end procedure

-- deduction rule for StringConstant
procedure StringConstant(integer indent_number)
end procedure

-- deduction rule for identifier
procedure identifier(integer indent_number)
end procedure


---------------------------------------------------------------------------------------------
-- Program Structure
---------------------------------------------------------------------------------------------
-- dediction rule for class
-- class --> 'class' className '{' classVarDec* subroutineDec* '}'
procedure class(integer indent_number)  
    printf(fd_file_output, "<class>\n")
    indent_number = indent_number + 1 -- increase indent number

    writeToFile(nextToken(), indent_number) -- 'class'
    className(indent_number)
    
    writeToFile(nextToken(), indent_number) -- '{'
    
    sequence pek = peek()
    while pek = "static" or pek = "field" do
        classVarDec(indent_number) -- classVarDec
        pek = peek()
    end while
    
    while pek = "constructor" or pek = "function" or pek = "method" do
        subroutineDec(indent_number) -- subroutineDec
        pek = peek()
    end while
    
    writeToFile(nextToken(), indent_number) -- '}'
    
    printf(fd_file_output, "</class>\n")
end procedure


-- deduction rule for classVarDec
procedure classVarDec(integer indent_number)
    printf(fd_file_output, "<classVarDec>\n")
    indent_number = indent_number + 1 -- increase indent number

    writeToFile(nextToken(), indent_number) -- 'static' |  'field'

    _type(indent_number) -- _type
    varName(indent_number) -- varName

    sequence pek = peek()
    while pek = "," do 
        writeToFile(nextToken(), indent_number) -- ','
        varName(indent_number) -- varName
        pek = peek()
    end while

    writeToFile(nextToken(), indent_number) -- ';'
    
    printf(fd_file_output, "</classVarDec>\n")
end procedure


-- deduction rule for type
procedure _type(integer indent_number)
    pek = peek()
    if pek = "int" or pek = "char" or pek = "boolean" then
        writeToFile(nextToken(), indent_number) -- 'int' or 'char' or 'boolean'
    else 
        className(indent_number) -- className
    end if

end procedure

-- deduction rule for subroutineDec
procedure subroutineDec(integer indent_number)
    printf(fd_file_output, "<subroutineDec>\n")
    indent_number = indent_number + 1 -- increase indent number

    writeToFile(nextToken(), indent_number) -- 'constructor' | 'function' | 'method'

    sequence pek = peek()
    if pek = "void" then
        writeToFile(nextToken(), indent_number) -- 'void'
    else
        _type(indent_number) -- _type
    end if
    
    subroutineName(indent_number) -- substroutineName
    
    writeToFile(nextToken(), indent_number) -- '('
    parameterList(indent_number) -- parameterList
    writeToFile(nextToken(), indent_number) -- ')'
    subroutineBody(indent_number) -- subroutineBody
    
    printf(fd_file_output, "</subroutineDec>\n")
end procedure

-- deduction rule for parameterList
procedure parameterList(integer indent_number)
    
end procedure

-- deduction rule for subroutineBody
procedure subroutineBody(integer indent_number)
    printf(fd_file_output, "<subroutineBody>\n")
    indent_number = indent_number + 1 -- increase indent number

    writeToFile(nextToken(), indent_number) -- '{'

    sequence pek = peek()
    while pek = "var" do 
        varDec(indent_number) -- varDec
        pek = peek()
    end while

    statements(indent_number) -- statements
    writeToFile(nextToken(), indent_number) -- '}'
    
    printf(fd_file_output, "</subroutineBody>\n")
end procedure

-- deduction rule for varDec
procedure varDec(integer indent_number)
    printf(fd_file_output, "<varDec>\n")
    indent_number = indent_number + 1 -- increase indent number

    _type(indent_number) -- type
    varName(indent_number) -- varName

    sequence pek = peek()
    while pek = "," do 
        writeToFile(nextToken(), indent_number) -- ','
        varName(indent_number) -- varName
        pek = peek()
    end while

    writeToFile(nextToken(), indent_number) -- ';'
    
    printf(fd_file_output, "</varDec>\n")
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
    sequence pek = peek()
    while pek = "let" or pek = "if" or pek = "while" or pek = "do" or "return" do 
        statement(indent_number) -- statement
        pek = peek()
    end while
end procedure

-- deduction rule for statement
procedure statement(integer indent_number)
    printf(fd_file_output, "<statement>\n")
    indent_number = indent_number + 1 -- increase indent number
    
    sequence pek = peek()
    if pek = "let" then
        letStatement(indent_number)
    elsif pek = "if" then
        ifStatement(indent_number)
    elsif pek = "while" then
        whileStatement(indent_number)
    elsif pek = "do" then
        doStatement(indent_number)
    elsif pek = "return" then
        ReturnStatement(indent_number)
    end if
    printf(fd_file_output, "</statement>\n")
end procedure

-- deduction rule for letStatement
procedure letStatement(integer indent_number)
    printf(fd_file_output, "<letStatement>\n")
    indent_number = indent_number + 1 -- increase indent number
    
    writeToFile(nextToken(), indent_number) -- 'let'
    varName(indent_number) -- 'varName'
    
    sequence pek = peek()
    if pek = '[' then
        writeToFile(nextToken(), indent_number) -- '['
        expression(indent_number)
        writeToFile(nextToken(), indent_number) -- ']'
    end if
    writeToFile(nextToken(), indent_number) -- '='
    expression(indent_number)
    writeToFile(nextToken(), indent_number) -- ';'

    printf(fd_file_output, "</letStatement>\n")
end procedure

-- deduction rule for ifStatement
procedure ifStatement(integer indent_number)
    writeToFile(nextToken(), indent_number) -- 'while'
    writeToFile(nextToken(), indent_number) -- '('
    expression(indent_number) -- expression
    writeToFile(nextToken(), indent_number) -- ')'
    writeToFile(nextToken(), indent_number) -- '{'
    statements(indent_number) -- statements
    writeToFile(nextToken(), indent_number) -- '}'
    
end procedure

-- deduction rule for whileStatement
procedure whileStatement(integer indent_number)
    writeToFile(nextToken(), indent_number) -- 'while'
    writeToFile(nextToken(), indent_number) -- '('
    expression(indent_number) -- expression
    writeToFile(nextToken(), indent_number) -- ')'
    writeToFile(nextToken(), indent_number) -- '{'
    statements(indent_number) -- statements
    writeToFile(nextToken(), indent_number) -- '}'

    subroutineCall(indent_number) -- subroutineCall
    writeToFile(nextToken(), indent_number) -- ';'
end procedure

-- deduction rule for doStatement
procedure doStatement(integer indent_number)
    writeToFile(nextToken(), indent_number) -- 'do'
    subroutineCall(indent_number) -- subroutineCall
    writeToFile(nextToken(), indent_number) -- ';'
end procedure

-- deduction rule for ReturnStatement
procedure ReturnStatement(integer indent_number)
    
end procedure

---------------------------------------------------------------------------------------------
-- Expressions
---------------------------------------------------------------------------------------------

-- deduction rule for expression
procedure expression(integer indent_number)
    printf(fd_file_output, "<expression>\n")
    indent_number = indent_number + 1 -- increase indent number
    term(indent_number) -- term
    sequence pek = peek()
    while pek = "+" or pek = "-" or pek = "*" or pek = "/" or pek = "&" or pek = "|" or pek = "<" or pek = ">" or pek = "=" 
    do 
        op(indent_number) -- op
        term(indent_number) -- term
        pek = peek()
    end while
    
    printf(fd_file_output, "</expression>\n")
end procedure

-- deduction rule for term
procedure term(integer indent_number)

end procedure

-- deduction rule for subroutineCall
procedure subroutineCall(integer indent_number)
    
end procedure

-- deduction rule for expressionList
procedure expressionList(integer indent_number)

end procedure

-- deduction rule for op
procedure op(integer indent_number)
    printf(fd_file_output, "<op>\n")
    indent_number = indent_number + 1 -- increase indent number
    
    writeToFile(nextToken(), indent_number) -- '+' or '-' or '* or '/' or '&' or '|' or '<' or '>' or '='   
     
    printf(fd_file_output, "</op>\n")

end procedure

-- deduction rule for unaryOp
procedure unaryOp(integer indent_number)
    printf(fd_file_output, "<unaryOp>\n")
    indent_number = indent_number + 1 -- increase indent number
    
    writeToFile(nextToken(), indent_number) -- '-' or '~'

    printf(fd_file_output, "</unaryOp>\n")
end procedure

-- deduction rule for KeywordConstant
procedure KeywordConstant(integer indent_number)
    printf(fd_file_output, "<KeywordConstant>\n")
    indent_number = indent_number + 1 -- increase indent number
    
    writeToFile(nextToken(), indent_number) -- 'true' or 'false' or 'null' or 'this'

    printf(fd_file_output, "</KeywordConstant>\n")
end procedure


