(lexical_declaration
  (variable_declarator
    name: (identifier) @name (#eq? @name "sql")
    value: (string (string_fragment) @injection.content 
            (#set! injection.language "sql")
            (#set! injection.include-children)
)))
