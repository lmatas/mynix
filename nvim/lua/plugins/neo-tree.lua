return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
	  "nvim-lua/plenary.nvim",
	  "nvim-tree/nvim-web-devicons", -- opcional pero recomendado
	  "MunifTanjim/nui.nvim",
	},
	config = function()
	  require("neo-tree").setup({
		filesystem = {
		  filtered_items = {
			visible = true,  -- Mostrar archivos ocultos por defecto
			hide_dotfiles = false,  -- No ocultar archivos que empiezan con punto
			hide_gitignored = false,  -- No ocultar archivos ignorados por git
			never_show = {  -- Nunca mostrar estos archivos/carpetas
			  ".DS_Store",
			  ".AppleDouble",
			  ".LSOverride",
			  ".Spotlight-V100",
			  ".Trashes",
			  ".fseventsd",
			  "__MACOSX",
			  "Icon\r",
			  "._*"  -- Archivos de recursos de macOS
			},
		  },
		  follow_current_file = {
			enabled = true,  -- Sigue al archivo actual al cambiar de buffer
		  },
		  use_libuv_file_watcher = true,  -- Para mejor rendimiento
		},
	  })

	  vim.keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>", {})
	  vim.keymap.set("n", "<leader>be", ":Neotree git_status reveal float<CR>", { silent = true, desc = "Estado de Git en ventana flotante" })
      vim.keymap.set("n", "<leader>br", ":Neotree filesystem reveal right<CR>", { silent = true, desc = "Explorador de archivos a la derecha" })

	  vim.keymap.set("n", "<C-n>", function()
        if vim.bo.filetype == "neo-tree" then
          vim.cmd("Neotree close")
        else
          vim.cmd("Neotree filesystem reveal left")
        end
      end, { silent = true, desc = "Alternar Neo-tree" })

	end,
  }