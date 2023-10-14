local current_path = ... .. "."

local rust = {
    require(current_path .. "crates"),
}

return rust
