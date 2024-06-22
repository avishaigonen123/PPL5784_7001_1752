include xml/euXML25.e
include std/io.e
include std/types.e
include std/search.e

sequence keywords = {
    "class", "constructor", "function", "method", "field", "static", "var", "int", "char", "boolean", "void", "true", "false", "null", "this", "let", "do", "if", "else", "while", "return"
}

sequence symbol = {
    '{', '}', '(', ')', '[', ']', '.', ',', ';', '+', '-', '*', '/', '&', '|', '<', '>', '=', '~'
}

procedure writeToXml(integer fd_file_output, sequence _type, sequence _value)
    sequence output = "<" & _type & "> " & _value & " </" & _type & ">" & '\n'
    printf(fd_file_output, output)
end procedure

public procedure tokenizeAnalyser(integer fd_file_input, integer fd_file_output)
    atom char = getc(fd_file_input)
    sequence temp = ""
    printf(fd_file_output, "<tokens>\n")
    while char != EOF do
        if t_digit(char) then -- case number

            temp = temp & char
            char = getc(fd_file_input)
            while t_digit(char) do
                temp = temp & char
                char = getc(fd_file_input)
            end while
            writeToXml(fd_file_output, "integerConstant", temp)
        -- ----------------------------------------------------------------

        -- ----------------------------------------------------------------
        elsif char = '\"' then -- case '"'
            char = getc(fd_file_input)
            while char != '\"' do
                temp = temp & char
                char = getc(fd_file_input)
            end while
            char = getc(fd_file_input)
            writeToXml(fd_file_output, "stringConstant", temp)
        -- ----------------------------------------------------------------
        
        -- ----------------------------------------------------------------
        elsif is_in_list(char, symbol) then -- case symbol
            if char = '/' then -- symbol is '/'
                char = getc(fd_file_input)
                if char = '/' then -- next symbol is '/'
                    while char != '\n' do 
                        char = getc(fd_file_input)
                    end while
                elsif char = '*' then -- next symbol is '*'
                    char = getc(fd_file_input)
                    while TRUE label "searchingLoop" do 
                        if char = '*' then
                            char = getc(fd_file_input)
                            if char = '/' then
                                char = getc(fd_file_input)
                                exit "searchingLoop" 
                            end if
                        else
                            char = getc(fd_file_input)
                        end if
                    end while
                else 
                    writeToXml(fd_file_output, "symbol", "/")
                end if
            else -- symbol isn't '/'
                if char = '<' then
                    writeToXml(fd_file_output, "symbol", "&lt;")
                elsif char = '>' then
                    writeToXml(fd_file_output, "symbol", "&gt;")
                elsif char = '\"' then
                    writeToXml(fd_file_output, "symbol", "&quot;")
                elsif char = '&' then
                    writeToXml(fd_file_output, "symbol", "&amp;")
                else 
                    writeToXml(fd_file_output, "symbol", {char})
                end if
                char = getc(fd_file_input)
            end if
        -- ----------------------------------------------------------------

        -- ----------------------------------------------------------------
        elsif char = '_' or t_alpha(char) then -- case '_' or character
            temp = temp & char
            char = getc(fd_file_input)
            while char = '_' or t_alpha(char) or t_digit(char) do -- char is  '_' or character or digit
                temp = temp & char
                char = getc(fd_file_input)
            end while
            if is_in_list(temp, keywords) then             
                writeToXml(fd_file_output, "keyword", temp)
            else
                writeToXml(fd_file_output, "identifier", temp)
            end if
        -- ----------------------------------------------------------------

        -- ----------------------------------------------------------------
        else -- white space
            char = getc(fd_file_input)
        end if
        temp = ""
        
    end while
    printf(fd_file_output, "</tokens>\n")
end procedure 