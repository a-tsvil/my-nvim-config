(assignment_expression 
  left: (variable_name (name) @name (#eq? @name "sql")) 
  right: (heredoc 
           value: ((heredoc_body) @injection.content 
            (#set! injection.language "sql")
            (#set! injection.include-children)
           )))
