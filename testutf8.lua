require('p')

local utf8 = require('utf8')
--local weird = {0x90b,0x2D32,0x10398,47,37,57,0x20AC}
local weird = {0x2D32,0x10398,0x90b,47,37,57,0x20AC}

local s = utf8.encode({0x20AC})
for i = 1,string.len(s) do
    p(i,string.byte(string.sub(s,i,i+1)))
end

eh = 'é'
p(eh)
assert(utf8.encode(utf8.decode(eh))==eh)
p(utf8.encode(utf8.decode("é")))
for n,v in ipairs(utf8.decode("é")) do
    p('beep',v)
end

local function equalderp(a,b)
    if #a ~= #b then 
        p('length',#a,#b)
        return false 
    end
    for i,v in ipairs(a) do
        if a[i] ~= b[i] then 
            p('i',a[i],b[i])
            return false 
        end
    end
    return true
end

local a = utf8.longEncode(weird)
local b = utf8.encode(weird)
p(a)
p(b)
assert(a==b)
