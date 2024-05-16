include std/io.e

procedure Main()
    sequence f = {}
    -- sequence 
    while f.size() do
        f += 1
        ? f
    end while
end procedure

Main()