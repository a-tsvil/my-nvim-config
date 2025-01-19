(short_var_declaration 
	left: (expression_list ((identifier) @name (#eq? @name "sql")))
	right: ((expression_list (interpreted_string_literal (interpreted_string_literal_content) @injection.content
            (#set! injection.language "sql")
			(#set! injection.include-children)))))
