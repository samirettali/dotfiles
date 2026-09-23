; extends

((short_var_declaration
  left: (expression_list
    (identifier) @_id
    (#match? @_id "query"))
  right: (expression_list
    (raw_string_literal
      (raw_string_literal_content) @injection.content)))
  (#set! injection.language "sql"))
