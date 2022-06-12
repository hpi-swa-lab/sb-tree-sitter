Class {
	#name : #SBJavascript,
	#superclass : #SBTSLanguage,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'configuration - declarations' }
SBJavascript class >> declarationsInScope: aScopeBlock do: aClosure [

	aScopeBlock type = 'function' ifTrue: [
		aScopeBlock childSandblocksDo: [:block | ((block compatibleWithType: 'pattern') or: [block compatibleWithType: 'assignment_pattern']) ifTrue: [block allBlocksDo: [:b | b type = 'identifier' ifTrue: [aClosure value: (SBTSDeclaration block: b label: 'func arg')]]]].
		self declarationsInScope: (aScopeBlock get: 'body') do: aClosure].
	(aScopeBlock type = 'statement_block' or: [aScopeBlock type = 'program']) ifTrue: [aScopeBlock childSandblocksDo: [:statement | statement type = 'lexical_declaration' ifTrue: [statement childSandblocksDo: [:declarator | aClosure value: (SBTSDeclaration block: (declarator get: 'name') label: 'lexical decl')]]]]
]

{ #category : #configuration }
SBJavascript class >> defaultRuntimeClass [

	^ SBJsRuntimeOSProcess
]

{ #category : #configuration }
SBJavascript class >> fileSuffix [

	^ 'js'
]

{ #category : #configuration }
SBJavascript class >> grammarJson [
	" https://github.com/tree-sitter/tree-sitter-javascript/blob/master/grammar.js "

	^ '{
	  "name": "javascript",
	  "word": "identifier",
	  "rules": {
	    "program": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "SYMBOL",
	              "name": "hash_bang_line"
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        },
	        {
	          "type": "REPEAT",
	          "content": {
	            "type": "SYMBOL",
	            "name": "statement"
	          }
	        }
	      ]
	    },
	    "hash_bang_line": {
	      "type": "PATTERN",
	      "value": "#!.*"
	    },
	    "export_statement": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "SEQ",
	          "members": [
	            {
	              "type": "STRING",
	              "value": "export"
	            },
	            {
	              "type": "CHOICE",
	              "members": [
	                {
	                  "type": "SEQ",
	                  "members": [
	                    {
	                      "type": "STRING",
	                      "value": "*"
	                    },
	                    {
	                      "type": "SYMBOL",
	                      "name": "_from_clause"
	                    },
	                    {
	                      "type": "SYMBOL",
	                      "name": "_semicolon"
	                    }
	                  ]
	                },
	                {
	                  "type": "SEQ",
	                  "members": [
	                    {
	                      "type": "ALIAS",
	                      "content": {
	                        "type": "SYMBOL",
	                        "name": "namespace_import_export"
	                      },
	                      "named": true,
	                      "value": "namespace_export"
	                    },
	                    {
	                      "type": "SYMBOL",
	                      "name": "_from_clause"
	                    },
	                    {
	                      "type": "SYMBOL",
	                      "name": "_semicolon"
	                    }
	                  ]
	                },
	                {
	                  "type": "SEQ",
	                  "members": [
	                    {
	                      "type": "SYMBOL",
	                      "name": "export_clause"
	                    },
	                    {
	                      "type": "SYMBOL",
	                      "name": "_from_clause"
	                    },
	                    {
	                      "type": "SYMBOL",
	                      "name": "_semicolon"
	                    }
	                  ]
	                },
	                {
	                  "type": "SEQ",
	                  "members": [
	                    {
	                      "type": "SYMBOL",
	                      "name": "export_clause"
	                    },
	                    {
	                      "type": "SYMBOL",
	                      "name": "_semicolon"
	                    }
	                  ]
	                }
	              ]
	            }
	          ]
	        },
	        {
	          "type": "SEQ",
	          "members": [
	            {
	              "type": "REPEAT",
	              "content": {
	                "type": "FIELD",
	                "name": "decorator",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "decorator"
	                }
	              }
	            },
	            {
	              "type": "STRING",
	              "value": "export"
	            },
	            {
	              "type": "CHOICE",
	              "members": [
	                {
	                  "type": "FIELD",
	                  "name": "declaration",
	                  "content": {
	                    "type": "SYMBOL",
	                    "name": "declaration"
	                  }
	                },
	                {
	                  "type": "SEQ",
	                  "members": [
	                    {
	                      "type": "STRING",
	                      "value": "default"
	                    },
	                    {
	                      "type": "CHOICE",
	                      "members": [
	                        {
	                          "type": "FIELD",
	                          "name": "declaration",
	                          "content": {
	                            "type": "SYMBOL",
	                            "name": "declaration"
	                          }
	                        },
	                        {
	                          "type": "SEQ",
	                          "members": [
	                            {
	                              "type": "FIELD",
	                              "name": "value",
	                              "content": {
	                                "type": "SYMBOL",
	                                "name": "expression"
	                              }
	                            },
	                            {
	                              "type": "SYMBOL",
	                              "name": "_semicolon"
	                            }
	                          ]
	                        }
	                      ]
	                    }
	                  ]
	                }
	              ]
	            }
	          ]
	        }
	      ]
	    },
	    "export_clause": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "{"
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "SEQ",
	              "members": [
	                {
	                  "type": "ALIAS",
	                  "content": {
	                    "type": "SYMBOL",
	                    "name": "_import_export_specifier"
	                  },
	                  "named": true,
	                  "value": "export_specifier"
	                },
	                {
	                  "type": "REPEAT",
	                  "content": {
	                    "type": "SEQ",
	                    "members": [
	                      {
	                        "type": "STRING",
	                        "value": ","
	                      },
	                      {
	                        "type": "ALIAS",
	                        "content": {
	                          "type": "SYMBOL",
	                          "name": "_import_export_specifier"
	                        },
	                        "named": true,
	                        "value": "export_specifier"
	                      }
	                    ]
	                  }
	                }
	              ]
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "STRING",
	              "value": ","
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        },
	        {
	          "type": "STRING",
	          "value": "}"
	        }
	      ]
	    },
	    "_import_export_specifier": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "FIELD",
	          "name": "name",
	          "content": {
	            "type": "SYMBOL",
	            "name": "identifier"
	          }
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "SEQ",
	              "members": [
	                {
	                  "type": "STRING",
	                  "value": "as"
	                },
	                {
	                  "type": "FIELD",
	                  "name": "alias",
	                  "content": {
	                    "type": "SYMBOL",
	                    "name": "identifier"
	                  }
	                }
	              ]
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        }
	      ]
	    },
	    "declaration": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "SYMBOL",
	          "name": "function_declaration"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "generator_function_declaration"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "class_declaration"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "lexical_declaration"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "variable_declaration"
	        }
	      ]
	    },
	    "import": {
	      "type": "TOKEN",
	      "content": {
	        "type": "STRING",
	        "value": "import"
	      }
	    },
	    "import_statement": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "import"
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "SEQ",
	              "members": [
	                {
	                  "type": "SYMBOL",
	                  "name": "import_clause"
	                },
	                {
	                  "type": "SYMBOL",
	                  "name": "_from_clause"
	                }
	              ]
	            },
	            {
	              "type": "FIELD",
	              "name": "source",
	              "content": {
	                "type": "SYMBOL",
	                "name": "string"
	              }
	            }
	          ]
	        },
	        {
	          "type": "SYMBOL",
	          "name": "_semicolon"
	        }
	      ]
	    },
	    "import_clause": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "ALIAS",
	          "content": {
	            "type": "SYMBOL",
	            "name": "namespace_import_export"
	          },
	          "named": true,
	          "value": "namespace_import"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "named_imports"
	        },
	        {
	          "type": "SEQ",
	          "members": [
	            {
	              "type": "SYMBOL",
	              "name": "identifier"
	            },
	            {
	              "type": "CHOICE",
	              "members": [
	                {
	                  "type": "SEQ",
	                  "members": [
	                    {
	                      "type": "STRING",
	                      "value": ","
	                    },
	                    {
	                      "type": "CHOICE",
	                      "members": [
	                        {
	                          "type": "ALIAS",
	                          "content": {
	                            "type": "SYMBOL",
	                            "name": "namespace_import_export"
	                          },
	                          "named": true,
	                          "value": "namespace_import"
	                        },
	                        {
	                          "type": "SYMBOL",
	                          "name": "named_imports"
	                        }
	                      ]
	                    }
	                  ]
	                },
	                {
	                  "type": "BLANK"
	                }
	              ]
	            }
	          ]
	        }
	      ]
	    },
	    "_from_clause": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "from"
	        },
	        {
	          "type": "FIELD",
	          "name": "source",
	          "content": {
	            "type": "SYMBOL",
	            "name": "string"
	          }
	        }
	      ]
	    },
	    "namespace_import_export": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "*"
	        },
	        {
	          "type": "STRING",
	          "value": "as"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "identifier"
	        }
	      ]
	    },
	    "named_imports": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "{"
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "SEQ",
	              "members": [
	                {
	                  "type": "ALIAS",
	                  "content": {
	                    "type": "SYMBOL",
	                    "name": "_import_export_specifier"
	                  },
	                  "named": true,
	                  "value": "import_specifier"
	                },
	                {
	                  "type": "REPEAT",
	                  "content": {
	                    "type": "SEQ",
	                    "members": [
	                      {
	                        "type": "STRING",
	                        "value": ","
	                      },
	                      {
	                        "type": "ALIAS",
	                        "content": {
	                          "type": "SYMBOL",
	                          "name": "_import_export_specifier"
	                        },
	                        "named": true,
	                        "value": "import_specifier"
	                      }
	                    ]
	                  }
	                }
	              ]
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "STRING",
	              "value": ","
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        },
	        {
	          "type": "STRING",
	          "value": "}"
	        }
	      ]
	    },
	    "statement": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "SYMBOL",
	          "name": "export_statement"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "import_statement"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "debugger_statement"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "expression_statement"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "declaration"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "statement_block"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "if_statement"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "switch_statement"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "for_statement"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "for_in_statement"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "while_statement"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "do_statement"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "try_statement"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "with_statement"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "break_statement"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "continue_statement"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "return_statement"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "throw_statement"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "empty_statement"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "labeled_statement"
	        }
	      ]
	    },
	    "expression_statement": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "SYMBOL",
	          "name": "_expressions"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "_semicolon"
	        }
	      ]
	    },
	    "variable_declaration": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "var"
	        },
	        {
	          "type": "SEQ",
	          "members": [
	            {
	              "type": "SYMBOL",
	              "name": "variable_declarator"
	            },
	            {
	              "type": "REPEAT",
	              "content": {
	                "type": "SEQ",
	                "members": [
	                  {
	                    "type": "STRING",
	                    "value": ","
	                  },
	                  {
	                    "type": "SYMBOL",
	                    "name": "variable_declarator"
	                  }
	                ]
	              }
	            }
	          ]
	        },
	        {
	          "type": "SYMBOL",
	          "name": "_semicolon"
	        }
	      ]
	    },
	    "lexical_declaration": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "FIELD",
	          "name": "kind",
	          "content": {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "STRING",
	                "value": "let"
	              },
	              {
	                "type": "STRING",
	                "value": "const"
	              }
	            ]
	          }
	        },
	        {
	          "type": "SEQ",
	          "members": [
	            {
	              "type": "SYMBOL",
	              "name": "variable_declarator"
	            },
	            {
	              "type": "REPEAT",
	              "content": {
	                "type": "SEQ",
	                "members": [
	                  {
	                    "type": "STRING",
	                    "value": ","
	                  },
	                  {
	                    "type": "SYMBOL",
	                    "name": "variable_declarator"
	                  }
	                ]
	              }
	            }
	          ]
	        },
	        {
	          "type": "SYMBOL",
	          "name": "_semicolon"
	        }
	      ]
	    },
	    "variable_declarator": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "FIELD",
	          "name": "name",
	          "content": {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "SYMBOL",
	                "name": "identifier"
	              },
	              {
	                "type": "SYMBOL",
	                "name": "_destructuring_pattern"
	              }
	            ]
	          }
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "SYMBOL",
	              "name": "_initializer"
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        }
	      ]
	    },
	    "statement_block": {
	      "type": "PREC_RIGHT",
	      "value": 0,
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "STRING",
	            "value": "{"
	          },
	          {
	            "type": "REPEAT",
	            "content": {
	              "type": "SYMBOL",
	              "name": "statement"
	            }
	          },
	          {
	            "type": "STRING",
	            "value": "}"
	          },
	          {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "SYMBOL",
	                "name": "_automatic_semicolon"
	              },
	              {
	                "type": "BLANK"
	              }
	            ]
	          }
	        ]
	      }
	    },
	    "else_clause": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "else"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "statement"
	        }
	      ]
	    },
	    "if_statement": {
	      "type": "PREC_RIGHT",
	      "value": 0,
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "STRING",
	            "value": "if"
	          },
	          {
	            "type": "FIELD",
	            "name": "condition",
	            "content": {
	              "type": "SYMBOL",
	              "name": "parenthesized_expression"
	            }
	          },
	          {
	            "type": "FIELD",
	            "name": "consequence",
	            "content": {
	              "type": "SYMBOL",
	              "name": "statement"
	            }
	          },
	          {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "alternative",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "else_clause"
	                }
	              },
	              {
	                "type": "BLANK"
	              }
	            ]
	          }
	        ]
	      }
	    },
	    "switch_statement": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "switch"
	        },
	        {
	          "type": "FIELD",
	          "name": "value",
	          "content": {
	            "type": "SYMBOL",
	            "name": "parenthesized_expression"
	          }
	        },
	        {
	          "type": "FIELD",
	          "name": "body",
	          "content": {
	            "type": "SYMBOL",
	            "name": "switch_body"
	          }
	        }
	      ]
	    },
	    "for_statement": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "for"
	        },
	        {
	          "type": "STRING",
	          "value": "("
	        },
	        {
	          "type": "FIELD",
	          "name": "initializer",
	          "content": {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "SYMBOL",
	                "name": "lexical_declaration"
	              },
	              {
	                "type": "SYMBOL",
	                "name": "variable_declaration"
	              },
	              {
	                "type": "SYMBOL",
	                "name": "expression_statement"
	              },
	              {
	                "type": "SYMBOL",
	                "name": "empty_statement"
	              }
	            ]
	          }
	        },
	        {
	          "type": "FIELD",
	          "name": "condition",
	          "content": {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "SYMBOL",
	                "name": "expression_statement"
	              },
	              {
	                "type": "SYMBOL",
	                "name": "empty_statement"
	              }
	            ]
	          }
	        },
	        {
	          "type": "FIELD",
	          "name": "increment",
	          "content": {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "SYMBOL",
	                "name": "_expressions"
	              },
	              {
	                "type": "BLANK"
	              }
	            ]
	          }
	        },
	        {
	          "type": "STRING",
	          "value": ")"
	        },
	        {
	          "type": "FIELD",
	          "name": "body",
	          "content": {
	            "type": "SYMBOL",
	            "name": "statement"
	          }
	        }
	      ]
	    },
	    "for_in_statement": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "for"
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "STRING",
	              "value": "await"
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        },
	        {
	          "type": "SYMBOL",
	          "name": "_for_header"
	        },
	        {
	          "type": "FIELD",
	          "name": "body",
	          "content": {
	            "type": "SYMBOL",
	            "name": "statement"
	          }
	        }
	      ]
	    },
	    "_for_header": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "("
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "FIELD",
	              "name": "left",
	              "content": {
	                "type": "CHOICE",
	                "members": [
	                  {
	                    "type": "SYMBOL",
	                    "name": "_lhs_expression"
	                  },
	                  {
	                    "type": "SYMBOL",
	                    "name": "parenthesized_expression"
	                  }
	                ]
	              }
	            },
	            {
	              "type": "SEQ",
	              "members": [
	                {
	                  "type": "FIELD",
	                  "name": "kind",
	                  "content": {
	                    "type": "STRING",
	                    "value": "var"
	                  }
	                },
	                {
	                  "type": "FIELD",
	                  "name": "left",
	                  "content": {
	                    "type": "CHOICE",
	                    "members": [
	                      {
	                        "type": "SYMBOL",
	                        "name": "identifier"
	                      },
	                      {
	                        "type": "SYMBOL",
	                        "name": "_destructuring_pattern"
	                      }
	                    ]
	                  }
	                },
	                {
	                  "type": "CHOICE",
	                  "members": [
	                    {
	                      "type": "SYMBOL",
	                      "name": "_initializer"
	                    },
	                    {
	                      "type": "BLANK"
	                    }
	                  ]
	                }
	              ]
	            },
	            {
	              "type": "SEQ",
	              "members": [
	                {
	                  "type": "FIELD",
	                  "name": "kind",
	                  "content": {
	                    "type": "CHOICE",
	                    "members": [
	                      {
	                        "type": "STRING",
	                        "value": "let"
	                      },
	                      {
	                        "type": "STRING",
	                        "value": "const"
	                      }
	                    ]
	                  }
	                },
	                {
	                  "type": "FIELD",
	                  "name": "left",
	                  "content": {
	                    "type": "CHOICE",
	                    "members": [
	                      {
	                        "type": "SYMBOL",
	                        "name": "identifier"
	                      },
	                      {
	                        "type": "SYMBOL",
	                        "name": "_destructuring_pattern"
	                      }
	                    ]
	                  }
	                }
	              ]
	            }
	          ]
	        },
	        {
	          "type": "FIELD",
	          "name": "operator",
	          "content": {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "STRING",
	                "value": "in"
	              },
	              {
	                "type": "STRING",
	                "value": "of"
	              }
	            ]
	          }
	        },
	        {
	          "type": "FIELD",
	          "name": "right",
	          "content": {
	            "type": "SYMBOL",
	            "name": "_expressions"
	          }
	        },
	        {
	          "type": "STRING",
	          "value": ")"
	        }
	      ]
	    },
	    "while_statement": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "while"
	        },
	        {
	          "type": "FIELD",
	          "name": "condition",
	          "content": {
	            "type": "SYMBOL",
	            "name": "parenthesized_expression"
	          }
	        },
	        {
	          "type": "FIELD",
	          "name": "body",
	          "content": {
	            "type": "SYMBOL",
	            "name": "statement"
	          }
	        }
	      ]
	    },
	    "do_statement": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "do"
	        },
	        {
	          "type": "FIELD",
	          "name": "body",
	          "content": {
	            "type": "SYMBOL",
	            "name": "statement"
	          }
	        },
	        {
	          "type": "STRING",
	          "value": "while"
	        },
	        {
	          "type": "FIELD",
	          "name": "condition",
	          "content": {
	            "type": "SYMBOL",
	            "name": "parenthesized_expression"
	          }
	        },
	        {
	          "type": "SYMBOL",
	          "name": "_semicolon"
	        }
	      ]
	    },
	    "try_statement": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "try"
	        },
	        {
	          "type": "FIELD",
	          "name": "body",
	          "content": {
	            "type": "SYMBOL",
	            "name": "statement_block"
	          }
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "FIELD",
	              "name": "handler",
	              "content": {
	                "type": "SYMBOL",
	                "name": "catch_clause"
	              }
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "FIELD",
	              "name": "finalizer",
	              "content": {
	                "type": "SYMBOL",
	                "name": "finally_clause"
	              }
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        }
	      ]
	    },
	    "with_statement": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "with"
	        },
	        {
	          "type": "FIELD",
	          "name": "object",
	          "content": {
	            "type": "SYMBOL",
	            "name": "parenthesized_expression"
	          }
	        },
	        {
	          "type": "FIELD",
	          "name": "body",
	          "content": {
	            "type": "SYMBOL",
	            "name": "statement"
	          }
	        }
	      ]
	    },
	    "break_statement": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "break"
	        },
	        {
	          "type": "FIELD",
	          "name": "label",
	          "content": {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "ALIAS",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "identifier"
	                },
	                "named": true,
	                "value": "statement_identifier"
	              },
	              {
	                "type": "BLANK"
	              }
	            ]
	          }
	        },
	        {
	          "type": "SYMBOL",
	          "name": "_semicolon"
	        }
	      ]
	    },
	    "continue_statement": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "continue"
	        },
	        {
	          "type": "FIELD",
	          "name": "label",
	          "content": {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "ALIAS",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "identifier"
	                },
	                "named": true,
	                "value": "statement_identifier"
	              },
	              {
	                "type": "BLANK"
	              }
	            ]
	          }
	        },
	        {
	          "type": "SYMBOL",
	          "name": "_semicolon"
	        }
	      ]
	    },
	    "debugger_statement": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "debugger"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "_semicolon"
	        }
	      ]
	    },
	    "return_statement": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "return"
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "SYMBOL",
	              "name": "_expressions"
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        },
	        {
	          "type": "SYMBOL",
	          "name": "_semicolon"
	        }
	      ]
	    },
	    "throw_statement": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "throw"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "_expressions"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "_semicolon"
	        }
	      ]
	    },
	    "empty_statement": {
	      "type": "STRING",
	      "value": ";"
	    },
	    "labeled_statement": {
	      "type": "PREC_DYNAMIC",
	      "value": -1,
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "FIELD",
	            "name": "label",
	            "content": {
	              "type": "ALIAS",
	              "content": {
	                "type": "CHOICE",
	                "members": [
	                  {
	                    "type": "SYMBOL",
	                    "name": "identifier"
	                  },
	                  {
	                    "type": "SYMBOL",
	                    "name": "_reserved_identifier"
	                  }
	                ]
	              },
	              "named": true,
	              "value": "statement_identifier"
	            }
	          },
	          {
	            "type": "STRING",
	            "value": ":"
	          },
	          {
	            "type": "FIELD",
	            "name": "body",
	            "content": {
	              "type": "SYMBOL",
	              "name": "statement"
	            }
	          }
	        ]
	      }
	    },
	    "switch_body": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "{"
	        },
	        {
	          "type": "REPEAT",
	          "content": {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "SYMBOL",
	                "name": "switch_case"
	              },
	              {
	                "type": "SYMBOL",
	                "name": "switch_default"
	              }
	            ]
	          }
	        },
	        {
	          "type": "STRING",
	          "value": "}"
	        }
	      ]
	    },
	    "switch_case": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "case"
	        },
	        {
	          "type": "FIELD",
	          "name": "value",
	          "content": {
	            "type": "SYMBOL",
	            "name": "_expressions"
	          }
	        },
	        {
	          "type": "STRING",
	          "value": ":"
	        },
	        {
	          "type": "FIELD",
	          "name": "body",
	          "content": {
	            "type": "REPEAT",
	            "content": {
	              "type": "SYMBOL",
	              "name": "statement"
	            }
	          }
	        }
	      ]
	    },
	    "switch_default": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "default"
	        },
	        {
	          "type": "STRING",
	          "value": ":"
	        },
	        {
	          "type": "FIELD",
	          "name": "body",
	          "content": {
	            "type": "REPEAT",
	            "content": {
	              "type": "SYMBOL",
	              "name": "statement"
	            }
	          }
	        }
	      ]
	    },
	    "catch_clause": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "catch"
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "SEQ",
	              "members": [
	                {
	                  "type": "STRING",
	                  "value": "("
	                },
	                {
	                  "type": "FIELD",
	                  "name": "parameter",
	                  "content": {
	                    "type": "CHOICE",
	                    "members": [
	                      {
	                        "type": "SYMBOL",
	                        "name": "identifier"
	                      },
	                      {
	                        "type": "SYMBOL",
	                        "name": "_destructuring_pattern"
	                      }
	                    ]
	                  }
	                },
	                {
	                  "type": "STRING",
	                  "value": ")"
	                }
	              ]
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        },
	        {
	          "type": "FIELD",
	          "name": "body",
	          "content": {
	            "type": "SYMBOL",
	            "name": "statement_block"
	          }
	        }
	      ]
	    },
	    "finally_clause": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "finally"
	        },
	        {
	          "type": "FIELD",
	          "name": "body",
	          "content": {
	            "type": "SYMBOL",
	            "name": "statement_block"
	          }
	        }
	      ]
	    },
	    "parenthesized_expression": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "("
	        },
	        {
	          "type": "SYMBOL",
	          "name": "_expressions"
	        },
	        {
	          "type": "STRING",
	          "value": ")"
	        }
	      ]
	    },
	    "_expressions": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "SYMBOL",
	          "name": "expression"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "sequence_expression"
	        }
	      ]
	    },
	    "expression": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "SYMBOL",
	          "name": "primary_expression"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "_jsx_element"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "jsx_fragment"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "assignment_expression"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "augmented_assignment_expression"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "await_expression"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "unary_expression"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "binary_expression"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "ternary_expression"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "update_expression"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "new_expression"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "yield_expression"
	        }
	      ]
	    },
	    "primary_expression": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "SYMBOL",
	          "name": "subscript_expression"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "member_expression"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "parenthesized_expression"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "_identifier"
	        },
	        {
	          "type": "ALIAS",
	          "content": {
	            "type": "SYMBOL",
	            "name": "_reserved_identifier"
	          },
	          "named": true,
	          "value": "identifier"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "this"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "super"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "number"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "string"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "template_string"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "regex"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "true"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "false"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "null"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "import"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "object"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "array"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "function"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "arrow_function"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "generator_function"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "class"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "meta_property"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "call_expression"
	        }
	      ]
	    },
	    "yield_expression": {
	      "type": "PREC_RIGHT",
	      "value": 0,
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "STRING",
	            "value": "yield"
	          },
	          {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "SEQ",
	                "members": [
	                  {
	                    "type": "STRING",
	                    "value": "*"
	                  },
	                  {
	                    "type": "SYMBOL",
	                    "name": "expression"
	                  }
	                ]
	              },
	              {
	                "type": "CHOICE",
	                "members": [
	                  {
	                    "type": "SYMBOL",
	                    "name": "expression"
	                  },
	                  {
	                    "type": "BLANK"
	                  }
	                ]
	              }
	            ]
	          }
	        ]
	      }
	    },
	    "object": {
	      "type": "PREC",
	      "value": "object",
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "STRING",
	            "value": "{"
	          },
	          {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "SEQ",
	                "members": [
	                  {
	                    "type": "CHOICE",
	                    "members": [
	                      {
	                        "type": "CHOICE",
	                        "members": [
	                          {
	                            "type": "SYMBOL",
	                            "name": "pair"
	                          },
	                          {
	                            "type": "SYMBOL",
	                            "name": "spread_element"
	                          },
	                          {
	                            "type": "SYMBOL",
	                            "name": "method_definition"
	                          },
	                          {
	                            "type": "ALIAS",
	                            "content": {
	                              "type": "CHOICE",
	                              "members": [
	                                {
	                                  "type": "SYMBOL",
	                                  "name": "identifier"
	                                },
	                                {
	                                  "type": "SYMBOL",
	                                  "name": "_reserved_identifier"
	                                }
	                              ]
	                            },
	                            "named": true,
	                            "value": "shorthand_property_identifier"
	                          }
	                        ]
	                      },
	                      {
	                        "type": "BLANK"
	                      }
	                    ]
	                  },
	                  {
	                    "type": "REPEAT",
	                    "content": {
	                      "type": "SEQ",
	                      "members": [
	                        {
	                          "type": "STRING",
	                          "value": ","
	                        },
	                        {
	                          "type": "CHOICE",
	                          "members": [
	                            {
	                              "type": "CHOICE",
	                              "members": [
	                                {
	                                  "type": "SYMBOL",
	                                  "name": "pair"
	                                },
	                                {
	                                  "type": "SYMBOL",
	                                  "name": "spread_element"
	                                },
	                                {
	                                  "type": "SYMBOL",
	                                  "name": "method_definition"
	                                },
	                                {
	                                  "type": "ALIAS",
	                                  "content": {
	                                    "type": "CHOICE",
	                                    "members": [
	                                      {
	                                        "type": "SYMBOL",
	                                        "name": "identifier"
	                                      },
	                                      {
	                                        "type": "SYMBOL",
	                                        "name": "_reserved_identifier"
	                                      }
	                                    ]
	                                  },
	                                  "named": true,
	                                  "value": "shorthand_property_identifier"
	                                }
	                              ]
	                            },
	                            {
	                              "type": "BLANK"
	                            }
	                          ]
	                        }
	                      ]
	                    }
	                  }
	                ]
	              },
	              {
	                "type": "BLANK"
	              }
	            ]
	          },
	          {
	            "type": "STRING",
	            "value": "}"
	          }
	        ]
	      }
	    },
	    "object_pattern": {
	      "type": "PREC",
	      "value": "object",
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "STRING",
	            "value": "{"
	          },
	          {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "SEQ",
	                "members": [
	                  {
	                    "type": "CHOICE",
	                    "members": [
	                      {
	                        "type": "CHOICE",
	                        "members": [
	                          {
	                            "type": "SYMBOL",
	                            "name": "pair_pattern"
	                          },
	                          {
	                            "type": "SYMBOL",
	                            "name": "rest_pattern"
	                          },
	                          {
	                            "type": "SYMBOL",
	                            "name": "object_assignment_pattern"
	                          },
	                          {
	                            "type": "ALIAS",
	                            "content": {
	                              "type": "CHOICE",
	                              "members": [
	                                {
	                                  "type": "SYMBOL",
	                                  "name": "identifier"
	                                },
	                                {
	                                  "type": "SYMBOL",
	                                  "name": "_reserved_identifier"
	                                }
	                              ]
	                            },
	                            "named": true,
	                            "value": "shorthand_property_identifier_pattern"
	                          }
	                        ]
	                      },
	                      {
	                        "type": "BLANK"
	                      }
	                    ]
	                  },
	                  {
	                    "type": "REPEAT",
	                    "content": {
	                      "type": "SEQ",
	                      "members": [
	                        {
	                          "type": "STRING",
	                          "value": ","
	                        },
	                        {
	                          "type": "CHOICE",
	                          "members": [
	                            {
	                              "type": "CHOICE",
	                              "members": [
	                                {
	                                  "type": "SYMBOL",
	                                  "name": "pair_pattern"
	                                },
	                                {
	                                  "type": "SYMBOL",
	                                  "name": "rest_pattern"
	                                },
	                                {
	                                  "type": "SYMBOL",
	                                  "name": "object_assignment_pattern"
	                                },
	                                {
	                                  "type": "ALIAS",
	                                  "content": {
	                                    "type": "CHOICE",
	                                    "members": [
	                                      {
	                                        "type": "SYMBOL",
	                                        "name": "identifier"
	                                      },
	                                      {
	                                        "type": "SYMBOL",
	                                        "name": "_reserved_identifier"
	                                      }
	                                    ]
	                                  },
	                                  "named": true,
	                                  "value": "shorthand_property_identifier_pattern"
	                                }
	                              ]
	                            },
	                            {
	                              "type": "BLANK"
	                            }
	                          ]
	                        }
	                      ]
	                    }
	                  }
	                ]
	              },
	              {
	                "type": "BLANK"
	              }
	            ]
	          },
	          {
	            "type": "STRING",
	            "value": "}"
	          }
	        ]
	      }
	    },
	    "assignment_pattern": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "FIELD",
	          "name": "left",
	          "content": {
	            "type": "SYMBOL",
	            "name": "pattern"
	          }
	        },
	        {
	          "type": "STRING",
	          "value": "="
	        },
	        {
	          "type": "FIELD",
	          "name": "right",
	          "content": {
	            "type": "SYMBOL",
	            "name": "expression"
	          }
	        }
	      ]
	    },
	    "object_assignment_pattern": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "FIELD",
	          "name": "left",
	          "content": {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "ALIAS",
	                "content": {
	                  "type": "CHOICE",
	                  "members": [
	                    {
	                      "type": "SYMBOL",
	                      "name": "_reserved_identifier"
	                    },
	                    {
	                      "type": "SYMBOL",
	                      "name": "identifier"
	                    }
	                  ]
	                },
	                "named": true,
	                "value": "shorthand_property_identifier_pattern"
	              },
	              {
	                "type": "SYMBOL",
	                "name": "_destructuring_pattern"
	              }
	            ]
	          }
	        },
	        {
	          "type": "STRING",
	          "value": "="
	        },
	        {
	          "type": "FIELD",
	          "name": "right",
	          "content": {
	            "type": "SYMBOL",
	            "name": "expression"
	          }
	        }
	      ]
	    },
	    "array": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "["
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "SEQ",
	              "members": [
	                {
	                  "type": "CHOICE",
	                  "members": [
	                    {
	                      "type": "CHOICE",
	                      "members": [
	                        {
	                          "type": "SYMBOL",
	                          "name": "expression"
	                        },
	                        {
	                          "type": "SYMBOL",
	                          "name": "spread_element"
	                        }
	                      ]
	                    },
	                    {
	                      "type": "BLANK"
	                    }
	                  ]
	                },
	                {
	                  "type": "REPEAT",
	                  "content": {
	                    "type": "SEQ",
	                    "members": [
	                      {
	                        "type": "STRING",
	                        "value": ","
	                      },
	                      {
	                        "type": "CHOICE",
	                        "members": [
	                          {
	                            "type": "CHOICE",
	                            "members": [
	                              {
	                                "type": "SYMBOL",
	                                "name": "expression"
	                              },
	                              {
	                                "type": "SYMBOL",
	                                "name": "spread_element"
	                              }
	                            ]
	                          },
	                          {
	                            "type": "BLANK"
	                          }
	                        ]
	                      }
	                    ]
	                  }
	                }
	              ]
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        },
	        {
	          "type": "STRING",
	          "value": "]"
	        }
	      ]
	    },
	    "array_pattern": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "["
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "SEQ",
	              "members": [
	                {
	                  "type": "CHOICE",
	                  "members": [
	                    {
	                      "type": "CHOICE",
	                      "members": [
	                        {
	                          "type": "SYMBOL",
	                          "name": "pattern"
	                        },
	                        {
	                          "type": "SYMBOL",
	                          "name": "assignment_pattern"
	                        }
	                      ]
	                    },
	                    {
	                      "type": "BLANK"
	                    }
	                  ]
	                },
	                {
	                  "type": "REPEAT",
	                  "content": {
	                    "type": "SEQ",
	                    "members": [
	                      {
	                        "type": "STRING",
	                        "value": ","
	                      },
	                      {
	                        "type": "CHOICE",
	                        "members": [
	                          {
	                            "type": "CHOICE",
	                            "members": [
	                              {
	                                "type": "SYMBOL",
	                                "name": "pattern"
	                              },
	                              {
	                                "type": "SYMBOL",
	                                "name": "assignment_pattern"
	                              }
	                            ]
	                          },
	                          {
	                            "type": "BLANK"
	                          }
	                        ]
	                      }
	                    ]
	                  }
	                }
	              ]
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        },
	        {
	          "type": "STRING",
	          "value": "]"
	        }
	      ]
	    },
	    "_jsx_element": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "SYMBOL",
	          "name": "jsx_element"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "jsx_self_closing_element"
	        }
	      ]
	    },
	    "jsx_element": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "FIELD",
	          "name": "open_tag",
	          "content": {
	            "type": "SYMBOL",
	            "name": "jsx_opening_element"
	          }
	        },
	        {
	          "type": "REPEAT",
	          "content": {
	            "type": "SYMBOL",
	            "name": "_jsx_child"
	          }
	        },
	        {
	          "type": "FIELD",
	          "name": "close_tag",
	          "content": {
	            "type": "SYMBOL",
	            "name": "jsx_closing_element"
	          }
	        }
	      ]
	    },
	    "jsx_fragment": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "<"
	        },
	        {
	          "type": "STRING",
	          "value": ">"
	        },
	        {
	          "type": "REPEAT",
	          "content": {
	            "type": "SYMBOL",
	            "name": "_jsx_child"
	          }
	        },
	        {
	          "type": "STRING",
	          "value": "<"
	        },
	        {
	          "type": "STRING",
	          "value": "/"
	        },
	        {
	          "type": "STRING",
	          "value": ">"
	        }
	      ]
	    },
	    "jsx_text": {
	      "type": "PATTERN",
	      "value": "[^{}<>]+"
	    },
	    "jsx_expression": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "{"
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "CHOICE",
	              "members": [
	                {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                },
	                {
	                  "type": "SYMBOL",
	                  "name": "sequence_expression"
	                },
	                {
	                  "type": "SYMBOL",
	                  "name": "spread_element"
	                }
	              ]
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        },
	        {
	          "type": "STRING",
	          "value": "}"
	        }
	      ]
	    },
	    "_jsx_child": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "SYMBOL",
	          "name": "jsx_text"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "_jsx_element"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "jsx_fragment"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "jsx_expression"
	        }
	      ]
	    },
	    "jsx_opening_element": {
	      "type": "PREC_DYNAMIC",
	      "value": -1,
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "STRING",
	            "value": "<"
	          },
	          {
	            "type": "FIELD",
	            "name": "name",
	            "content": {
	              "type": "SYMBOL",
	              "name": "_jsx_element_name"
	            }
	          },
	          {
	            "type": "REPEAT",
	            "content": {
	              "type": "FIELD",
	              "name": "attribute",
	              "content": {
	                "type": "SYMBOL",
	                "name": "_jsx_attribute"
	              }
	            }
	          },
	          {
	            "type": "STRING",
	            "value": ">"
	          }
	        ]
	      }
	    },
	    "jsx_identifier": {
	      "type": "PATTERN",
	      "value": "[a-zA-Z_$][a-zA-Z\\d_$]*-[a-zA-Z\\d_$\\-]*"
	    },
	    "_jsx_identifier": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "ALIAS",
	          "content": {
	            "type": "SYMBOL",
	            "name": "jsx_identifier"
	          },
	          "named": true,
	          "value": "identifier"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "identifier"
	        }
	      ]
	    },
	    "nested_identifier": {
	      "type": "PREC",
	      "value": "member",
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "SYMBOL",
	                "name": "identifier"
	              },
	              {
	                "type": "SYMBOL",
	                "name": "nested_identifier"
	              }
	            ]
	          },
	          {
	            "type": "STRING",
	            "value": "."
	          },
	          {
	            "type": "SYMBOL",
	            "name": "identifier"
	          }
	        ]
	      }
	    },
	    "jsx_namespace_name": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "SYMBOL",
	          "name": "_jsx_identifier"
	        },
	        {
	          "type": "STRING",
	          "value": ":"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "_jsx_identifier"
	        }
	      ]
	    },
	    "_jsx_element_name": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "SYMBOL",
	          "name": "_jsx_identifier"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "nested_identifier"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "jsx_namespace_name"
	        }
	      ]
	    },
	    "jsx_closing_element": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "<"
	        },
	        {
	          "type": "STRING",
	          "value": "/"
	        },
	        {
	          "type": "FIELD",
	          "name": "name",
	          "content": {
	            "type": "SYMBOL",
	            "name": "_jsx_element_name"
	          }
	        },
	        {
	          "type": "STRING",
	          "value": ">"
	        }
	      ]
	    },
	    "jsx_self_closing_element": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "<"
	        },
	        {
	          "type": "FIELD",
	          "name": "name",
	          "content": {
	            "type": "SYMBOL",
	            "name": "_jsx_element_name"
	          }
	        },
	        {
	          "type": "REPEAT",
	          "content": {
	            "type": "FIELD",
	            "name": "attribute",
	            "content": {
	              "type": "SYMBOL",
	              "name": "_jsx_attribute"
	            }
	          }
	        },
	        {
	          "type": "STRING",
	          "value": "/"
	        },
	        {
	          "type": "STRING",
	          "value": ">"
	        }
	      ]
	    },
	    "_jsx_attribute": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "SYMBOL",
	          "name": "jsx_attribute"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "jsx_expression"
	        }
	      ]
	    },
	    "_jsx_attribute_name": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "ALIAS",
	          "content": {
	            "type": "SYMBOL",
	            "name": "_jsx_identifier"
	          },
	          "named": true,
	          "value": "property_identifier"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "jsx_namespace_name"
	        }
	      ]
	    },
	    "jsx_attribute": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "SYMBOL",
	          "name": "_jsx_attribute_name"
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "SEQ",
	              "members": [
	                {
	                  "type": "STRING",
	                  "value": "="
	                },
	                {
	                  "type": "SYMBOL",
	                  "name": "_jsx_attribute_value"
	                }
	              ]
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        }
	      ]
	    },
	    "_jsx_attribute_value": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "SYMBOL",
	          "name": "string"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "jsx_expression"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "_jsx_element"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "jsx_fragment"
	        }
	      ]
	    },
	    "class": {
	      "type": "PREC",
	      "value": "literal",
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "REPEAT",
	            "content": {
	              "type": "FIELD",
	              "name": "decorator",
	              "content": {
	                "type": "SYMBOL",
	                "name": "decorator"
	              }
	            }
	          },
	          {
	            "type": "STRING",
	            "value": "class"
	          },
	          {
	            "type": "FIELD",
	            "name": "name",
	            "content": {
	              "type": "CHOICE",
	              "members": [
	                {
	                  "type": "SYMBOL",
	                  "name": "identifier"
	                },
	                {
	                  "type": "BLANK"
	                }
	              ]
	            }
	          },
	          {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "SYMBOL",
	                "name": "class_heritage"
	              },
	              {
	                "type": "BLANK"
	              }
	            ]
	          },
	          {
	            "type": "FIELD",
	            "name": "body",
	            "content": {
	              "type": "SYMBOL",
	              "name": "class_body"
	            }
	          }
	        ]
	      }
	    },
	    "class_declaration": {
	      "type": "PREC",
	      "value": "declaration",
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "REPEAT",
	            "content": {
	              "type": "FIELD",
	              "name": "decorator",
	              "content": {
	                "type": "SYMBOL",
	                "name": "decorator"
	              }
	            }
	          },
	          {
	            "type": "STRING",
	            "value": "class"
	          },
	          {
	            "type": "FIELD",
	            "name": "name",
	            "content": {
	              "type": "SYMBOL",
	              "name": "identifier"
	            }
	          },
	          {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "SYMBOL",
	                "name": "class_heritage"
	              },
	              {
	                "type": "BLANK"
	              }
	            ]
	          },
	          {
	            "type": "FIELD",
	            "name": "body",
	            "content": {
	              "type": "SYMBOL",
	              "name": "class_body"
	            }
	          },
	          {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "SYMBOL",
	                "name": "_automatic_semicolon"
	              },
	              {
	                "type": "BLANK"
	              }
	            ]
	          }
	        ]
	      }
	    },
	    "class_heritage": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "extends"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "expression"
	        }
	      ]
	    },
	    "function": {
	      "type": "PREC",
	      "value": "literal",
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "STRING",
	                "value": "async"
	              },
	              {
	                "type": "BLANK"
	              }
	            ]
	          },
	          {
	            "type": "STRING",
	            "value": "function"
	          },
	          {
	            "type": "FIELD",
	            "name": "name",
	            "content": {
	              "type": "CHOICE",
	              "members": [
	                {
	                  "type": "SYMBOL",
	                  "name": "identifier"
	                },
	                {
	                  "type": "BLANK"
	                }
	              ]
	            }
	          },
	          {
	            "type": "SYMBOL",
	            "name": "_call_signature"
	          },
	          {
	            "type": "FIELD",
	            "name": "body",
	            "content": {
	              "type": "SYMBOL",
	              "name": "statement_block"
	            }
	          }
	        ]
	      }
	    },
	    "function_declaration": {
	      "type": "PREC_RIGHT",
	      "value": "declaration",
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "STRING",
	                "value": "async"
	              },
	              {
	                "type": "BLANK"
	              }
	            ]
	          },
	          {
	            "type": "STRING",
	            "value": "function"
	          },
	          {
	            "type": "FIELD",
	            "name": "name",
	            "content": {
	              "type": "SYMBOL",
	              "name": "identifier"
	            }
	          },
	          {
	            "type": "SYMBOL",
	            "name": "_call_signature"
	          },
	          {
	            "type": "FIELD",
	            "name": "body",
	            "content": {
	              "type": "SYMBOL",
	              "name": "statement_block"
	            }
	          },
	          {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "SYMBOL",
	                "name": "_automatic_semicolon"
	              },
	              {
	                "type": "BLANK"
	              }
	            ]
	          }
	        ]
	      }
	    },
	    "generator_function": {
	      "type": "PREC",
	      "value": "literal",
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "STRING",
	                "value": "async"
	              },
	              {
	                "type": "BLANK"
	              }
	            ]
	          },
	          {
	            "type": "STRING",
	            "value": "function"
	          },
	          {
	            "type": "STRING",
	            "value": "*"
	          },
	          {
	            "type": "FIELD",
	            "name": "name",
	            "content": {
	              "type": "CHOICE",
	              "members": [
	                {
	                  "type": "SYMBOL",
	                  "name": "identifier"
	                },
	                {
	                  "type": "BLANK"
	                }
	              ]
	            }
	          },
	          {
	            "type": "SYMBOL",
	            "name": "_call_signature"
	          },
	          {
	            "type": "FIELD",
	            "name": "body",
	            "content": {
	              "type": "SYMBOL",
	              "name": "statement_block"
	            }
	          }
	        ]
	      }
	    },
	    "generator_function_declaration": {
	      "type": "PREC_RIGHT",
	      "value": "declaration",
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "STRING",
	                "value": "async"
	              },
	              {
	                "type": "BLANK"
	              }
	            ]
	          },
	          {
	            "type": "STRING",
	            "value": "function"
	          },
	          {
	            "type": "STRING",
	            "value": "*"
	          },
	          {
	            "type": "FIELD",
	            "name": "name",
	            "content": {
	              "type": "SYMBOL",
	              "name": "identifier"
	            }
	          },
	          {
	            "type": "SYMBOL",
	            "name": "_call_signature"
	          },
	          {
	            "type": "FIELD",
	            "name": "body",
	            "content": {
	              "type": "SYMBOL",
	              "name": "statement_block"
	            }
	          },
	          {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "SYMBOL",
	                "name": "_automatic_semicolon"
	              },
	              {
	                "type": "BLANK"
	              }
	            ]
	          }
	        ]
	      }
	    },
	    "arrow_function": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "STRING",
	              "value": "async"
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "FIELD",
	              "name": "parameter",
	              "content": {
	                "type": "CHOICE",
	                "members": [
	                  {
	                    "type": "ALIAS",
	                    "content": {
	                      "type": "SYMBOL",
	                      "name": "_reserved_identifier"
	                    },
	                    "named": true,
	                    "value": "identifier"
	                  },
	                  {
	                    "type": "SYMBOL",
	                    "name": "identifier"
	                  }
	                ]
	              }
	            },
	            {
	              "type": "SYMBOL",
	              "name": "_call_signature"
	            }
	          ]
	        },
	        {
	          "type": "STRING",
	          "value": "=>"
	        },
	        {
	          "type": "FIELD",
	          "name": "body",
	          "content": {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "SYMBOL",
	                "name": "expression"
	              },
	              {
	                "type": "SYMBOL",
	                "name": "statement_block"
	              }
	            ]
	          }
	        }
	      ]
	    },
	    "_call_signature": {
	      "type": "FIELD",
	      "name": "parameters",
	      "content": {
	        "type": "SYMBOL",
	        "name": "formal_parameters"
	      }
	    },
	    "_formal_parameter": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "SYMBOL",
	          "name": "pattern"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "assignment_pattern"
	        }
	      ]
	    },
	    "call_expression": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "PREC",
	          "value": "call",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "function",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "arguments",
	                "content": {
	                  "type": "CHOICE",
	                  "members": [
	                    {
	                      "type": "SYMBOL",
	                      "name": "arguments"
	                    },
	                    {
	                      "type": "SYMBOL",
	                      "name": "template_string"
	                    }
	                  ]
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC",
	          "value": "member",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "function",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "primary_expression"
	                }
	              },
	              {
	                "type": "STRING",
	                "value": "?."
	              },
	              {
	                "type": "FIELD",
	                "name": "arguments",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "arguments"
	                }
	              }
	            ]
	          }
	        }
	      ]
	    },
	    "new_expression": {
	      "type": "PREC_RIGHT",
	      "value": "new",
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "STRING",
	            "value": "new"
	          },
	          {
	            "type": "FIELD",
	            "name": "constructor",
	            "content": {
	              "type": "CHOICE",
	              "members": [
	                {
	                  "type": "SYMBOL",
	                  "name": "primary_expression"
	                },
	                {
	                  "type": "SYMBOL",
	                  "name": "new_expression"
	                }
	              ]
	            }
	          },
	          {
	            "type": "FIELD",
	            "name": "arguments",
	            "content": {
	              "type": "CHOICE",
	              "members": [
	                {
	                  "type": "PREC_DYNAMIC",
	                  "value": 1,
	                  "content": {
	                    "type": "SYMBOL",
	                    "name": "arguments"
	                  }
	                },
	                {
	                  "type": "BLANK"
	                }
	              ]
	            }
	          }
	        ]
	      }
	    },
	    "await_expression": {
	      "type": "PREC",
	      "value": "unary_void",
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "STRING",
	            "value": "await"
	          },
	          {
	            "type": "SYMBOL",
	            "name": "expression"
	          }
	        ]
	      }
	    },
	    "member_expression": {
	      "type": "PREC",
	      "value": "member",
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "FIELD",
	            "name": "object",
	            "content": {
	              "type": "CHOICE",
	              "members": [
	                {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                },
	                {
	                  "type": "SYMBOL",
	                  "name": "primary_expression"
	                }
	              ]
	            }
	          },
	          {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "STRING",
	                "value": "."
	              },
	              {
	                "type": "STRING",
	                "value": "?."
	              }
	            ]
	          },
	          {
	            "type": "FIELD",
	            "name": "property",
	            "content": {
	              "type": "CHOICE",
	              "members": [
	                {
	                  "type": "SYMBOL",
	                  "name": "private_property_identifier"
	                },
	                {
	                  "type": "ALIAS",
	                  "content": {
	                    "type": "SYMBOL",
	                    "name": "identifier"
	                  },
	                  "named": true,
	                  "value": "property_identifier"
	                }
	              ]
	            }
	          }
	        ]
	      }
	    },
	    "subscript_expression": {
	      "type": "PREC_RIGHT",
	      "value": "member",
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "FIELD",
	            "name": "object",
	            "content": {
	              "type": "CHOICE",
	              "members": [
	                {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                },
	                {
	                  "type": "SYMBOL",
	                  "name": "primary_expression"
	                }
	              ]
	            }
	          },
	          {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "STRING",
	                "value": "?."
	              },
	              {
	                "type": "BLANK"
	              }
	            ]
	          },
	          {
	            "type": "STRING",
	            "value": "["
	          },
	          {
	            "type": "FIELD",
	            "name": "index",
	            "content": {
	              "type": "SYMBOL",
	              "name": "_expressions"
	            }
	          },
	          {
	            "type": "STRING",
	            "value": "]"
	          }
	        ]
	      }
	    },
	    "_lhs_expression": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "SYMBOL",
	          "name": "member_expression"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "subscript_expression"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "_identifier"
	        },
	        {
	          "type": "ALIAS",
	          "content": {
	            "type": "SYMBOL",
	            "name": "_reserved_identifier"
	          },
	          "named": true,
	          "value": "identifier"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "_destructuring_pattern"
	        }
	      ]
	    },
	    "assignment_expression": {
	      "type": "PREC_RIGHT",
	      "value": "assign",
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "FIELD",
	            "name": "left",
	            "content": {
	              "type": "CHOICE",
	              "members": [
	                {
	                  "type": "SYMBOL",
	                  "name": "parenthesized_expression"
	                },
	                {
	                  "type": "SYMBOL",
	                  "name": "_lhs_expression"
	                }
	              ]
	            }
	          },
	          {
	            "type": "STRING",
	            "value": "="
	          },
	          {
	            "type": "FIELD",
	            "name": "right",
	            "content": {
	              "type": "SYMBOL",
	              "name": "expression"
	            }
	          }
	        ]
	      }
	    },
	    "_augmented_assignment_lhs": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "SYMBOL",
	          "name": "member_expression"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "subscript_expression"
	        },
	        {
	          "type": "ALIAS",
	          "content": {
	            "type": "SYMBOL",
	            "name": "_reserved_identifier"
	          },
	          "named": true,
	          "value": "identifier"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "identifier"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "parenthesized_expression"
	        }
	      ]
	    },
	    "augmented_assignment_expression": {
	      "type": "PREC_RIGHT",
	      "value": "assign",
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "FIELD",
	            "name": "left",
	            "content": {
	              "type": "SYMBOL",
	              "name": "_augmented_assignment_lhs"
	            }
	          },
	          {
	            "type": "FIELD",
	            "name": "operator",
	            "content": {
	              "type": "CHOICE",
	              "members": [
	                {
	                  "type": "STRING",
	                  "value": "+="
	                },
	                {
	                  "type": "STRING",
	                  "value": "-="
	                },
	                {
	                  "type": "STRING",
	                  "value": "*="
	                },
	                {
	                  "type": "STRING",
	                  "value": "/="
	                },
	                {
	                  "type": "STRING",
	                  "value": "%="
	                },
	                {
	                  "type": "STRING",
	                  "value": "^="
	                },
	                {
	                  "type": "STRING",
	                  "value": "&="
	                },
	                {
	                  "type": "STRING",
	                  "value": "|="
	                },
	                {
	                  "type": "STRING",
	                  "value": ">>="
	                },
	                {
	                  "type": "STRING",
	                  "value": ">>>="
	                },
	                {
	                  "type": "STRING",
	                  "value": "<<="
	                },
	                {
	                  "type": "STRING",
	                  "value": "**="
	                },
	                {
	                  "type": "STRING",
	                  "value": "&&="
	                },
	                {
	                  "type": "STRING",
	                  "value": "||="
	                },
	                {
	                  "type": "STRING",
	                  "value": "??="
	                }
	              ]
	            }
	          },
	          {
	            "type": "FIELD",
	            "name": "right",
	            "content": {
	              "type": "SYMBOL",
	              "name": "expression"
	            }
	          }
	        ]
	      }
	    },
	    "_initializer": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "="
	        },
	        {
	          "type": "FIELD",
	          "name": "value",
	          "content": {
	            "type": "SYMBOL",
	            "name": "expression"
	          }
	        }
	      ]
	    },
	    "_destructuring_pattern": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "SYMBOL",
	          "name": "object_pattern"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "array_pattern"
	        }
	      ]
	    },
	    "spread_element": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "..."
	        },
	        {
	          "type": "SYMBOL",
	          "name": "expression"
	        }
	      ]
	    },
	    "ternary_expression": {
	      "type": "PREC_RIGHT",
	      "value": "ternary",
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "FIELD",
	            "name": "condition",
	            "content": {
	              "type": "SYMBOL",
	              "name": "expression"
	            }
	          },
	          {
	            "type": "ALIAS",
	            "content": {
	              "type": "SYMBOL",
	              "name": "_ternary_qmark"
	            },
	            "named": false,
	            "value": "?"
	          },
	          {
	            "type": "FIELD",
	            "name": "consequence",
	            "content": {
	              "type": "SYMBOL",
	              "name": "expression"
	            }
	          },
	          {
	            "type": "STRING",
	            "value": ":"
	          },
	          {
	            "type": "FIELD",
	            "name": "alternative",
	            "content": {
	              "type": "SYMBOL",
	              "name": "expression"
	            }
	          }
	        ]
	      }
	    },
	    "binary_expression": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "PREC_LEFT",
	          "value": "logical_and",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": "&&"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "logical_or",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": "||"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "binary_shift",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": ">>"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "binary_shift",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": ">>>"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "binary_shift",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": "<<"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "bitwise_and",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": "&"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "bitwise_xor",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": "^"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "bitwise_or",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": "|"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "binary_plus",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": "+"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "binary_plus",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": "-"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "binary_times",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": "*"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "binary_times",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": "/"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "binary_times",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": "%"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "binary_exp",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": "**"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "binary_relation",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": "<"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "binary_relation",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": "<="
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "binary_equality",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": "=="
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "binary_equality",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": "==="
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "binary_equality",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": "!="
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "binary_equality",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": "!=="
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "binary_relation",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": ">="
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "binary_relation",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": ">"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "ternary",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": "??"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "binary_relation",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": "instanceof"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        },
	        {
	          "type": "PREC_LEFT",
	          "value": "binary_relation",
	          "content": {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "left",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "STRING",
	                  "value": "in"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "right",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        }
	      ]
	    },
	    "unary_expression": {
	      "type": "PREC_LEFT",
	      "value": "unary_void",
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "FIELD",
	            "name": "operator",
	            "content": {
	              "type": "CHOICE",
	              "members": [
	                {
	                  "type": "STRING",
	                  "value": "!"
	                },
	                {
	                  "type": "STRING",
	                  "value": "~"
	                },
	                {
	                  "type": "STRING",
	                  "value": "-"
	                },
	                {
	                  "type": "STRING",
	                  "value": "+"
	                },
	                {
	                  "type": "STRING",
	                  "value": "typeof"
	                },
	                {
	                  "type": "STRING",
	                  "value": "void"
	                },
	                {
	                  "type": "STRING",
	                  "value": "delete"
	                }
	              ]
	            }
	          },
	          {
	            "type": "FIELD",
	            "name": "argument",
	            "content": {
	              "type": "SYMBOL",
	              "name": "expression"
	            }
	          }
	        ]
	      }
	    },
	    "update_expression": {
	      "type": "PREC_LEFT",
	      "value": 0,
	      "content": {
	        "type": "CHOICE",
	        "members": [
	          {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "argument",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "CHOICE",
	                  "members": [
	                    {
	                      "type": "STRING",
	                      "value": "++"
	                    },
	                    {
	                      "type": "STRING",
	                      "value": "--"
	                    }
	                  ]
	                }
	              }
	            ]
	          },
	          {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "FIELD",
	                "name": "operator",
	                "content": {
	                  "type": "CHOICE",
	                  "members": [
	                    {
	                      "type": "STRING",
	                      "value": "++"
	                    },
	                    {
	                      "type": "STRING",
	                      "value": "--"
	                    }
	                  ]
	                }
	              },
	              {
	                "type": "FIELD",
	                "name": "argument",
	                "content": {
	                  "type": "SYMBOL",
	                  "name": "expression"
	                }
	              }
	            ]
	          }
	        ]
	      }
	    },
	    "sequence_expression": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "FIELD",
	          "name": "left",
	          "content": {
	            "type": "SYMBOL",
	            "name": "expression"
	          }
	        },
	        {
	          "type": "STRING",
	          "value": ","
	        },
	        {
	          "type": "FIELD",
	          "name": "right",
	          "content": {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "SYMBOL",
	                "name": "sequence_expression"
	              },
	              {
	                "type": "SYMBOL",
	                "name": "expression"
	              }
	            ]
	          }
	        }
	      ]
	    },
	    "string": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "SEQ",
	          "members": [
	            {
	              "type": "STRING",
	              "value": "\""
	            },
	            {
	              "type": "REPEAT",
	              "content": {
	                "type": "CHOICE",
	                "members": [
	                  {
	                    "type": "ALIAS",
	                    "content": {
	                      "type": "SYMBOL",
	                      "name": "unescaped_double_string_fragment"
	                    },
	                    "named": true,
	                    "value": "string_fragment"
	                  },
	                  {
	                    "type": "SYMBOL",
	                    "name": "escape_sequence"
	                  }
	                ]
	              }
	            },
	            {
	              "type": "STRING",
	              "value": "\""
	            }
	          ]
	        },
	        {
	          "type": "SEQ",
	          "members": [
	            {
	              "type": "STRING",
	              "value": "''"
	            },
	            {
	              "type": "REPEAT",
	              "content": {
	                "type": "CHOICE",
	                "members": [
	                  {
	                    "type": "ALIAS",
	                    "content": {
	                      "type": "SYMBOL",
	                      "name": "unescaped_single_string_fragment"
	                    },
	                    "named": true,
	                    "value": "string_fragment"
	                  },
	                  {
	                    "type": "SYMBOL",
	                    "name": "escape_sequence"
	                  }
	                ]
	              }
	            },
	            {
	              "type": "STRING",
	              "value": "''"
	            }
	          ]
	        }
	      ]
	    },
	    "unescaped_double_string_fragment": {
	      "type": "IMMEDIATE_TOKEN",
	      "content": {
	        "type": "PREC",
	        "value": 1,
	        "content": {
	          "type": "PATTERN",
	          "value": "[^\"\\\\]+"
	        }
	      }
	    },
	    "unescaped_single_string_fragment": {
	      "type": "IMMEDIATE_TOKEN",
	      "content": {
	        "type": "PREC",
	        "value": 1,
	        "content": {
	          "type": "PATTERN",
	          "value": "[^''\\\\]+"
	        }
	      }
	    },
	    "escape_sequence": {
	      "type": "IMMEDIATE_TOKEN",
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "STRING",
	            "value": "\\"
	          },
	          {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "PATTERN",
	                "value": "[^xu0-7]"
	              },
	              {
	                "type": "PATTERN",
	                "value": "[0-7]{1,3}"
	              },
	              {
	                "type": "PATTERN",
	                "value": "x[0-9a-fA-F]{2}"
	              },
	              {
	                "type": "PATTERN",
	                "value": "u[0-9a-fA-F]{4}"
	              },
	              {
	                "type": "PATTERN",
	                "value": "u{[0-9a-fA-F]+}"
	              }
	            ]
	          }
	        ]
	      }
	    },
	    "comment": {
	      "type": "TOKEN",
	      "content": {
	        "type": "CHOICE",
	        "members": [
	          {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "STRING",
	                "value": "//"
	              },
	              {
	                "type": "PATTERN",
	                "value": ".*"
	              }
	            ]
	          },
	          {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "STRING",
	                "value": "/*"
	              },
	              {
	                "type": "PATTERN",
	                "value": "[^*]*\\*+([^/*][^*]*\\*+)*"
	              },
	              {
	                "type": "STRING",
	                "value": "/"
	              }
	            ]
	          }
	        ]
	      }
	    },
	    "template_string": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "`"
	        },
	        {
	          "type": "REPEAT",
	          "content": {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "SYMBOL",
	                "name": "_template_chars"
	              },
	              {
	                "type": "SYMBOL",
	                "name": "escape_sequence"
	              },
	              {
	                "type": "SYMBOL",
	                "name": "template_substitution"
	              }
	            ]
	          }
	        },
	        {
	          "type": "STRING",
	          "value": "`"
	        }
	      ]
	    },
	    "template_substitution": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "${"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "_expressions"
	        },
	        {
	          "type": "STRING",
	          "value": "}"
	        }
	      ]
	    },
	    "regex": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "/"
	        },
	        {
	          "type": "FIELD",
	          "name": "pattern",
	          "content": {
	            "type": "SYMBOL",
	            "name": "regex_pattern"
	          }
	        },
	        {
	          "type": "IMMEDIATE_TOKEN",
	          "content": {
	            "type": "STRING",
	            "value": "/"
	          }
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "FIELD",
	              "name": "flags",
	              "content": {
	                "type": "SYMBOL",
	                "name": "regex_flags"
	              }
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        }
	      ]
	    },
	    "regex_pattern": {
	      "type": "IMMEDIATE_TOKEN",
	      "content": {
	        "type": "PREC",
	        "value": -1,
	        "content": {
	          "type": "REPEAT1",
	          "content": {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "SEQ",
	                "members": [
	                  {
	                    "type": "STRING",
	                    "value": "["
	                  },
	                  {
	                    "type": "REPEAT",
	                    "content": {
	                      "type": "CHOICE",
	                      "members": [
	                        {
	                          "type": "SEQ",
	                          "members": [
	                            {
	                              "type": "STRING",
	                              "value": "\\"
	                            },
	                            {
	                              "type": "PATTERN",
	                              "value": "."
	                            }
	                          ]
	                        },
	                        {
	                          "type": "PATTERN",
	                          "value": "[^\\]\\n\\\\]"
	                        }
	                      ]
	                    }
	                  },
	                  {
	                    "type": "STRING",
	                    "value": "]"
	                  }
	                ]
	              },
	              {
	                "type": "SEQ",
	                "members": [
	                  {
	                    "type": "STRING",
	                    "value": "\\"
	                  },
	                  {
	                    "type": "PATTERN",
	                    "value": "."
	                  }
	                ]
	              },
	              {
	                "type": "PATTERN",
	                "value": "[^/\\\\\\[\\n]"
	              }
	            ]
	          }
	        }
	      }
	    },
	    "regex_flags": {
	      "type": "IMMEDIATE_TOKEN",
	      "content": {
	        "type": "PATTERN",
	        "value": "[a-z]+"
	      }
	    },
	    "number": {
	      "type": "TOKEN",
	      "content": {
	        "type": "CHOICE",
	        "members": [
	          {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "CHOICE",
	                "members": [
	                  {
	                    "type": "STRING",
	                    "value": "0x"
	                  },
	                  {
	                    "type": "STRING",
	                    "value": "0X"
	                  }
	                ]
	              },
	              {
	                "type": "PATTERN",
	                "value": "[\\da-fA-F](_?[\\da-fA-F])*"
	              }
	            ]
	          },
	          {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "SEQ",
	                "members": [
	                  {
	                    "type": "CHOICE",
	                    "members": [
	                      {
	                        "type": "STRING",
	                        "value": "0"
	                      },
	                      {
	                        "type": "SEQ",
	                        "members": [
	                          {
	                            "type": "CHOICE",
	                            "members": [
	                              {
	                                "type": "STRING",
	                                "value": "0"
	                              },
	                              {
	                                "type": "BLANK"
	                              }
	                            ]
	                          },
	                          {
	                            "type": "PATTERN",
	                            "value": "[1-9]"
	                          },
	                          {
	                            "type": "CHOICE",
	                            "members": [
	                              {
	                                "type": "SEQ",
	                                "members": [
	                                  {
	                                    "type": "CHOICE",
	                                    "members": [
	                                      {
	                                        "type": "STRING",
	                                        "value": "_"
	                                      },
	                                      {
	                                        "type": "BLANK"
	                                      }
	                                    ]
	                                  },
	                                  {
	                                    "type": "PATTERN",
	                                    "value": "\\d(_?\\d)*"
	                                  }
	                                ]
	                              },
	                              {
	                                "type": "BLANK"
	                              }
	                            ]
	                          }
	                        ]
	                      }
	                    ]
	                  },
	                  {
	                    "type": "STRING",
	                    "value": "."
	                  },
	                  {
	                    "type": "CHOICE",
	                    "members": [
	                      {
	                        "type": "PATTERN",
	                        "value": "\\d(_?\\d)*"
	                      },
	                      {
	                        "type": "BLANK"
	                      }
	                    ]
	                  },
	                  {
	                    "type": "CHOICE",
	                    "members": [
	                      {
	                        "type": "SEQ",
	                        "members": [
	                          {
	                            "type": "CHOICE",
	                            "members": [
	                              {
	                                "type": "STRING",
	                                "value": "e"
	                              },
	                              {
	                                "type": "STRING",
	                                "value": "E"
	                              }
	                            ]
	                          },
	                          {
	                            "type": "SEQ",
	                            "members": [
	                              {
	                                "type": "CHOICE",
	                                "members": [
	                                  {
	                                    "type": "CHOICE",
	                                    "members": [
	                                      {
	                                        "type": "STRING",
	                                        "value": "-"
	                                      },
	                                      {
	                                        "type": "STRING",
	                                        "value": "+"
	                                      }
	                                    ]
	                                  },
	                                  {
	                                    "type": "BLANK"
	                                  }
	                                ]
	                              },
	                              {
	                                "type": "PATTERN",
	                                "value": "\\d(_?\\d)*"
	                              }
	                            ]
	                          }
	                        ]
	                      },
	                      {
	                        "type": "BLANK"
	                      }
	                    ]
	                  }
	                ]
	              },
	              {
	                "type": "SEQ",
	                "members": [
	                  {
	                    "type": "STRING",
	                    "value": "."
	                  },
	                  {
	                    "type": "PATTERN",
	                    "value": "\\d(_?\\d)*"
	                  },
	                  {
	                    "type": "CHOICE",
	                    "members": [
	                      {
	                        "type": "SEQ",
	                        "members": [
	                          {
	                            "type": "CHOICE",
	                            "members": [
	                              {
	                                "type": "STRING",
	                                "value": "e"
	                              },
	                              {
	                                "type": "STRING",
	                                "value": "E"
	                              }
	                            ]
	                          },
	                          {
	                            "type": "SEQ",
	                            "members": [
	                              {
	                                "type": "CHOICE",
	                                "members": [
	                                  {
	                                    "type": "CHOICE",
	                                    "members": [
	                                      {
	                                        "type": "STRING",
	                                        "value": "-"
	                                      },
	                                      {
	                                        "type": "STRING",
	                                        "value": "+"
	                                      }
	                                    ]
	                                  },
	                                  {
	                                    "type": "BLANK"
	                                  }
	                                ]
	                              },
	                              {
	                                "type": "PATTERN",
	                                "value": "\\d(_?\\d)*"
	                              }
	                            ]
	                          }
	                        ]
	                      },
	                      {
	                        "type": "BLANK"
	                      }
	                    ]
	                  }
	                ]
	              },
	              {
	                "type": "SEQ",
	                "members": [
	                  {
	                    "type": "CHOICE",
	                    "members": [
	                      {
	                        "type": "STRING",
	                        "value": "0"
	                      },
	                      {
	                        "type": "SEQ",
	                        "members": [
	                          {
	                            "type": "CHOICE",
	                            "members": [
	                              {
	                                "type": "STRING",
	                                "value": "0"
	                              },
	                              {
	                                "type": "BLANK"
	                              }
	                            ]
	                          },
	                          {
	                            "type": "PATTERN",
	                            "value": "[1-9]"
	                          },
	                          {
	                            "type": "CHOICE",
	                            "members": [
	                              {
	                                "type": "SEQ",
	                                "members": [
	                                  {
	                                    "type": "CHOICE",
	                                    "members": [
	                                      {
	                                        "type": "STRING",
	                                        "value": "_"
	                                      },
	                                      {
	                                        "type": "BLANK"
	                                      }
	                                    ]
	                                  },
	                                  {
	                                    "type": "PATTERN",
	                                    "value": "\\d(_?\\d)*"
	                                  }
	                                ]
	                              },
	                              {
	                                "type": "BLANK"
	                              }
	                            ]
	                          }
	                        ]
	                      }
	                    ]
	                  },
	                  {
	                    "type": "SEQ",
	                    "members": [
	                      {
	                        "type": "CHOICE",
	                        "members": [
	                          {
	                            "type": "STRING",
	                            "value": "e"
	                          },
	                          {
	                            "type": "STRING",
	                            "value": "E"
	                          }
	                        ]
	                      },
	                      {
	                        "type": "SEQ",
	                        "members": [
	                          {
	                            "type": "CHOICE",
	                            "members": [
	                              {
	                                "type": "CHOICE",
	                                "members": [
	                                  {
	                                    "type": "STRING",
	                                    "value": "-"
	                                  },
	                                  {
	                                    "type": "STRING",
	                                    "value": "+"
	                                  }
	                                ]
	                              },
	                              {
	                                "type": "BLANK"
	                              }
	                            ]
	                          },
	                          {
	                            "type": "PATTERN",
	                            "value": "\\d(_?\\d)*"
	                          }
	                        ]
	                      }
	                    ]
	                  }
	                ]
	              },
	              {
	                "type": "SEQ",
	                "members": [
	                  {
	                    "type": "PATTERN",
	                    "value": "\\d(_?\\d)*"
	                  }
	                ]
	              }
	            ]
	          },
	          {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "CHOICE",
	                "members": [
	                  {
	                    "type": "STRING",
	                    "value": "0b"
	                  },
	                  {
	                    "type": "STRING",
	                    "value": "0B"
	                  }
	                ]
	              },
	              {
	                "type": "PATTERN",
	                "value": "[0-1](_?[0-1])*"
	              }
	            ]
	          },
	          {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "CHOICE",
	                "members": [
	                  {
	                    "type": "STRING",
	                    "value": "0o"
	                  },
	                  {
	                    "type": "STRING",
	                    "value": "0O"
	                  }
	                ]
	              },
	              {
	                "type": "PATTERN",
	                "value": "[0-7](_?[0-7])*"
	              }
	            ]
	          },
	          {
	            "type": "SEQ",
	            "members": [
	              {
	                "type": "CHOICE",
	                "members": [
	                  {
	                    "type": "SEQ",
	                    "members": [
	                      {
	                        "type": "CHOICE",
	                        "members": [
	                          {
	                            "type": "STRING",
	                            "value": "0x"
	                          },
	                          {
	                            "type": "STRING",
	                            "value": "0X"
	                          }
	                        ]
	                      },
	                      {
	                        "type": "PATTERN",
	                        "value": "[\\da-fA-F](_?[\\da-fA-F])*"
	                      }
	                    ]
	                  },
	                  {
	                    "type": "SEQ",
	                    "members": [
	                      {
	                        "type": "CHOICE",
	                        "members": [
	                          {
	                            "type": "STRING",
	                            "value": "0b"
	                          },
	                          {
	                            "type": "STRING",
	                            "value": "0B"
	                          }
	                        ]
	                      },
	                      {
	                        "type": "PATTERN",
	                        "value": "[0-1](_?[0-1])*"
	                      }
	                    ]
	                  },
	                  {
	                    "type": "SEQ",
	                    "members": [
	                      {
	                        "type": "CHOICE",
	                        "members": [
	                          {
	                            "type": "STRING",
	                            "value": "0o"
	                          },
	                          {
	                            "type": "STRING",
	                            "value": "0O"
	                          }
	                        ]
	                      },
	                      {
	                        "type": "PATTERN",
	                        "value": "[0-7](_?[0-7])*"
	                      }
	                    ]
	                  },
	                  {
	                    "type": "PATTERN",
	                    "value": "\\d(_?\\d)*"
	                  }
	                ]
	              },
	              {
	                "type": "STRING",
	                "value": "n"
	              }
	            ]
	          }
	        ]
	      }
	    },
	    "_identifier": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "SYMBOL",
	          "name": "undefined"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "identifier"
	        }
	      ]
	    },
	    "identifier": {
	      "type": "TOKEN",
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "PATTERN",
	            "value": "[^\\x00-\\x1F\\s\\p{Zs}0-9:;`\"''@#.,|^&<=>+\\-*/\\\\%?!~()\\[\\]{}\\uFEFF\\u2060\\u200B]|\\\\u[0-9a-fA-F]{4}|\\\\u\\{[0-9a-fA-F]+\\}"
	          },
	          {
	            "type": "REPEAT",
	            "content": {
	              "type": "PATTERN",
	              "value": "[^\\x00-\\x1F\\s\\p{Zs}:;`\"''@#.,|^&<=>+\\-*/\\\\%?!~()\\[\\]{}\\uFEFF\\u2060\\u200B]|\\\\u[0-9a-fA-F]{4}|\\\\u\\{[0-9a-fA-F]+\\}"
	            }
	          }
	        ]
	      }
	    },
	    "private_property_identifier": {
	      "type": "TOKEN",
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "STRING",
	            "value": "#"
	          },
	          {
	            "type": "PATTERN",
	            "value": "[^\\x00-\\x1F\\s\\p{Zs}0-9:;`\"''@#.,|^&<=>+\\-*/\\\\%?!~()\\[\\]{}\\uFEFF\\u2060\\u200B]|\\\\u[0-9a-fA-F]{4}|\\\\u\\{[0-9a-fA-F]+\\}"
	          },
	          {
	            "type": "REPEAT",
	            "content": {
	              "type": "PATTERN",
	              "value": "[^\\x00-\\x1F\\s\\p{Zs}:;`\"''@#.,|^&<=>+\\-*/\\\\%?!~()\\[\\]{}\\uFEFF\\u2060\\u200B]|\\\\u[0-9a-fA-F]{4}|\\\\u\\{[0-9a-fA-F]+\\}"
	            }
	          }
	        ]
	      }
	    },
	    "meta_property": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "new"
	        },
	        {
	          "type": "STRING",
	          "value": "."
	        },
	        {
	          "type": "STRING",
	          "value": "target"
	        }
	      ]
	    },
	    "this": {
	      "type": "STRING",
	      "value": "this"
	    },
	    "super": {
	      "type": "STRING",
	      "value": "super"
	    },
	    "true": {
	      "type": "STRING",
	      "value": "true"
	    },
	    "false": {
	      "type": "STRING",
	      "value": "false"
	    },
	    "null": {
	      "type": "STRING",
	      "value": "null"
	    },
	    "undefined": {
	      "type": "STRING",
	      "value": "undefined"
	    },
	    "arguments": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "("
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "SEQ",
	              "members": [
	                {
	                  "type": "CHOICE",
	                  "members": [
	                    {
	                      "type": "CHOICE",
	                      "members": [
	                        {
	                          "type": "SYMBOL",
	                          "name": "expression"
	                        },
	                        {
	                          "type": "SYMBOL",
	                          "name": "spread_element"
	                        }
	                      ]
	                    },
	                    {
	                      "type": "BLANK"
	                    }
	                  ]
	                },
	                {
	                  "type": "REPEAT",
	                  "content": {
	                    "type": "SEQ",
	                    "members": [
	                      {
	                        "type": "STRING",
	                        "value": ","
	                      },
	                      {
	                        "type": "CHOICE",
	                        "members": [
	                          {
	                            "type": "CHOICE",
	                            "members": [
	                              {
	                                "type": "SYMBOL",
	                                "name": "expression"
	                              },
	                              {
	                                "type": "SYMBOL",
	                                "name": "spread_element"
	                              }
	                            ]
	                          },
	                          {
	                            "type": "BLANK"
	                          }
	                        ]
	                      }
	                    ]
	                  }
	                }
	              ]
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        },
	        {
	          "type": "STRING",
	          "value": ")"
	        }
	      ]
	    },
	    "decorator": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "@"
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "SYMBOL",
	              "name": "identifier"
	            },
	            {
	              "type": "ALIAS",
	              "content": {
	                "type": "SYMBOL",
	                "name": "decorator_member_expression"
	              },
	              "named": true,
	              "value": "member_expression"
	            },
	            {
	              "type": "ALIAS",
	              "content": {
	                "type": "SYMBOL",
	                "name": "decorator_call_expression"
	              },
	              "named": true,
	              "value": "call_expression"
	            }
	          ]
	        }
	      ]
	    },
	    "decorator_member_expression": {
	      "type": "PREC",
	      "value": "member",
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "FIELD",
	            "name": "object",
	            "content": {
	              "type": "CHOICE",
	              "members": [
	                {
	                  "type": "SYMBOL",
	                  "name": "identifier"
	                },
	                {
	                  "type": "ALIAS",
	                  "content": {
	                    "type": "SYMBOL",
	                    "name": "decorator_member_expression"
	                  },
	                  "named": true,
	                  "value": "member_expression"
	                }
	              ]
	            }
	          },
	          {
	            "type": "STRING",
	            "value": "."
	          },
	          {
	            "type": "FIELD",
	            "name": "property",
	            "content": {
	              "type": "ALIAS",
	              "content": {
	                "type": "SYMBOL",
	                "name": "identifier"
	              },
	              "named": true,
	              "value": "property_identifier"
	            }
	          }
	        ]
	      }
	    },
	    "decorator_call_expression": {
	      "type": "PREC",
	      "value": "call",
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "FIELD",
	            "name": "function",
	            "content": {
	              "type": "CHOICE",
	              "members": [
	                {
	                  "type": "SYMBOL",
	                  "name": "identifier"
	                },
	                {
	                  "type": "ALIAS",
	                  "content": {
	                    "type": "SYMBOL",
	                    "name": "decorator_member_expression"
	                  },
	                  "named": true,
	                  "value": "member_expression"
	                }
	              ]
	            }
	          },
	          {
	            "type": "FIELD",
	            "name": "arguments",
	            "content": {
	              "type": "SYMBOL",
	              "name": "arguments"
	            }
	          }
	        ]
	      }
	    },
	    "class_body": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "{"
	        },
	        {
	          "type": "REPEAT",
	          "content": {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "SEQ",
	                "members": [
	                  {
	                    "type": "FIELD",
	                    "name": "member",
	                    "content": {
	                      "type": "SYMBOL",
	                      "name": "method_definition"
	                    }
	                  },
	                  {
	                    "type": "CHOICE",
	                    "members": [
	                      {
	                        "type": "STRING",
	                        "value": ";"
	                      },
	                      {
	                        "type": "BLANK"
	                      }
	                    ]
	                  }
	                ]
	              },
	              {
	                "type": "SEQ",
	                "members": [
	                  {
	                    "type": "FIELD",
	                    "name": "member",
	                    "content": {
	                      "type": "SYMBOL",
	                      "name": "field_definition"
	                    }
	                  },
	                  {
	                    "type": "SYMBOL",
	                    "name": "_semicolon"
	                  }
	                ]
	              }
	            ]
	          }
	        },
	        {
	          "type": "STRING",
	          "value": "}"
	        }
	      ]
	    },
	    "field_definition": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "REPEAT",
	          "content": {
	            "type": "FIELD",
	            "name": "decorator",
	            "content": {
	              "type": "SYMBOL",
	              "name": "decorator"
	            }
	          }
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "STRING",
	              "value": "static"
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        },
	        {
	          "type": "FIELD",
	          "name": "property",
	          "content": {
	            "type": "SYMBOL",
	            "name": "_property_name"
	          }
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "SYMBOL",
	              "name": "_initializer"
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        }
	      ]
	    },
	    "formal_parameters": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "("
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "SEQ",
	              "members": [
	                {
	                  "type": "SEQ",
	                  "members": [
	                    {
	                      "type": "SYMBOL",
	                      "name": "_formal_parameter"
	                    },
	                    {
	                      "type": "REPEAT",
	                      "content": {
	                        "type": "SEQ",
	                        "members": [
	                          {
	                            "type": "STRING",
	                            "value": ","
	                          },
	                          {
	                            "type": "SYMBOL",
	                            "name": "_formal_parameter"
	                          }
	                        ]
	                      }
	                    }
	                  ]
	                },
	                {
	                  "type": "CHOICE",
	                  "members": [
	                    {
	                      "type": "STRING",
	                      "value": ","
	                    },
	                    {
	                      "type": "BLANK"
	                    }
	                  ]
	                }
	              ]
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        },
	        {
	          "type": "STRING",
	          "value": ")"
	        }
	      ]
	    },
	    "pattern": {
	      "type": "PREC_DYNAMIC",
	      "value": -1,
	      "content": {
	        "type": "CHOICE",
	        "members": [
	          {
	            "type": "SYMBOL",
	            "name": "_lhs_expression"
	          },
	          {
	            "type": "SYMBOL",
	            "name": "rest_pattern"
	          }
	        ]
	      }
	    },
	    "rest_pattern": {
	      "type": "PREC_RIGHT",
	      "value": 0,
	      "content": {
	        "type": "SEQ",
	        "members": [
	          {
	            "type": "STRING",
	            "value": "..."
	          },
	          {
	            "type": "SYMBOL",
	            "name": "_lhs_expression"
	          }
	        ]
	      }
	    },
	    "method_definition": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "REPEAT",
	          "content": {
	            "type": "FIELD",
	            "name": "decorator",
	            "content": {
	              "type": "SYMBOL",
	              "name": "decorator"
	            }
	          }
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "STRING",
	              "value": "static"
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "STRING",
	              "value": "async"
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        },
	        {
	          "type": "CHOICE",
	          "members": [
	            {
	              "type": "CHOICE",
	              "members": [
	                {
	                  "type": "STRING",
	                  "value": "get"
	                },
	                {
	                  "type": "STRING",
	                  "value": "set"
	                },
	                {
	                  "type": "STRING",
	                  "value": "*"
	                }
	              ]
	            },
	            {
	              "type": "BLANK"
	            }
	          ]
	        },
	        {
	          "type": "FIELD",
	          "name": "name",
	          "content": {
	            "type": "SYMBOL",
	            "name": "_property_name"
	          }
	        },
	        {
	          "type": "FIELD",
	          "name": "parameters",
	          "content": {
	            "type": "SYMBOL",
	            "name": "formal_parameters"
	          }
	        },
	        {
	          "type": "FIELD",
	          "name": "body",
	          "content": {
	            "type": "SYMBOL",
	            "name": "statement_block"
	          }
	        }
	      ]
	    },
	    "pair": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "FIELD",
	          "name": "key",
	          "content": {
	            "type": "SYMBOL",
	            "name": "_property_name"
	          }
	        },
	        {
	          "type": "STRING",
	          "value": ":"
	        },
	        {
	          "type": "FIELD",
	          "name": "value",
	          "content": {
	            "type": "SYMBOL",
	            "name": "expression"
	          }
	        }
	      ]
	    },
	    "pair_pattern": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "FIELD",
	          "name": "key",
	          "content": {
	            "type": "SYMBOL",
	            "name": "_property_name"
	          }
	        },
	        {
	          "type": "STRING",
	          "value": ":"
	        },
	        {
	          "type": "FIELD",
	          "name": "value",
	          "content": {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "SYMBOL",
	                "name": "pattern"
	              },
	              {
	                "type": "SYMBOL",
	                "name": "assignment_pattern"
	              }
	            ]
	          }
	        }
	      ]
	    },
	    "_property_name": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "ALIAS",
	          "content": {
	            "type": "CHOICE",
	            "members": [
	              {
	                "type": "SYMBOL",
	                "name": "identifier"
	              },
	              {
	                "type": "SYMBOL",
	                "name": "_reserved_identifier"
	              }
	            ]
	          },
	          "named": true,
	          "value": "property_identifier"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "private_property_identifier"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "string"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "number"
	        },
	        {
	          "type": "SYMBOL",
	          "name": "computed_property_name"
	        }
	      ]
	    },
	    "computed_property_name": {
	      "type": "SEQ",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "["
	        },
	        {
	          "type": "SYMBOL",
	          "name": "expression"
	        },
	        {
	          "type": "STRING",
	          "value": "]"
	        }
	      ]
	    },
	    "_reserved_identifier": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "STRING",
	          "value": "get"
	        },
	        {
	          "type": "STRING",
	          "value": "set"
	        },
	        {
	          "type": "STRING",
	          "value": "async"
	        },
	        {
	          "type": "STRING",
	          "value": "static"
	        },
	        {
	          "type": "STRING",
	          "value": "export"
	        }
	      ]
	    },
	    "_semicolon": {
	      "type": "CHOICE",
	      "members": [
	        {
	          "type": "SYMBOL",
	          "name": "_automatic_semicolon"
	        },
	        {
	          "type": "STRING",
	          "value": ";"
	        }
	      ]
	    }
	  },
	  "extras": [
	    {
	      "type": "SYMBOL",
	      "name": "comment"
	    },
	    {
	      "type": "PATTERN",
	      "value": "[\\s\\p{Zs}\\uFEFF\\u2060\\u200B]"
	    }
	  ],
	  "conflicts": [
	    [
	      "primary_expression",
	      "_property_name"
	    ],
	    [
	      "primary_expression",
	      "_property_name",
	      "arrow_function"
	    ],
	    [
	      "primary_expression",
	      "arrow_function"
	    ],
	    [
	      "primary_expression",
	      "method_definition"
	    ],
	    [
	      "primary_expression",
	      "rest_pattern"
	    ],
	    [
	      "primary_expression",
	      "pattern"
	    ],
	    [
	      "primary_expression",
	      "_for_header"
	    ],
	    [
	      "array",
	      "array_pattern"
	    ],
	    [
	      "object",
	      "object_pattern"
	    ],
	    [
	      "assignment_expression",
	      "pattern"
	    ],
	    [
	      "assignment_expression",
	      "object_assignment_pattern"
	    ],
	    [
	      "labeled_statement",
	      "_property_name"
	    ],
	    [
	      "computed_property_name",
	      "array"
	    ],
	    [
	      "binary_expression",
	      "_initializer"
	    ]
	  ],
	  "precedences": [
	    [
	      {
	        "type": "STRING",
	        "value": "member"
	      },
	      {
	        "type": "STRING",
	        "value": "call"
	      },
	      {
	        "type": "SYMBOL",
	        "name": "update_expression"
	      },
	      {
	        "type": "STRING",
	        "value": "unary_void"
	      },
	      {
	        "type": "STRING",
	        "value": "binary_exp"
	      },
	      {
	        "type": "STRING",
	        "value": "binary_times"
	      },
	      {
	        "type": "STRING",
	        "value": "binary_plus"
	      },
	      {
	        "type": "STRING",
	        "value": "binary_shift"
	      },
	      {
	        "type": "STRING",
	        "value": "binary_compare"
	      },
	      {
	        "type": "STRING",
	        "value": "binary_relation"
	      },
	      {
	        "type": "STRING",
	        "value": "binary_equality"
	      },
	      {
	        "type": "STRING",
	        "value": "bitwise_and"
	      },
	      {
	        "type": "STRING",
	        "value": "bitwise_xor"
	      },
	      {
	        "type": "STRING",
	        "value": "bitwise_or"
	      },
	      {
	        "type": "STRING",
	        "value": "logical_and"
	      },
	      {
	        "type": "STRING",
	        "value": "logical_or"
	      },
	      {
	        "type": "STRING",
	        "value": "ternary"
	      },
	      {
	        "type": "SYMBOL",
	        "name": "sequence_expression"
	      },
	      {
	        "type": "SYMBOL",
	        "name": "arrow_function"
	      }
	    ],
	    [
	      {
	        "type": "STRING",
	        "value": "assign"
	      },
	      {
	        "type": "SYMBOL",
	        "name": "primary_expression"
	      }
	    ],
	    [
	      {
	        "type": "STRING",
	        "value": "member"
	      },
	      {
	        "type": "STRING",
	        "value": "new"
	      },
	      {
	        "type": "STRING",
	        "value": "call"
	      },
	      {
	        "type": "SYMBOL",
	        "name": "expression"
	      }
	    ],
	    [
	      {
	        "type": "STRING",
	        "value": "declaration"
	      },
	      {
	        "type": "STRING",
	        "value": "literal"
	      }
	    ],
	    [
	      {
	        "type": "SYMBOL",
	        "name": "primary_expression"
	      },
	      {
	        "type": "SYMBOL",
	        "name": "statement_block"
	      },
	      {
	        "type": "STRING",
	        "value": "object"
	      }
	    ],
	    [
	      {
	        "type": "SYMBOL",
	        "name": "import_statement"
	      },
	      {
	        "type": "SYMBOL",
	        "name": "import"
	      }
	    ],
	    [
	      {
	        "type": "SYMBOL",
	        "name": "export_statement"
	      },
	      {
	        "type": "SYMBOL",
	        "name": "primary_expression"
	      }
	    ]
	  ],
	  "externals": [
	    {
	      "type": "SYMBOL",
	      "name": "_automatic_semicolon"
	    },
	    {
	      "type": "SYMBOL",
	      "name": "_template_chars"
	    },
	    {
	      "type": "SYMBOL",
	      "name": "_ternary_qmark"
	    }
	  ],
	  "inline": [
	    "_call_signature",
	    "_formal_parameter",
	    "statement",
	    "_expressions",
	    "_semicolon",
	    "_identifier",
	    "_reserved_identifier",
	    "_jsx_attribute",
	    "_jsx_element_name",
	    "_jsx_child",
	    "_jsx_element",
	    "_jsx_attribute_name",
	    "_jsx_attribute_value",
	    "_jsx_identifier",
	    "_lhs_expression"
	  ],
	  "supertypes": [
	    "statement",
	    "declaration",
	    "expression",
	    "primary_expression",
	    "pattern"
	  ]
	}
	
	'
]

