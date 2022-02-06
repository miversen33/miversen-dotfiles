local setup = function(debug_mode)
    require('core_keymaps')
    if not debug_mode then
        require('plug_keymaps')
    end
end

return {
    setup = setup
}
