
public enum SP,LCL,ARG,THIS,THAT,TEMP,R1,R2,R3,STATIC

public sequence labels = {
	"0", 	-- SP
	"1", 	-- LCL
	"2", 	-- ARG
	"3", 	-- THIS
    "4", 	-- THAT
	"5", 	-- TEMP
	"13", 	-- R1
	"14", 	-- R2
	"15", 	-- R3
    "16" 	-- STATIC
}

public sequence address = {
	"256", 		-- SP 
	"1536", 	-- LCL
	"1792", 	-- ARG
	"2048", 	-- THIS
    "8192", 	-- THAT
	"", 		-- TEMP
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
