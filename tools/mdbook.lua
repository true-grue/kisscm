function Meta(meta)
    biburl = meta.biburl
    return meta
end

function Link(el)
    if el.target:match '^#' then
        el.target = biburl .. el.target
    end
    return el
end

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
        local tree = pandoc.Pandoc(el.content[1].content)
        local text = pandoc.write(tree, 'html'):gsub('\n+', ' ')
        local html = '<p id="' .. el.identifier .. '">' .. text .. '</p>'
        return pandoc.RawBlock('html', html)
    end
    -- Remove other containers.
    if el.identifier ~= "" then
        return el.content
    end
    return el
end

return {
  { Meta = Meta },
  { Link = Link, Math = Math, Div = Div }
}
