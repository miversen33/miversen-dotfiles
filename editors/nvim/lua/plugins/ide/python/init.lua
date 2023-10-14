local current_path = ... .. "."

return {
    require(current_path .. "nvim_puppeteer"),
    require(current_path .. "vim_python_pep8_indent"),
    require(current_path .. "venv_selector")
}
