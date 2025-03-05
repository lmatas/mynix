return {
    "nvim-java/nvim-java",
    config = function()
        local java = require("java")    
        java.setup()
    end,
}