{ #category : #'configuration - layout' }
SBJavascript class >> hardLineBreakBetween: aBlock and: anotherBlock [

	(super hardLineBreakBetween: aBlock and: anotherBlock) ifTrue: [^ true].
	aBlock parentSandblock type = #'class_body' ifTrue: [^ true].
	anotherBlock type = #'else_clause' ifTrue: [^ true].
	(aBlock contents = '{' and: [aBlock parentSandblock type = #'statement_block']) ifTrue: [^ true].
	^ #(#'statement_block' #'class_body') includes: anotherBlock type
]

{ #category : #configuration }
SBJavascript class >> highlightQuery [
	" https://github.com/tree-sitter/tree-sitter-javascript/blob/master/queries/highlights.scm "

	^ '; Special identifiers
	;--------------------
	
	([
	    (identifier)
	    (shorthand_property_identifier)
	    (shorthand_property_identifier_pattern)
	 ] @constant
	 (#match? @constant "^[A-Z_][A-Z\\d_]+$"))
	
	
	((identifier) @constructor
	 (#match? @constructor "^[A-Z]"))
	
	((identifier) @variable.builtin
	 (#match? @variable.builtin "^(arguments|module|console|window|document)$")
	 (#is-not? local))
	
	((identifier) @function.builtin
	 (#eq? @function.builtin "require")
	 (#is-not? local))
	
	; Function and method definitions
	;--------------------------------
	
	(function
	  name: (identifier) @function)
	(function_declaration
	  name: (identifier) @function)
	(method_definition
	  name: (property_identifier) @function.method)
	
	(pair
	  key: (property_identifier) @function.method
	  value: [(function) (arrow_function)])
	
	(assignment_expression
	  left: (member_expression
	    property: (property_identifier) @function.method)
	  right: [(function) (arrow_function)])
	
	(variable_declarator
	  name: (identifier) @function
	  value: [(function) (arrow_function)])
	
	(assignment_expression
	  left: (identifier) @function
	  right: [(function) (arrow_function)])
	
	; Function and method calls
	;--------------------------
	
	(call_expression
	  function: (identifier) @function)
	
	(call_expression
	  function: (member_expression
	    property: (property_identifier) @function.method))
	
	; Variables
	;----------
	
	(identifier) @variable
	
	; Properties
	;-----------
	
	(property_identifier) @property
	
	; Literals
	;---------
	
	(this) @variable.builtin
	(super) @variable.builtin
	
	[
	  (true)
	  (false)
	  (null)
	  (undefined)
	] @constant.builtin
	
	(comment) @comment
	
	[
	  (string)
	  (template_string)
	] @string
	
	(regex) @string.special
	(number) @number
	
	; Tokens
	;-------
	
	(template_substitution
	  "${" @punctuation.special
	  "}" @punctuation.special) @embedded
	
	[
	  ";"
	  "?."
	  "."
	  ","
	] @punctuation.delimiter
	
	[
	  "-"
	  "--"
	  "-="
	  "+"
	  "++"
	  "+="
	  "*"
	  "*="
	  "**"
	  "**="
	  "/"
	  "/="
	  "%"
	  "%="
	  "<"
	  "<="
	  "<<"
	  "<<="
	  "="
	  "=="
	  "==="
	  "!"
	  "!="
	  "!=="
	  "=>"
	  ">"
	  ">="
	  ">>"
	  ">>="
	  ">>>"
	  ">>>="
	  "~"
	  "^"
	  "&"
	  "|"
	  "^="
	  "&="
	  "|="
	  "&&"
	  "||"
	  "??"
	  "&&="
	  "||="
	  "??="
	] @operator
	
	[
	  "("
	  ")"
	  "["
	  "]"
	  "{"
	  "}"
	]  @punctuation.bracket
	
	[
	  "as"
	  "async"
	  "await"
	  "break"
	  "case"
	  "catch"
	  "class"
	  "const"
	  "continue"
	  "debugger"
	  "default"
	  "delete"
	  "do"
	  "else"
	  "export"
	  "extends"
	  "finally"
	  "for"
	  "from"
	  "function"
	  "get"
	  "if"
	  "import"
	  "in"
	  "instanceof"
	  "let"
	  "new"
	  "of"
	  "return"
	  "set"
	  "static"
	  "switch"
	  "target"
	  "throw"
	  "try"
	  "typeof"
	  "var"
	  "void"
	  "while"
	  "with"
	  "yield"
	] @keyword'
]

{ #category : #configuration }
SBJavascript class >> icon [

	^ Form
		extent: 16 @ 16
		depth: 32
		fromArray: #(4294370048 4294436096 4294436096 4294436096 4294436096 4294436096 4294436096 4294436096 4294436096 4294436096 4294436096 4294436096 4294436096 4294436096 4294435840 4294370048 4294435840 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436096 4294435840 4294436096 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436096 4294436096 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436096 4294436096 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436096 4294436096 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294502144 4294436352 4294436352 4294436096 4294436096 4294436352 4294436352 4294436352 4294436352 4294436352 4294436352 4294700800 4294635008 4294436096 4294634496 4294701056 4294635008 4294701056 4294502144 4294436096 4294436096 4294436352 4294436352 4294436352 4294436352 4294502144 4294502656 4286082560 4286740224 4294701312 4292002304 4283977984 4282399488 4287924224 4294304768 4294436352 4294436096 4294436352 4294436352 4294436352 4294436352 4294502144 4294568704 4280689408 4282004480 4294568704 4280886528 4280360450 4282991360 4280031490 4292659968 4294568448 4294436096 4294436352 4294436352 4294436352 4294436352 4294502144 4294568448 4281347072 4282728192 4294040576 4278255872 4284701184 4294701312 4294172928 4294502656 4294436096 4294436096 4294436352 4294436352 4294436352 4294436352 4294502144 4294568448 4281347072 4282465024 4294833152 4284964352 4278190080 4281347072 4289240064 4294568448 4294436352 4294436096 4294436352 4294436352 4294436352 4294502656 4294634752 4294568704 4281347072 4282399232 4294767104 4294701056 4288516608 4281018113 4278190080 4287792384 4294701056 4294436096 4294436352 4294436352 4294502400 4293712128 4292199680 4294833152 4281083904 4282465024 4294173952 4290094848 4294634752 4294700800 4280623617 4281872896 4294634496 4294436096 4294436352 4294502144 4294701312 4285950720 4278584577 4283320320 4278190080 4286608384 4291739136 4278190080 4281478400 4283780864 4278190080 4285490432 4294701056 4294435840 4294436096 4294436096 4294502656 4292989184 4285424896 4282202112 4285885184 4293778432 4294634496 4290029056 4283451648 4282136320 4286411520 4293843968 4294502144 4294435840 4294436096 4294436096 4294435840 4294502656 4294701056 4294634496 4294701056 4294502144 4294435840 4294635008 4294700800 4294634496 4294701312 4294502144 4294370048)
		offset: 0 @ 0
]

{ #category : #'configuration - editing' }
SBJavascript class >> inputTransitionBlackList [
	"return a list of types that should not be considered during transitions, e.g. the typical C comma operator that just chains multiple expressions and thus yields mostly noise"

	^ #(#'sequence_expression')
]

{ #category : #'configuration - editing' }
SBJavascript class >> isBlockInlined: aSymbol [

	^ aSymbol = #'expression_statement' or: [super isBlockInlined: aSymbol]
]

{ #category : #'configuration - editing' }
SBJavascript class >> isBlockInlinedInParent: aSymbol [

	^ aSymbol = #'formal_parameters' or: [aSymbol = #arguments]
]

{ #category : #'configuration - layout' }
SBJavascript class >> isImmutableLabel: aLabelNode [

	^ (super isImmutableLabel: aLabelNode) or: [#(';') includes: aLabelNode label]
]

{ #category : #'configuration - declarations' }
SBJavascript class >> isScope: aBlock [

	^ #('function' 'program' 'statement_block') includes: aBlock type
]

{ #category : #'configuration - editing' }
SBJavascript class >> isStatementContainer: aRepeatNode in: aBlock [

	^ aRepeatNode element type = 'statement'
]

{ #category : #configuration }
SBJavascript class >> language [

	^ #javascript
]

{ #category : #'configuration - editing' }
SBJavascript class >> noteUncapturedText [

	^ #('template_string')
]

{ #category : #configuration }
SBJavascript class >> preprocessGrammar: aGrammar [
	"for some reason the member_expression accepts both primary_expr and expr as options, which lets our parser think that matches are ambiguous"

	(aGrammar bodyNodeForRule: #'member_expression') element elements first replaceBy: (aGrammar bodyNodeForRule: #'member_expression') element elements first elements first.
	(aGrammar bodyNodeForRule: #'subscript_expression') element elements first replaceBy: (aGrammar bodyNodeForRule: #'subscript_expression') element elements first elements first.
	
	aGrammar rules at: '_semicolon' put: (SBTSNodeLabel new
		label: ';';
		factory: aGrammar).
	SBToggledCode comment: '' active: 1 do: {
		[aGrammar removeRule: #'_automatic_semicolon'].
		[
			aGrammar rules at: '_automatic_semicolon' put: (SBTSNodeLabel new
				label: '';
				factory: aGrammar)]}.
	aGrammar rules at: '_template_chars' put: (SBTSNodeText new
		regexString: '.*';
		factory: aGrammar)
]

{ #category : #configuration }
SBJavascript class >> rootRuleName [

	^ 'program'
]

{ #category : #'configuration - layout' }
SBJavascript class >> softLineBreakMatchBetween: aBlock and: anotherBlock [

	(aBlock isTSLabel and: [aBlock contents = ':']) ifTrue: [^ true].
	(aBlock isTSLabel and: [aBlock contents = '?']) ifTrue: [^ true].
	(aBlock type = 'jsx_opening_element' or: [anotherBlock type = 'jsx_closing_element']) ifTrue: [^ true].
	^ false
]

{ #category : #builder }
SBJavascript class >> sourceForSlider: aBlock [

	| slider |
	slider := self parseExpression: '[0.0, "slider"][0]'.
	slider childSandblocks first childSandblocks first replaceBlock: aBlock.
	^ (slider adaptSlotFor: aBlock slot ifFailed: [self error: 'blocks not compatible']) applyReplacement
]

{ #category : #'configuration - layout' }
SBJavascript class >> statementTerminator [

	^ ';'
]

{ #category : #'as yet unclassified' }
SBJavascript >> addIndent: aBlock [

	^ super addIndent: aBlock
]

{ #category : #'as yet unclassified' }
SBJavascript >> configure [

	self blockInline: #('expression_statement').
	self blockInlineInParent: #('arguments' 'formal_parameters').
	self noteUncapturedText: {'template_string'}
]

{ #category : #semantics }
SBJavascript >> declarationsInScope: aScopeBlock do: aClosure [

	aScopeBlock type = 'function' ifTrue: [
		aScopeBlock childSandblocksDo: [:block | ((block compatibleWithType: 'pattern') or: [block compatibleWithType: 'assignment_pattern']) ifTrue: [block allBlocksDo: [:b | b type = 'identifier' ifTrue: [aClosure value: (SBTSDeclaration block: b label: 'func arg')]]]].
		self declarationsInScope: (aScopeBlock get: 'body') do: aClosure].
	
	(aScopeBlock type = 'statement_block' or: [aScopeBlock type = 'program']) ifTrue: [aScopeBlock childSandblocksDo: [:statement | statement type = 'lexical_declaration' ifTrue: [statement childSandblocksDo: [:declarator | aClosure value: (SBTSDeclaration block: (declarator get: 'name') label: 'lexical decl')]]]]
]

{ #category : #'configuration helpers' }
SBJavascript >> hardLineBreakBetween: aBlock and: anotherBlock [

	(super hardLineBreakBetween: aBlock and: anotherBlock) ifTrue: [^ true].
	anotherBlock type = 'else_clause' ifTrue: [^ true].
	^ #('statement_block' 'class_body') includes: anotherBlock type
]

{ #category : #'configuration helpers' }
SBJavascript >> hardLineBreakMatch: aBlock [

	^ (aBlock submorphAfter ifNotNil: #type) = 'statement_block' or: [(aBlock submorphAfter ifNotNil: #type) = 'class_body']
]

{ #category : #'configuration helpers' }
SBJavascript >> hardLineBreakMatchBetween: aBlock and: anotherBlock [

	(anotherBlock childOrNil ifNotNil: #type) = 'else_clause' ifTrue: [^ true].
	^ #('statement_block' 'class_body') includes: anotherBlock firstVisibleType
]

{ #category : #'as yet unclassified' }
SBJavascript >> highlightFor: aBlock [

	^ nil
]

{ #category : #'as yet unclassified' }
SBJavascript >> inputTransitionBlackList [
	"return a list of types that should not be considered during transitions, e.g. the typical C comma operator that just chains multiple expressions and thus yields mostly noise"

	^ #(#'sequence_expression')
]

{ #category : #semantics }
SBJavascript >> isScope: aBlock [

	^ #('function' 'program' 'statement_block') includes: aBlock type
]

{ #category : #'as yet unclassified' }
SBJavascript >> postConfigure [

	blockInline remove: 'class_body'
]

{ #category : #'as yet unclassified' }
SBJavascript >> preprocessGrammar [

	| rulesWithSemicolon |
	rulesWithSemicolon := ((self grammar rules associations collect: [:pair |
		self
			traverse: pair value
			detect: [:obj | obj type = 'SYMBOL' and: [obj name = '_semicolon']]
			ifFound: [:obj | pair key -> ';']
			ifNone: [nil]]) select: #notNil) as: Dictionary.
	self addDelimitedRules: rulesWithSemicolon.
	self removeSymbol: '_automatic_semicolon'.
	
	self grammar rules
		at: '_template_chars'
		put: (JsonObject fromAssociations: {'type' -> 'PATTERN'. 'value' -> '.*'}).
	self grammar externals: (self grammar externals copyWithout: (self grammar externals detect: [:e | e name = '_template_chars'])).
	self grammar at: 'inline' put: self grammar inline, {'_ternary_qmark'}.
	SBToggledCode comment: '' active: 0 do: {
		[self grammar rules statement members: (self grammar rules statement members reject: [:m | m name = 'labeled_statement'])]}.
	
	"for some reason the member_expression accepts both primary_expr and expr as options, which lets our parser think that matches are ambiguous"
	(self grammar rules at: 'member_expression') content members first content: (JsonObject fromAssociations: {'type' -> 'SYMBOL'. 'name' -> 'expression'}).
	(self grammar rules at: 'subscript_expression') content members first content: (JsonObject fromAssociations: {'type' -> 'SYMBOL'. 'name' -> 'expression'})
]

{ #category : #'as yet unclassified' }
SBJavascript >> removeIndent: aBlock [

	^ super removeIndent: aBlock
]

{ #category : #testing }
SBJavascript >> shouldSkipParsing: aTypeString in: aParentTypeString cursor: aCursor [

	^ (super shouldSkipParsing: aTypeString in: aParentTypeString cursor: aCursor) or: [aTypeString = 'jsx_text' and: [aCursor text allSatisfy: [:c | c isSeparator]]]
]

{ #category : #'configuration helpers' }
SBJavascript >> softLineBreakMatchBetween: aBlock and: anotherBlock [

	(aBlock isTSLabel and: [aBlock contents = ':']) ifTrue: [^ true].
	(aBlock isTSLabel and: [aBlock contents = '?']) ifTrue: [^ true].
	(aBlock type = 'jsx_opening_element' or: [anotherBlock type = 'jsx_closing_element']) ifTrue: [^ true].
	^ false
]

{ #category : #'as yet unclassified' }
SBJavascript >> sourceForSlider: aBlock [

	| slider |
	slider := self parseExpression: '[0.0, "slider"][0]'.
	slider childSandblocks first childSandblocks first replaceBlock: aBlock.
	^ (slider adaptSlotFor: aBlock slot ifFailed: [self error: 'blocks not compatible']) applyReplacement
]

{ #category : #'as yet unclassified' }
SBJavascript >> terminatorFor: anElement on: aStream [

	(anElement type = 'statement' and: [anElement firstSubmorph isInlineBlock and: [anElement firstSubmorph firstSubmorph isInlineBlock and: [anElement firstSubmorph firstSubmorph type = 'expression_statement']]]) ifTrue: [aStream nextPut: $;]
]
