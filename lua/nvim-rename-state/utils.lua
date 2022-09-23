local M = {}

M.startswith = function(text, prefix)
  return text:find(prefix, 1, true) == 1
end

M.chopstart = function(text, prefix)
  return string.sub(text, string.len(prefix) + 1, string.len(text))
end

M.upperfirst = function(text)
  return string.sub(text, 1, 1):upper() .. string.sub(text, 2)
end

M.lowerfirst = function(text)
  return string.sub(text, 1, 1):lower() .. string.sub(text, 2)
end

return M
