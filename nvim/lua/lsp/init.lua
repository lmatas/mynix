-- Nueva config LSP para Neovim 0.11+ usando vim.lsp.config
-- Sustituye todo tu archivo por esto

local capabilities = require("lsp.handlers").capabilities

-- Helper base para iniciar un LSP con capacidades por defecto
local function start_lsp(server, opts)
  opts = opts or {}

  -- mezcla capabilities por defecto con las opciones específicas
  opts = vim.tbl_deep_extend("force", {
    capabilities = capabilities,
  }, opts)

  vim.lsp.start(vim.lsp.config(server, opts))
end

-- Helper: autostart según FileType (equivalente a autostart = true)
local function setup_autostart(server, patterns, opts)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = patterns,
    callback = function()
      start_lsp(server, opts)
    end,
  })
end

-- Helper: inicio manual vía comando (equivalente a autostart = false)
local function setup_manual(server, command_name, opts)
  vim.api.nvim_create_user_command(command_name, function()
    start_lsp(server, opts)
  end, {})
end

-----------------------------------------------------------------------
-- Python - pyright (antes autostart = false)
-----------------------------------------------------------------------
setup_manual("pyright", "LspStartPyright", {
  -- si quisieras añadir cosas específicas, van aquí
  -- por ahora queda vacío para respetar tu config original
})

-----------------------------------------------------------------------
-- Lua - lua_ls (antes autostart = false)
-----------------------------------------------------------------------
setup_manual("lua_ls", "LspStartLuaLS", {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

-----------------------------------------------------------------------
-- Rust - rust_analyzer
-----------------------------------------------------------------------
setup_autostart("rust_analyzer", { "rust" }, {
  on_attach = function(client, bufnr)
    require("lsp.handlers").on_attach(client, bufnr)
    -- si quieres activar inlay hints:
    -- vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end,
  settings = {
    ["rust-analyzer"] = {
      diagnostics = {
        enable = true,
      },
      imports = {
        granularity = {
          group = "module",
        },
        prefix = "self",
      },
      cargo = {
        buildScripts = {
          enable = true,
        },
      },
      procMacro = {
        enable = true,
      },
    },
  },
})

-----------------------------------------------------------------------
-- C / C++ - clangd
-----------------------------------------------------------------------
setup_autostart("clangd", { "c", "cpp", "objc", "objcpp" }, {
  -- sin opciones adicionales
})

-----------------------------------------------------------------------
-- Bash - bashls (antes autostart = false)
-----------------------------------------------------------------------
setup_manual("bashls", "LspStartBash", {
  -- sin opciones adicionales
})

-----------------------------------------------------------------------
-- Javascript / Typescript - eslint
-----------------------------------------------------------------------
setup_autostart("eslint", {
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  -- añade más filetypes si quieres
}, {
  settings = {
    packageManager = "npm",
  },
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  end,
})

-----------------------------------------------------------------------
-- HTML - html (antes autostart = false)
-----------------------------------------------------------------------
setup_manual("html", "LspStartHtml", {
  -- capabilities se añaden automáticamente por start_lsp
})

-----------------------------------------------------------------------
-- CSS - cssls (antes autostart = false)
-----------------------------------------------------------------------
setup_manual("cssls", "LspStartCss", {
  -- sin opciones extra
})

-----------------------------------------------------------------------
-- Dockerfile - dockerls (antes autostart = false)
-----------------------------------------------------------------------
setup_manual("dockerls", "LspStartDocker", {
  -- sin opciones extra
})

-----------------------------------------------------------------------
-- Docker Compose - docker_compose_language_service (antes autostart = false)
-----------------------------------------------------------------------
setup_manual("docker_compose_language_service", "LspStartDockerCompose", {
  -- sin opciones extra
})

-----------------------------------------------------------------------
-- XML - lemminx
-----------------------------------------------------------------------
setup_autostart("lemminx", { "xml", "xsd", "xsl", "xslt", "svg" }, {
  -- sin opciones extra
})

-----------------------------------------------------------------------
-- Vue - vuels
-----------------------------------------------------------------------
setup_autostart("vuels", { "vue" }, {
  -- sin opciones extra
})
