return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    opts = {
      auto_install = true,
    },
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      local lspconfig = require("lspconfig")
      lspconfig.ts_ls.setup({
        capabilities = capabilities
      })
      lspconfig.solargraph.setup({
        capabilities = capabilities
      })
      lspconfig.html.setup({
        capabilities = capabilities
      })
      lspconfig.lua_ls.setup({
        capabilities = capabilities
      })

        -- Añadir configuración para Python (Pyright)
        lspconfig.pyright.setup({
          capabilities = capabilities,
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                useLibraryCodeForTypes = true,
                typeCheckingMode = "basic"
              }
            }
          }
        })

        --  -- Configuración para Java (jdtls)
        --  lspconfig.jdtls.setup({
        --   capabilities = capabilities,
        --   cmd = { "jdtls" },
        --   root_dir = function(fname)
        --     return require("lspconfig.util").root_pattern(
        --       "pom.xml",
        --       "gradle.build",
        --       "build.gradle",
        --       ".git"
        --     )(fname) or vim.fn.getcwd()
        --   end,
        --   settings = {
        --     java = {
        --       signatureHelp = { enabled = true },
        --       contentProvider = { preferred = "fernflower" },
        --       completion = {
        --         favoriteStaticMembers = {
        --           "org.junit.Assert.*",
        --           "org.junit.Assume.*",
        --           "org.junit.jupiter.api.Assertions.*",
        --           "org.junit.jupiter.api.Assumptions.*",
        --           "org.junit.jupiter.api.DynamicContainer.*",
        --           "org.junit.jupiter.api.DynamicTest.*",
        --         },
        --       },
        --       sources = {
        --         organizeImports = {
        --           starThreshold = 9999,
        --           staticStarThreshold = 9999,
        --         },
        --       },
        --       codeGeneration = {
        --         toString = {
        --           template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
        --         },
        --         useBlocks = true,
        --       },
        --       -- runtimes = {
        --       --   {
        --       --     name = "JavaSE-17",
        --       --     path = "/usr/lib/jvm/java-17-openjdk/",
        --       --   },
        --       -- }
        --     },
        --   },
        -- })

      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
    end,
  },
}
