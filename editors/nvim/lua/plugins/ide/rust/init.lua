local current_path = ... .. "."

local rust = {
    require(current_path .. "crates"),
    require(current_path .. "rustaceanvim")
}

return rust
