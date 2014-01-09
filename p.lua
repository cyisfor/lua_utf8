-- global p
function p(...) 
    local s = nil
    for _,v in ipairs({...}) do
        if s == nil then
            s = ""
        else
            s = s .. " "
        end
        if type(v) == 'string' then
            s = s .. v
        elseif type(v) == 'number' then
            s = s .. string.format('%x',v)
        else
            s = s .. tostring(v)
        end
    end
    print(s)
end

