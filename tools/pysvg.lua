-- Taken from diagram.lua

local function diagram_options(cb)
    local attribs = cb.attributes or {}
    local caption = attribs.caption and pandoc.read(attribs.caption).blocks
    local image_attrs = {}
    for attr, value in pairs(attribs) do
        if attr ~= "caption" then image_attrs[attr] = value end
    end
    return {
        alt = caption and pandoc.utils.blocks_to_inlines(caption) or {},
        caption = caption,
        figure_attrs = {id = cb.identifier},
        image_attrs = image_attrs
    }
end

function CodeBlock(el)
    if el.attr.classes[1] == "pysvg" then
        local svg = pandoc.pipe("python", {"-"}, "from tools.pysvg import *\n" .. el.text)
        local fname = pandoc.sha1(svg) .. ".svg"
        pandoc.mediabag.insert(fname, "image/svg+xml", svg)
        local options = diagram_options(el)
        local image = pandoc.Image(options.alt, fname, "", options.image_attrs)
        local plain = pandoc.Plain {image}
        return options.caption and
            pandoc.Figure(plain, options.caption, options.figure_attrs) or
            plain
    end
end
