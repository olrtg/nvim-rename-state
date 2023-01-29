local M = {}

M.upperfirst = function(text)
  return string.sub(text, 1, 1):upper() .. string.sub(text, 2)
end

return M
