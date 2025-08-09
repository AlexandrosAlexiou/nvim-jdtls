if vim.g.nvim_jdtls then
  return
end
vim.g.nvim_jdtls = 1

-- Create commands (these stay regardless of filetype)
vim.api.nvim_create_user_command("JdtWipeDataAndRestart", function()
  require("jdtls.setup").wipe_data_and_restart()
end, {})

vim.api.nvim_create_user_command("JdtShowLogs", function()
  require("jdtls.setup").show_logs()
end, {})

-- Create a group for JDTLS handlers
local jdtls_handler_group = vim.api.nvim_create_augroup("JdtlsHandlers", { clear = true })

-- Function to register JDTLS handlers
local function register_handlers()
  -- Clear any existing handlers in this group
  vim.api.nvim_clear_autocmds({ group = jdtls_handler_group })

  -- Helper function to handle class files and URIs
  local function handle_class_file(path)
    local success, result = pcall(require("jdtls").open_classfile, path)
    if not success then
      return false
    end
    return result
  end

  -- Register handlers for various patterns
  local patterns = {
    "jdt://*",
    "*.class",
  }

  for _, pattern in ipairs(patterns) do
    vim.api.nvim_create_autocmd("BufReadCmd", {
      pattern = pattern,
      group = jdtls_handler_group,
      callback = function()
        local path = vim.fn.expand("<amatch>")
        return handle_class_file(path)
      end,
    })
  end
end

-- Register handlers when entering Java files
local filetype_group = vim.api.nvim_create_augroup("JavaFiletypeHandlers", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  group = filetype_group,
  callback = function()
    register_handlers()
  end,
})

-- Register handlers right away if we're in a Java file
if vim.bo.filetype == "java" then
  register_handlers()
end
