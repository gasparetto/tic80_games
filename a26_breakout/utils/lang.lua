-----------------------------------------------------------
-- UTILS LANG

local utils_lang = {}

function utils_lang.table_print(tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs(tt) do
      table.insert(sb, string.rep(" ", indent))
      if type(value) == "table" and not done[value] then
        done[value] = true
        table.insert(sb, key .. " = {\n");
        table.insert(sb, table_print(value, indent + 2,
          done))
        table.insert(sb, string.rep(" ", indent))
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("%s,\n",
          tostring(value)))
      else
        if "number" == type(key) then
          table.insert(sb, string.format("%s = %s,\n",
            tostring(key), tostring(value)))
        else
          table.insert(sb, string.format("%s = \"%s\",\n",
            tostring(key), tostring(value)))
        end
      end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end

function utils_lang.table_deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[utils_lang.table_deepcopy(orig_key)] =
      utils_lang.table_deepcopy(orig_value)
    end
    setmetatable(copy,
      utils_lang.table_deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

function utils_lang.trace_t(table, name)
  name = name or table
  trace(name .. " =\n{\n"
    .. utils_lang.table_print(table, 2) .. "}\n")
end

