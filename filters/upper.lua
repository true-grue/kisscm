-- we use preloaded text to get a UTF-8 aware 'upper' function
local text = require('text')

function Header(el)
    if el.level == 1 then
      return pandoc.walk_block(el, {
        Str = function(el)
            return pandoc.Str(text.upper(el.text))
        end })
    end
end
