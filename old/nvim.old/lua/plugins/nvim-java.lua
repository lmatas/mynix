return {
    "nvim-java/nvim-java",
    dependencies = {
        "nvim-java/lua-async-await",
        "nvim-java/nvim-java-core",
        "nvim-java/nvim-java-test",
        "nvim-java/nvim-java-dap",
        "MunifTanjim/nui.nvim",
        "neovim/nvim-lspconfig",
        "mfussenegger/nvim-dap",
        "williamboman/mason.nvim",
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "mfussenegger/nvim-jdtls"
    },
    config = function()
        require("java").setup({
            -- Configuración del JDK (descomenta y ajusta las rutas según tu sistema)
            -- jdk = {
            --     java_executable = "/nix/store/g088wj35sp5p0013ccplx41n9h0jlmi6-openjdk-11.0.21+9/bin/java",
            --     jdk_home = "/nix/store/g088wj35sp5p0013ccplx41n9h0jlmi6-openjdk-11.0.21+9",
            -- },
            
            -- Configuración de depuración
            dap = {
                enable = true,
            },
            
            -- Configuración de LSP
            lsp = {
                setup = {
                    cmd = { "jdtls" },
                }
            }
        })

        require("lspconfig").jdtls.setup ({})
        
        -- Key bindings específicos para Java
        -- Navegación de código
        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "java" },
            callback = function()
                -- Acciones de código y navegación
                vim.keymap.set("n", "<leader>oi", function() require("jdtls").organize_imports() end, 
                    { buffer = 0, desc = "Organizar imports" })
                vim.keymap.set("n", "<leader>jc", function() require("java").compile() end, 
                    { buffer = 0, desc = "Compilar proyecto Java" })
                vim.keymap.set("n", "<leader>jt", function() require("java").test_class() end, 
                    { buffer = 0, desc = "Ejecutar test de clase" })
                vim.keymap.set("n", "<leader>jm", function() require("java").test_nearest_method() end, 
                    { buffer = 0, desc = "Ejecutar test del método" })
                vim.keymap.set("n", "<leader>jf", function() require("jdtls").test_class() end, 
                    { buffer = 0, desc = "Ejecutar clase actual" })
                
                -- Refactoring
                vim.keymap.set("n", "<leader>jR", function() require("jdtls").code_action(false, "refactor") end, 
                    { buffer = 0, desc = "Acción de refactorización" })
                vim.keymap.set("v", "<leader>jx", function() require("jdtls").extract_variable(true) end, 
                    { buffer = 0, desc = "Extraer variable" })
                vim.keymap.set("v", "<leader>jm", function() require("jdtls").extract_method(true) end, 
                    { buffer = 0, desc = "Extraer método" })

                -- Debugging
                vim.keymap.set("n", "<leader>db", function() require("dap").toggle_breakpoint() end, 
                    { buffer = 0, desc = "Toggle breakpoint" })
                vim.keymap.set("n", "<leader>dr", function() require("dap").repl.open() end, 
                    { buffer = 0, desc = "Abrir REPL de depuración" })
                vim.keymap.set("n", "<leader>dc", function() require("dap").continue() end, 
                    { buffer = 0, desc = "Continuar depuración" })
                vim.keymap.set("n", "<leader>do", function() require("dap").step_over() end, 
                    { buffer = 0, desc = "Step over" })
                vim.keymap.set("n", "<leader>di", function() require("dap").step_into() end, 
                    { buffer = 0, desc = "Step into" })
                vim.keymap.set("n", "<leader>du", function() require("dapui").toggle() end, 
                    { buffer = 0, desc = "Toggle DAP UI" })
                
                -- JavaDoc generation
                vim.keymap.set("n", "<leader>jd", function() require("java").generate_javadoc() end, 
                    { buffer = 0, desc = "Generar JavaDoc" })
                    
                -- Smart code actions
                vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end,
                    { buffer = 0, desc = "Mostrar acciones de código" })

                -- Project management
                vim.keymap.set("n", "<leader>jp", function() require("java").open_jdt_import_wizard() end, 
                    { buffer = 0, desc = "Importar proyecto Java" })
                    
                -- Show project structure/outline
                vim.keymap.set("n", "<leader>jo", function() require("java").show_outline() end, 
                    { buffer = 0, desc = "Mostrar estructura del proyecto" })
                    
                print("Java keybindings loaded!")
            end,
        })
        
        -- Configuración de DAP UI (opcional pero recomendado)
        require("dapui").setup({
            icons = { expanded = "▾", collapsed = "▸" },
            mappings = {
                expand = { "<CR>", "<2-LeftMouse>" },
                open = "o",
                remove = "d",
                edit = "e",
                repl = "r",
                toggle = "t",
            },
            layouts = {
                {
                    elements = {
                        "scopes",
                        "breakpoints",
                        "stacks",
                        "watches",
                    },
                    size = 40,
                    position = "left",
                },
                {
                    elements = {
                        "repl",
                        "console",
                    },
                    size = 10,
                    position = "bottom",
                },
            },
            floating = {
                max_height = nil,
                max_width = nil,
                border = "single",
                mappings = {
                    close = { "q", "<Esc>" },
                },
            },
            windows = { indent = 1 },
            render = {
                max_type_length = nil,
            },
        })
        
        -- Conectar DAP con DAP UI
        local dap = require("dap")
        dap.listeners.after.event_initialized["dapui_config"] = function()
            require("dapui").open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
            require("dapui").close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
            require("dapui").close()
        end
    end,
}