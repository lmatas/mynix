 -- Configuración para mostrar archivos ocultos excepto los de macOS
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
