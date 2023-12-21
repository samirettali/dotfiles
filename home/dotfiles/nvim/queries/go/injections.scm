(short_var_declaration
    left: (expression_list
            (identifier) @_id (#match? @_id "query"))
    right: (expression_list
             (raw_string_literal) @sql (#offset! @sql 0 1 0 -1)))
