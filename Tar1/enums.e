
public enum SP,LCL,ARG,THIS,THAT,TEMP0,TEMP1,TEMP2,TEMP3,TEMP4,TEMP5,TEMP6,TEMP7,R1,R2,R3,STATIC

public sequence labels = {
	"SP", 		-- SP
	"LCL", 		-- LCL
	"ARG", 		-- ARG
	"THIS", 	-- THIS
    "THAT", 	-- THAT
	"5", 		-- TEMP0
	"6", 		-- TEMP1
	"7", 		-- TEMP2
	"8", 		-- TEMP3
	"9", 		-- TEMP4
	"10", 		-- TEMP5
	"11", 		-- TEMP6
	"12", 		-- TEMP7
	"13", 		-- R1
	"14", 		-- R2
	"15", 		-- R3
    "STATIC"  	-- STATIC
}

public sequence address = {
	"256", 		-- SP 
	"1536", 	-- LCL
	"1792", 	-- ARG
	"2048", 	-- THIS
    "8192", 	-- THAT
	"", 		-- TEMP0
	"", 		-- TEMP1
	"", 		-- TEMP2
	"", 		-- TEMP3
	"", 		-- TEMP4
	"", 		-- TEMP5
	"", 		-- TEMP6
	"", 		-- TEMP7
	"", 		-- R1
	"", 		-- R2
	"", 		-- R3
    ""			-- STATIC
}



public function mapCommendToLabels(sequence segment)
	switch segment do
	    case "local" then
			return LCL
		case "argument" then
            return ARG
        case "this" then
            return THIS
        case "that" then
            return THAT
        case else 
            return -1
	end switch
end function
