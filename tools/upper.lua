local text = require('text')

function Header(el)
    if el.level == 1 and FORMAT == 'docx' then
        return pandoc.walk_block(el, {
        Str = function(el)
            return pandoc.Str(text.upper(el.text))
        end })
    end
end

function Blocks(blocks)
    local hblocks = {}
    for i, el in pairs(blocks) do
        if el.t == "Header" and el.level == 1 then
            table.insert(hblocks, pandoc.RawBlock("tex","\\newpage"))
        end
        table.insert(hblocks, el)
    end
    return hblocks
end