-- Taken from diagram.lua

local function properties_from_code(code, comment_start)
    local props = {}
    local pattern = comment_start:gsub("%p", "%%%1") .. "| " .. "([-_%w]+): ([^\n]*)\n"
    for key, value in code:gmatch(pattern) do
        if key == "fig-cap" then
            props["caption"] = value
        else
            props[key] = value
        end
    end
    return props
end

local function diagram_options(cb, comment_start)
    local attribs = comment_start and properties_from_code(cb.text, comment_start) or {}
    for key, value in pairs(cb.attributes) do
        attribs[key] = value
    end

    local alt
    local caption
    local fig_attr = {id = cb.identifier}
    local filename
    local image_attr = {}
    local user_opt = {}

    for attr_name, value in pairs(attribs) do
        if attr_name == "alt" then
            alt = value
        elseif attr_name == "caption" then
            -- Read caption attribute as Markdown
            caption = attribs.caption and pandoc.read(attribs.caption).blocks or nil
        elseif attr_name == "filename" then
            filename = value
        elseif attr_name == "label" then
            fig_attr.id = value
        elseif attr_name == "name" then
            fig_attr.name = value
        else
            -- Check for prefixed attributes
            local prefix, key = attr_name:match "^(%a+)%-(%a[-%w]*)$"
            if prefix == "fig" then
                fig_attr[key] = value
            elseif prefix == "image" or prefix == "img" then
                image_attr[key] = value
            elseif prefix == "opt" then
                user_opt[key] = value
            else
                -- Use as image attribute
                image_attr[attr_name] = value
            end
        end
    end
    return {
        ["alt"] = alt or (caption and pandoc.utils.blocks_to_inlines(caption)) or {},
        ["caption"] = caption,
        ["fig-attr"] = fig_attr,
        ["filename"] = filename,
        ["image-attr"] = image_attr,
        ["opt"] = user_opt
    }
end

function CodeBlock(el)
    if el.attr.classes[1] == "pysvg" then
        local data = pandoc.pipe("python", {"-"}, "from tools.pysvg import *\n" .. el.text)
        local fname = pandoc.sha1(data)
        pandoc.mediabag.insert(fname, "image/svg+xml", data)
        local dgr_opt = diagram_options(el, "#")
        local image = pandoc.Image(dgr_opt.alt, fname, "", dgr_opt["image-attr"])
        return dgr_opt.caption and pandoc.Figure(pandoc.Plain {image}, dgr_opt.caption, dgr_opt["fig-attr"]) or
            pandoc.Plain {image}
    end
end
