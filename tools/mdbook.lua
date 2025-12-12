function Math(m)
    -- MdBook uses \( x \) notation instead of $ x $ for inline math.
    if m.mathtype == "InlineMath" then
        return pandoc.Str('\\(' .. m.text .. '\\)')
    end
    return m
end

function Div(el)
    -- Convert references to paragraphs with id.
    if el.classes:includes('csl-entry') then
        local text = pandoc.utils.stringify(el.content[1].content)
        local html = '<p id="' .. el.identifier .. '">' .. text .. '</p>'
        return pandoc.RawBlock('html', html)
    end
    -- Remove other containers.
    if el.identifier ~= "" then
        return el.content
    end
    return el
end
