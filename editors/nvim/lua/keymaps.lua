local setup = function(debug_mode)
    import('core_keymaps')
    if not debug_mode then
        import('plug_keymaps')
    end
end

return {
    setup = setup
}
