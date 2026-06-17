-- Lua filter: reformat H3 + following employer/date paragraph
-- into \jobentry{Role}{Employer}{Date} raw LaTeX

function Blocks(blocks)
  local result = {}
  local i = 1
  while i <= #blocks do
    local block = blocks[i]
    -- Check if this is a level-3 header
    if block.t == "Header" and block.level == 3 then
      -- Look ahead for the next Para
      local next = blocks[i+1]
      if next and next.t == "Para" then
        -- Try to extract "Employer, date" where date is Emph
        local inlines = next.content
        -- Find the last Emph element (the date)
        local date_str = nil
        local employer_inlines = {}
        local found_emph = false
        for j = #inlines, 1, -1 do
          local el = inlines[j]
          if not found_emph and el.t == "Emph" then
            -- Extract text from emph
            date_str = pandoc.utils.stringify(el)
            found_emph = true
          elseif found_emph then
            -- everything before the emph is the employer (in reverse)
            table.insert(employer_inlines, 1, inlines[j])
          end
        end
        if found_emph and date_str then
          -- Strip trailing comma+space from employer
          local employer_str = pandoc.utils.stringify(pandoc.Inlines(employer_inlines))
          employer_str = employer_str:gsub("[,%s]+$", "")
          -- Get role text
          local role_str = pandoc.utils.stringify(block)
          -- Emit raw LaTeX jobentry
          local tex = string.format(
            "\\jobentry{%s}{%s}{%s}",
            role_str, employer_str, date_str
          )
          table.insert(result, pandoc.RawBlock("latex", tex))
          i = i + 2  -- skip both header and para
        else
          table.insert(result, block)
          i = i + 1
        end
      else
        table.insert(result, block)
        i = i + 1
      end
    else
      table.insert(result, block)
      i = i + 1
    end
  end
  return result
end
