include std/sequence.e

sequence ClassScopeST = {}
sequence SubrottinScopeST = {}

integer subrottinIndex = 0
integer ClassIndex = 0

procedure startSubroutine()
    SubrottinScopeST = {}
    subrottinIndex = 0
end procedure

-- add to the symbol table
-- name: the name of the identifier
-- IDType: the type of the identifier (int, string, etc)
-- kind: the kind of the identifier (STATIC, FIELD, ARG, VAR)
procedure define(sequence name, sequence IDType, sequence kind)
    switch kind do
        case "ARG", "VAR" then
            SubrottinScopeST &= {{name, IDType, kind, subrottinIndex}}
            subrottinIndex += 1
            break
        case "STATIC", "FIELD" then
            ClassScopeST &= {{name, IDType, kind, ClassIndex}}
            ClassIndex += 1
            break
    end switch
end procedure