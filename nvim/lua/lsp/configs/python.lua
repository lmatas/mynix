return {
    "mfussenegger/nvim-dap-python",
	ft = { "py" },
    config = function()
        require("dap-python").setup("python3")
    end,
}
