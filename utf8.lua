bit32 = bit32 or bit

local function longEncode(codepoint)
    local chars = ""
    local trailers = 0
    local ocodepoint = codepoint

    -- feckin backwards compatability
    if codepoint < 0x80 then return string.char(codepoint) end

    topspace = 0x20 -- we lose a bit of space left on the top every time

    -- even if the codepoint is <0x40 and will fit inside 10xxxxxx, 
    -- we add a 11100000  byte in front, because it won't fit inside
    -- 0x20 xxxxx so we need a blank top and an extra continuation.
    -- example: 0x90b
    -- bit.rshift(0x90b,6) => 0x24
    -- 0x24 = 00100100
    -- top =  11100000
    --          ^ oh noes info lost
    -- thus we do:
    --        11100000 - 10100100 - ...
    --
    while codepoint > topspace do -- as long as there's too much for the top
        local derp = bit32.bor(bit32.band(codepoint,0x3F),0x80)
        chars = string.char(derp) .. chars
        codepoint = bit32.rshift(codepoint,6)
        trailers = trailers + 1
        topspace = bit32.rshift(topspace,1)
    end

    -- is there a better way to make 0xFFFF0000 from 4 than lshift/rshift?
    local mask = bit32.lshift(bit32.rshift(0xFF,7-trailers),7-trailers)

    local last = bit32.bor(mask,codepoint)
    return string.char(last) .. chars
end

return {
    encode = function(t,derp,...)
        if derp ~= nil then
            t = {t,derp,...}
        end
        local s = ""
        for i,codepoint in ipairs(t) do
            -- manually doing the common codepoints to avoid calling logarithm
            if codepoint < 0x80 then
                derp = string.char(codepoint)
            elseif codepoint < 0x800 then
                derp = string.char(bit32.bor(bit32.rshift(codepoint,6),0xc0)) .. 
                    string.char(bit32.bor(bit32.band(codepoint,0x3F),0x80))   
            elseif codepoint < 0x10000 then
                derp = string.char(bit32.bor(bit32.rshift(codepoint,12),0xe0)) ..
                    string.char(bit32.bor(bit32.band(bit32.rshift(codepoint,6),0x3F),0x80)) ..
                    string.char(bit32.bor(bit32.band(codepoint,0x3F),0x80))
            elseif codepoint < 0x200000 then
                derp = string.char(bit32.bor(bit32.rshift(codepoint,18),0xf0)) ..
                    string.char(bit32.bor(bit32.band(bit32.rshift(codepoint,12),0x3F),0x80)) ..
                    string.char(bit32.bor(bit32.band(bit32.rshift(codepoint,6),0x3F),0x80)) ..
                    string.char(bit32.bor(bit32.band(codepoint,0x3F),0x80))
            else
                -- alpha centauri?!
                derp = longEncode(codepoint)
            end
            s = s .. derp
        end
        return s
    end,
    -- got decode from http://lua-users.org/wiki/LuaUnicode
    decode = function(s)            
        assert(type(s) == "string")
        local res, seq, val = {}, 0, nil
        for i = 1, #s do
            local c = string.byte(s, i)
            if seq == 0 then
                table.insert(res, val)
                seq = c < 0x80 and 1 or c < 0xE0 and 2 or c < 0xF0 and 3 or
                      c < 0xF8 and 4 or c < 0xFC and 5 or c < 0xFE and 6 or
                      error("invalid UTF-8 character sequence")
                val = bit32.band(c, 2^(8-seq) - 1)
            else
                val = bit32.bor(bit32.lshift(val, 6), bit32.band(c, 0x3F))
            end
            seq = seq - 1
        end
        table.insert(res, val)
        --table.insert(res, 0)
        return res
    end,

    longEncode = function (t)
        local s = ""
        for i,codepoint in ipairs(t) do
            s = s .. longEncode(codepoint)
        end
        return s
    end
}
