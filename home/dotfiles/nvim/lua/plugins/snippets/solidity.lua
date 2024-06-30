local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

-- // SPDX-License-Identifier: UNLICENSED
-- pragma solidity ^0.8.13;

ls.add_snippets("sol", {
    s("lic", {
        t({ "SPDX-License-Identifier: MIT" }),
        i(0),
    })
})

ls.add_snippets("sol", {
    s("pra", {
        t({ "pragma solidity " }),
        i(1),
    })
})
