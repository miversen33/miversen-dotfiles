local function lazy_req(runner, config)
    local wrapper = {}
    local meta_wrapper = {}

    meta_wrapper.__index = function(_, k)
        local req_runner = require(runner)
        if config then
            req_runner = req_runner(config)
        end
        return req_runner[k]
    end

    setmetatable(wrapper, meta_wrapper)

    return wrapper
end

local neotest_opts = {
    adapters = {
       lazy_req("neotest-rust"),
       -- , {
       --     args = { "-E 'not test(/raw/)'" }
       -- }),
       lazy_req("neotest-go"),
       lazy_req("neotest-vitest"),
       lazy_req("neotest-bash"),
       lazy_req("neotest-haskell"),
       lazy_req("neotest-zig"),
       lazy_req("neotest-playwrite"),
       lazy_req("neotest-python"),
       lazy_req("neotest-java")
    }
}

local neotest = {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-lua/plenary.nvim",
        -- "antoinemadec/FixCursorHold.nvim",
        "rouge8/neotest-rust",
        "nvim-neotest/neotest-python",
        "rcasia/neotest-java",
        "lawrence-laz/neotest-zig",
        "nvim-neotest/nvim-nio",
        "nvim-neotest/neotest-go",
        "marilari88/neotest-vitest",
        "rcasia/neotest-bash",
        "mrcjkb/neotest-haskell",
        "thenbe/neotest-playwright",
    },
    config = true,
    opts = neotest_opts
}

return neotest


