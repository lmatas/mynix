return {
    "rcarriga/nvim-notify",
    config = function()
      local notify = require("notify")
      notify.setup({
        stages = "fade_in_slide_out",  -- Animación suave
        timeout = 3000,  -- Duración de la notificación (en ms)
        background_colour = "#1e1e2e",  -- Color de fondo
        render = "default",  -- Estilo de renderizado
      })
      vim.notify = notify  -- Reemplaza las notificaciones predeterminadas de Neovim
    end
  }
