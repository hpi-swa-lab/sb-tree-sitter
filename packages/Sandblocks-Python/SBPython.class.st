Class {
	#name : #SBPython,
	#superclass : #SBGrammarLanguage,
	#instVars : [
		'separatorRule'
	],
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPython class >> defaultRuntimeClass [

	^ SBPyRuntimeOSProcess
]

{ #category : #'as yet unclassified' }
SBPython class >> expressionTypes [

	^ #('expression' 'primary_expression')
]

{ #category : #'as yet unclassified' }
SBPython class >> fileSuffix [

	^ 'py'
]

{ #category : #'as yet unclassified' }
SBPython class >> grammarJson [
	" https://github.com/tree-sitter/tree-sitter-python/blob/master/src/grammar.json "

	^ '{
  "name": "python",
  "word": "identifier",
  "rules": {
    "module": {
      "type": "REPEAT",
      "content": {
        "type": "SYMBOL",
        "name": "_statement"
      }
    },
    "_statement": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "_simple_statements"
        },
        {
          "type": "SYMBOL",
          "name": "_compound_statement"
        }
      ]
    },
    "_simple_statements": {
      "type": "SEQ",
      "members": [
        {
          "type": "SYMBOL",
          "name": "_simple_statement"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "REPEAT",
              "content": {
                "type": "SEQ",
                "members": [
                  {
                    "type": "SYMBOL",
                    "name": "_semicolon"
                  },
                  {
                    "type": "SYMBOL",
                    "name": "_simple_statement"
                  }
                ]
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
              "type": "SYMBOL",
              "name": "_semicolon"
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "SYMBOL",
          "name": "_newline"
        }
      ]
    },
    "_simple_statement": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "future_import_statement"
        },
        {
          "type": "SYMBOL",
          "name": "import_statement"
        },
        {
          "type": "SYMBOL",
          "name": "import_from_statement"
        },
        {
          "type": "SYMBOL",
          "name": "print_statement"
        },
        {
          "type": "SYMBOL",
          "name": "assert_statement"
        },
        {
          "type": "SYMBOL",
          "name": "expression_statement"
        },
        {
          "type": "SYMBOL",
          "name": "return_statement"
        },
        {
          "type": "SYMBOL",
          "name": "delete_statement"
        },
        {
          "type": "SYMBOL",
          "name": "raise_statement"
        },
        {
          "type": "SYMBOL",
          "name": "pass_statement"
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
          "name": "global_statement"
        },
        {
          "type": "SYMBOL",
          "name": "nonlocal_statement"
        },
        {
          "type": "SYMBOL",
          "name": "exec_statement"
        }
      ]
    },
    "import_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "import"
        },
        {
          "type": "SYMBOL",
          "name": "_import_list"
        }
      ]
    },
    "import_prefix": {
      "type": "REPEAT1",
      "content": {
        "type": "STRING",
        "value": "."
      }
    },
    "relative_import": {
      "type": "SEQ",
      "members": [
        {
          "type": "SYMBOL",
          "name": "import_prefix"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "dotted_name"
            },
            {
              "type": "BLANK"
            }
          ]
        }
      ]
    },
    "future_import_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "from"
        },
        {
          "type": "STRING",
          "value": "__future__"
        },
        {
          "type": "STRING",
          "value": "import"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "_import_list"
            },
            {
              "type": "SEQ",
              "members": [
                {
                  "type": "STRING",
                  "value": "("
                },
                {
                  "type": "SYMBOL",
                  "name": "_import_list"
                },
                {
                  "type": "STRING",
                  "value": ")"
                }
              ]
            }
          ]
        }
      ]
    },
    "import_from_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "from"
        },
        {
          "type": "FIELD",
          "name": "module_name",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "relative_import"
              },
              {
                "type": "SYMBOL",
                "name": "dotted_name"
              }
            ]
          }
        },
        {
          "type": "STRING",
          "value": "import"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "wildcard_import"
            },
            {
              "type": "SYMBOL",
              "name": "_import_list"
            },
            {
              "type": "SEQ",
              "members": [
                {
                  "type": "STRING",
                  "value": "("
                },
                {
                  "type": "SYMBOL",
                  "name": "_import_list"
                },
                {
                  "type": "STRING",
                  "value": ")"
                }
              ]
            }
          ]
        }
      ]
    },
    "_import_list": {
      "type": "SEQ",
      "members": [
        {
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
                    "name": "dotted_name"
                  },
                  {
                    "type": "SYMBOL",
                    "name": "aliased_import"
                  }
                ]
              }
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
                    "type": "FIELD",
                    "name": "name",
                    "content": {
                      "type": "CHOICE",
                      "members": [
                        {
                          "type": "SYMBOL",
                          "name": "dotted_name"
                        },
                        {
                          "type": "SYMBOL",
                          "name": "aliased_import"
                        }
                      ]
                    }
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
    "aliased_import": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "name",
          "content": {
            "type": "SYMBOL",
            "name": "dotted_name"
          }
        },
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
    "wildcard_import": {
      "type": "STRING",
      "value": "*"
    },
    "print_statement": {
      "type": "CHOICE",
      "members": [
        {
          "type": "PREC",
          "value": 1,
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "STRING",
                "value": "print"
              },
              {
                "type": "SYMBOL",
                "name": "chevron"
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
          }
        },
        {
          "type": "PREC",
          "value": -10,
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "STRING",
                "value": "print"
              },
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
                    "type": "REPEAT",
                    "content": {
                      "type": "SEQ",
                      "members": [
                        {
                          "type": "STRING",
                          "value": ","
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
          }
        }
      ]
    },
    "chevron": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": ">>"
        },
        {
          "type": "SYMBOL",
          "name": "expression"
        }
      ]
    },
    "assert_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "assert"
        },
        {
          "type": "SEQ",
          "members": [
            {
              "type": "SYMBOL",
              "name": "expression"
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
                    "name": "expression"
                  }
                ]
              }
            }
          ]
        }
      ]
    },
    "expression_statement": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "expression"
        },
        {
          "type": "SEQ",
          "members": [
            {
              "type": "SEQ",
              "members": [
                {
                  "type": "SYMBOL",
                  "name": "expression"
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
                        "name": "expression"
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
          "type": "SYMBOL",
          "name": "assignment"
        },
        {
          "type": "SYMBOL",
          "name": "augmented_assignment"
        },
        {
          "type": "SYMBOL",
          "name": "yield"
        }
      ]
    },
    "named_expression": {
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
          "type": "STRING",
          "value": ":="
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
        }
      ]
    },
    "delete_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "del"
        },
        {
          "type": "SYMBOL",
          "name": "_expressions"
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
          "name": "expression_list"
        }
      ]
    },
    "raise_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "raise"
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
          "type": "CHOICE",
          "members": [
            {
              "type": "SEQ",
              "members": [
                {
                  "type": "STRING",
                  "value": "from"
                },
                {
                  "type": "FIELD",
                  "name": "cause",
                  "content": {
                    "type": "SYMBOL",
                    "name": "expression"
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
    "pass_statement": {
      "type": "PREC_LEFT",
      "value": 0,
      "content": {
        "type": "STRING",
        "value": "pass"
      }
    },
    "break_statement": {
      "type": "PREC_LEFT",
      "value": 0,
      "content": {
        "type": "STRING",
        "value": "break"
      }
    },
    "continue_statement": {
      "type": "PREC_LEFT",
      "value": 0,
      "content": {
        "type": "STRING",
        "value": "continue"
      }
    },
    "_compound_statement": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "if_statement"
        },
        {
          "type": "SYMBOL",
          "name": "for_statement"
        },
        {
          "type": "SYMBOL",
          "name": "while_statement"
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
          "name": "function_definition"
        },
        {
          "type": "SYMBOL",
          "name": "class_definition"
        },
        {
          "type": "SYMBOL",
          "name": "decorated_definition"
        }
      ]
    },
    "if_statement": {
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
            "name": "expression"
          }
        },
        {
          "type": "STRING",
          "value": ":"
        },
        {
          "type": "FIELD",
          "name": "consequence",
          "content": {
            "type": "SYMBOL",
            "name": "_suite"
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "FIELD",
            "name": "alternative",
            "content": {
              "type": "SYMBOL",
              "name": "elif_clause"
            }
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
    },
    "elif_clause": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "elif"
        },
        {
          "type": "FIELD",
          "name": "condition",
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
          "name": "consequence",
          "content": {
            "type": "SYMBOL",
            "name": "_suite"
          }
        }
      ]
    },
    "else_clause": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "else"
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
            "name": "_suite"
          }
        }
      ]
    },
    "for_statement": {
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
          "value": "for"
        },
        {
          "type": "FIELD",
          "name": "left",
          "content": {
            "type": "SYMBOL",
            "name": "_left_hand_side"
          }
        },
        {
          "type": "STRING",
          "value": "in"
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
          "value": ":"
        },
        {
          "type": "FIELD",
          "name": "body",
          "content": {
            "type": "SYMBOL",
            "name": "_suite"
          }
        },
        {
          "type": "FIELD",
          "name": "alternative",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "else_clause"
              },
              {
                "type": "BLANK"
              }
            ]
          }
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
            "name": "expression"
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
            "name": "_suite"
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
    },
    "try_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "try"
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
            "name": "_suite"
          }
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SEQ",
              "members": [
                {
                  "type": "REPEAT1",
                  "content": {
                    "type": "SYMBOL",
                    "name": "except_clause"
                  }
                },
                {
                  "type": "CHOICE",
                  "members": [
                    {
                      "type": "SYMBOL",
                      "name": "else_clause"
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
                      "type": "SYMBOL",
                      "name": "finally_clause"
                    },
                    {
                      "type": "BLANK"
                    }
                  ]
                }
              ]
            },
            {
              "type": "SYMBOL",
              "name": "finally_clause"
            }
          ]
        }
      ]
    },
    "except_clause": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "except"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SEQ",
              "members": [
                {
                  "type": "SYMBOL",
                  "name": "expression"
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
                              "value": "as"
                            },
                            {
                              "type": "STRING",
                              "value": ","
                            }
                          ]
                        },
                        {
                          "type": "SYMBOL",
                          "name": "expression"
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
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "STRING",
          "value": ":"
        },
        {
          "type": "SYMBOL",
          "name": "_suite"
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
          "type": "STRING",
          "value": ":"
        },
        {
          "type": "SYMBOL",
          "name": "_suite"
        }
      ]
    },
    "with_statement": {
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
          "value": "with"
        },
        {
          "type": "SYMBOL",
          "name": "with_clause"
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
            "name": "_suite"
          }
        }
      ]
    },
    "with_clause": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SEQ",
          "members": [
            {
              "type": "SYMBOL",
              "name": "with_item"
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
                    "name": "with_item"
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
              "type": "STRING",
              "value": "("
            },
            {
              "type": "SEQ",
              "members": [
                {
                  "type": "SYMBOL",
                  "name": "with_item"
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
                        "name": "with_item"
                      }
                    ]
                  }
                }
              ]
            },
            {
              "type": "STRING",
              "value": ")"
            }
          ]
        }
      ]
    },
    "with_item": {
      "type": "PREC_DYNAMIC",
      "value": -1,
      "content": {
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
                      "name": "pattern"
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
      }
    },
    "function_definition": {
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
          "value": "def"
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
          "type": "FIELD",
          "name": "parameters",
          "content": {
            "type": "SYMBOL",
            "name": "parameters"
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
                  "value": "->"
                },
                {
                  "type": "FIELD",
                  "name": "return_type",
                  "content": {
                    "type": "SYMBOL",
                    "name": "type"
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
          "value": ":"
        },
        {
          "type": "FIELD",
          "name": "body",
          "content": {
            "type": "SYMBOL",
            "name": "_suite"
          }
        }
      ]
    },
    "parameters": {
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
              "type": "SYMBOL",
              "name": "_parameters"
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
    "lambda_parameters": {
      "type": "SYMBOL",
      "name": "_parameters"
    },
    "list_splat": {
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
    "dictionary_splat": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "**"
        },
        {
          "type": "SYMBOL",
          "name": "expression"
        }
      ]
    },
    "global_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "global"
        },
        {
          "type": "SEQ",
          "members": [
            {
              "type": "SYMBOL",
              "name": "identifier"
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
                    "name": "identifier"
                  }
                ]
              }
            }
          ]
        }
      ]
    },
    "nonlocal_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "nonlocal"
        },
        {
          "type": "SEQ",
          "members": [
            {
              "type": "SYMBOL",
              "name": "identifier"
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
                    "name": "identifier"
                  }
                ]
              }
            }
          ]
        }
      ]
    },
    "exec_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "exec"
        },
        {
          "type": "FIELD",
          "name": "code",
          "content": {
            "type": "SYMBOL",
            "name": "string"
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
                  "value": "in"
                },
                {
                  "type": "SEQ",
                  "members": [
                    {
                      "type": "SYMBOL",
                      "name": "expression"
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
                            "name": "expression"
                          }
                        ]
                      }
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
    "class_definition": {
      "type": "SEQ",
      "members": [
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
          "type": "FIELD",
          "name": "superclasses",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "argument_list"
              },
              {
                "type": "BLANK"
              }
            ]
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
            "name": "_suite"
          }
        }
      ]
    },
    "parenthesized_list_splat": {
      "type": "PREC",
      "value": 1,
      "content": {
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
                "type": "ALIAS",
                "content": {
                  "type": "SYMBOL",
                  "name": "parenthesized_list_splat"
                },
                "named": true,
                "value": "parenthesized_expression"
              },
              {
                "type": "SYMBOL",
                "name": "list_splat"
              }
            ]
          },
          {
            "type": "STRING",
            "value": ")"
          }
        ]
      }
    },
    "argument_list": {
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
                      "type": "SYMBOL",
                      "name": "expression"
                    },
                    {
                      "type": "SYMBOL",
                      "name": "list_splat"
                    },
                    {
                      "type": "SYMBOL",
                      "name": "dictionary_splat"
                    },
                    {
                      "type": "ALIAS",
                      "content": {
                        "type": "SYMBOL",
                        "name": "parenthesized_list_splat"
                      },
                      "named": true,
                      "value": "parenthesized_expression"
                    },
                    {
                      "type": "SYMBOL",
                      "name": "keyword_argument"
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
                            "type": "SYMBOL",
                            "name": "expression"
                          },
                          {
                            "type": "SYMBOL",
                            "name": "list_splat"
                          },
                          {
                            "type": "SYMBOL",
                            "name": "dictionary_splat"
                          },
                          {
                            "type": "ALIAS",
                            "content": {
                              "type": "SYMBOL",
                              "name": "parenthesized_list_splat"
                            },
                            "named": true,
                            "value": "parenthesized_expression"
                          },
                          {
                            "type": "SYMBOL",
                            "name": "keyword_argument"
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
          "value": ")"
        }
      ]
    },
    "decorated_definition": {
      "type": "SEQ",
      "members": [
        {
          "type": "REPEAT1",
          "content": {
            "type": "SYMBOL",
            "name": "decorator"
          }
        },
        {
          "type": "FIELD",
          "name": "definition",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "class_definition"
              },
              {
                "type": "SYMBOL",
                "name": "function_definition"
              }
            ]
          }
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
          "type": "SYMBOL",
          "name": "primary_expression"
        },
        {
          "type": "SYMBOL",
          "name": "_newline"
        }
      ]
    },
    "_suite": {
      "type": "CHOICE",
      "members": [
        {
          "type": "ALIAS",
          "content": {
            "type": "SYMBOL",
            "name": "_simple_statements"
          },
          "named": true,
          "value": "block"
        },
        {
          "type": "SEQ",
          "members": [
            {
              "type": "SYMBOL",
              "name": "_indent"
            },
            {
              "type": "SYMBOL",
              "name": "block"
            }
          ]
        },
        {
          "type": "ALIAS",
          "content": {
            "type": "SYMBOL",
            "name": "_newline"
          },
          "named": true,
          "value": "block"
        }
      ]
    },
    "block": {
      "type": "SEQ",
      "members": [
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_statement"
          }
        },
        {
          "type": "SYMBOL",
          "name": "_dedent"
        }
      ]
    },
    "expression_list": {
      "type": "PREC_RIGHT",
      "value": 0,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "SYMBOL",
            "name": "expression"
          },
          {
            "type": "CHOICE",
            "members": [
              {
                "type": "STRING",
                "value": ","
              },
              {
                "type": "SEQ",
                "members": [
                  {
                    "type": "REPEAT1",
                    "content": {
                      "type": "SEQ",
                      "members": [
                        {
                          "type": "STRING",
                          "value": ","
                        },
                        {
                          "type": "SYMBOL",
                          "name": "expression"
                        }
                      ]
                    }
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
              }
            ]
          }
        ]
      }
    },
    "dotted_name": {
      "type": "SEQ",
      "members": [
        {
          "type": "SYMBOL",
          "name": "identifier"
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SEQ",
            "members": [
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
        }
      ]
    },
    "_parameters": {
      "type": "SEQ",
      "members": [
        {
          "type": "SEQ",
          "members": [
            {
              "type": "SYMBOL",
              "name": "parameter"
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
                    "name": "parameter"
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
    "_patterns": {
      "type": "SEQ",
      "members": [
        {
          "type": "SEQ",
          "members": [
            {
              "type": "SYMBOL",
              "name": "pattern"
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
                    "name": "pattern"
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
    "parameter": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "identifier"
        },
        {
          "type": "SYMBOL",
          "name": "typed_parameter"
        },
        {
          "type": "SYMBOL",
          "name": "default_parameter"
        },
        {
          "type": "SYMBOL",
          "name": "typed_default_parameter"
        },
        {
          "type": "SYMBOL",
          "name": "list_splat_pattern"
        },
        {
          "type": "SYMBOL",
          "name": "tuple_pattern"
        },
        {
          "type": "ALIAS",
          "content": {
            "type": "STRING",
            "value": "*"
          },
          "named": true,
          "value": "list_splat_pattern"
        },
        {
          "type": "SYMBOL",
          "name": "dictionary_splat_pattern"
        }
      ]
    },
    "pattern": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "identifier"
        },
        {
          "type": "SYMBOL",
          "name": "keyword_identifier"
        },
        {
          "type": "SYMBOL",
          "name": "subscript"
        },
        {
          "type": "SYMBOL",
          "name": "attribute"
        },
        {
          "type": "SYMBOL",
          "name": "list_splat_pattern"
        },
        {
          "type": "SYMBOL",
          "name": "tuple_pattern"
        },
        {
          "type": "SYMBOL",
          "name": "list_pattern"
        }
      ]
    },
    "tuple_pattern": {
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
              "type": "SYMBOL",
              "name": "_patterns"
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
    "list_pattern": {
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
              "type": "SYMBOL",
              "name": "_patterns"
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
    "default_parameter": {
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
    "typed_default_parameter": {
      "type": "PREC",
      "value": -1,
      "content": {
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
            "type": "STRING",
            "value": ":"
          },
          {
            "type": "FIELD",
            "name": "type",
            "content": {
              "type": "SYMBOL",
              "name": "type"
            }
          },
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
      }
    },
    "list_splat_pattern": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "*"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "identifier"
            },
            {
              "type": "SYMBOL",
              "name": "keyword_identifier"
            },
            {
              "type": "SYMBOL",
              "name": "subscript"
            },
            {
              "type": "SYMBOL",
              "name": "attribute"
            }
          ]
        }
      ]
    },
    "dictionary_splat_pattern": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "**"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "identifier"
            },
            {
              "type": "SYMBOL",
              "name": "keyword_identifier"
            },
            {
              "type": "SYMBOL",
              "name": "subscript"
            },
            {
              "type": "SYMBOL",
              "name": "attribute"
            }
          ]
        }
      ]
    },
    "_expression_within_for_in_clause": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "expression"
        },
        {
          "type": "ALIAS",
          "content": {
            "type": "SYMBOL",
            "name": "lambda_within_for_in_clause"
          },
          "named": true,
          "value": "lambda"
        }
      ]
    },
    "expression": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "comparison_operator"
        },
        {
          "type": "SYMBOL",
          "name": "not_operator"
        },
        {
          "type": "SYMBOL",
          "name": "boolean_operator"
        },
        {
          "type": "SYMBOL",
          "name": "await"
        },
        {
          "type": "SYMBOL",
          "name": "lambda"
        },
        {
          "type": "SYMBOL",
          "name": "primary_expression"
        },
        {
          "type": "SYMBOL",
          "name": "conditional_expression"
        },
        {
          "type": "SYMBOL",
          "name": "named_expression"
        }
      ]
    },
    "primary_expression": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "binary_operator"
        },
        {
          "type": "SYMBOL",
          "name": "identifier"
        },
        {
          "type": "SYMBOL",
          "name": "keyword_identifier"
        },
        {
          "type": "SYMBOL",
          "name": "string"
        },
        {
          "type": "SYMBOL",
          "name": "concatenated_string"
        },
        {
          "type": "SYMBOL",
          "name": "integer"
        },
        {
          "type": "SYMBOL",
          "name": "float"
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
          "name": "none"
        },
        {
          "type": "SYMBOL",
          "name": "unary_operator"
        },
        {
          "type": "SYMBOL",
          "name": "attribute"
        },
        {
          "type": "SYMBOL",
          "name": "subscript"
        },
        {
          "type": "SYMBOL",
          "name": "call"
        },
        {
          "type": "SYMBOL",
          "name": "list"
        },
        {
          "type": "SYMBOL",
          "name": "list_comprehension"
        },
        {
          "type": "SYMBOL",
          "name": "dictionary"
        },
        {
          "type": "SYMBOL",
          "name": "dictionary_comprehension"
        },
        {
          "type": "SYMBOL",
          "name": "set"
        },
        {
          "type": "SYMBOL",
          "name": "set_comprehension"
        },
        {
          "type": "SYMBOL",
          "name": "tuple"
        },
        {
          "type": "SYMBOL",
          "name": "parenthesized_expression"
        },
        {
          "type": "SYMBOL",
          "name": "generator_expression"
        },
        {
          "type": "SYMBOL",
          "name": "ellipsis"
        }
      ]
    },
    "not_operator": {
      "type": "PREC",
      "value": 1,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "STRING",
            "value": "not"
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
    "boolean_operator": {
      "type": "CHOICE",
      "members": [
        {
          "type": "PREC_LEFT",
          "value": 11,
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
                  "value": "and"
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
          "value": 10,
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
                  "value": "or"
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
    "binary_operator": {
      "type": "CHOICE",
      "members": [
        {
          "type": "PREC_LEFT",
          "value": 16,
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "FIELD",
                "name": "left",
                "content": {
                  "type": "SYMBOL",
                  "name": "primary_expression"
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
                  "name": "primary_expression"
                }
              }
            ]
          }
        },
        {
          "type": "PREC_LEFT",
          "value": 16,
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "FIELD",
                "name": "left",
                "content": {
                  "type": "SYMBOL",
                  "name": "primary_expression"
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
                  "name": "primary_expression"
                }
              }
            ]
          }
        },
        {
          "type": "PREC_LEFT",
          "value": 17,
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "FIELD",
                "name": "left",
                "content": {
                  "type": "SYMBOL",
                  "name": "primary_expression"
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
                  "name": "primary_expression"
                }
              }
            ]
          }
        },
        {
          "type": "PREC_LEFT",
          "value": 17,
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "FIELD",
                "name": "left",
                "content": {
                  "type": "SYMBOL",
                  "name": "primary_expression"
                }
              },
              {
                "type": "FIELD",
                "name": "operator",
                "content": {
                  "type": "STRING",
                  "value": "@"
                }
              },
              {
                "type": "FIELD",
                "name": "right",
                "content": {
                  "type": "SYMBOL",
                  "name": "primary_expression"
                }
              }
            ]
          }
        },
        {
          "type": "PREC_LEFT",
          "value": 17,
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "FIELD",
                "name": "left",
                "content": {
                  "type": "SYMBOL",
                  "name": "primary_expression"
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
                  "name": "primary_expression"
                }
              }
            ]
          }
        },
        {
          "type": "PREC_LEFT",
          "value": 17,
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "FIELD",
                "name": "left",
                "content": {
                  "type": "SYMBOL",
                  "name": "primary_expression"
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
                  "name": "primary_expression"
                }
              }
            ]
          }
        },
        {
          "type": "PREC_LEFT",
          "value": 17,
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "FIELD",
                "name": "left",
                "content": {
                  "type": "SYMBOL",
                  "name": "primary_expression"
                }
              },
              {
                "type": "FIELD",
                "name": "operator",
                "content": {
                  "type": "STRING",
                  "value": "//"
                }
              },
              {
                "type": "FIELD",
                "name": "right",
                "content": {
                  "type": "SYMBOL",
                  "name": "primary_expression"
                }
              }
            ]
          }
        },
        {
          "type": "PREC_RIGHT",
          "value": 19,
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "FIELD",
                "name": "left",
                "content": {
                  "type": "SYMBOL",
                  "name": "primary_expression"
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
                  "name": "primary_expression"
                }
              }
            ]
          }
        },
        {
          "type": "PREC_LEFT",
          "value": 12,
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "FIELD",
                "name": "left",
                "content": {
                  "type": "SYMBOL",
                  "name": "primary_expression"
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
                  "name": "primary_expression"
                }
              }
            ]
          }
        },
        {
          "type": "PREC_LEFT",
          "value": 13,
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "FIELD",
                "name": "left",
                "content": {
                  "type": "SYMBOL",
                  "name": "primary_expression"
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
                  "name": "primary_expression"
                }
              }
            ]
          }
        },
        {
          "type": "PREC_LEFT",
          "value": 14,
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "FIELD",
                "name": "left",
                "content": {
                  "type": "SYMBOL",
                  "name": "primary_expression"
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
                  "name": "primary_expression"
                }
              }
            ]
          }
        },
        {
          "type": "PREC_LEFT",
          "value": 15,
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "FIELD",
                "name": "left",
                "content": {
                  "type": "SYMBOL",
                  "name": "primary_expression"
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
                  "name": "primary_expression"
                }
              }
            ]
          }
        },
        {
          "type": "PREC_LEFT",
          "value": 15,
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "FIELD",
                "name": "left",
                "content": {
                  "type": "SYMBOL",
                  "name": "primary_expression"
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
                  "name": "primary_expression"
                }
              }
            ]
          }
        }
      ]
    },
    "unary_operator": {
      "type": "PREC",
      "value": 18,
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
                  "value": "+"
                },
                {
                  "type": "STRING",
                  "value": "-"
                },
                {
                  "type": "STRING",
                  "value": "~"
                }
              ]
            }
          },
          {
            "type": "FIELD",
            "name": "argument",
            "content": {
              "type": "SYMBOL",
              "name": "primary_expression"
            }
          }
        ]
      }
    },
    "comparison_operator": {
      "type": "PREC_LEFT",
      "value": 2,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "SYMBOL",
            "name": "primary_expression"
          },
          {
            "type": "REPEAT1",
            "content": {
              "type": "SEQ",
              "members": [
                {
                  "type": "FIELD",
                  "name": "operators",
                  "content": {
                    "type": "CHOICE",
                    "members": [
                      {
                        "type": "STRING",
                        "value": "<"
                      },
                      {
                        "type": "STRING",
                        "value": "<="
                      },
                      {
                        "type": "STRING",
                        "value": "=="
                      },
                      {
                        "type": "STRING",
                        "value": "!="
                      },
                      {
                        "type": "STRING",
                        "value": ">="
                      },
                      {
                        "type": "STRING",
                        "value": ">"
                      },
                      {
                        "type": "STRING",
                        "value": "<>"
                      },
                      {
                        "type": "STRING",
                        "value": "in"
                      },
                      {
                        "type": "SEQ",
                        "members": [
                          {
                            "type": "STRING",
                            "value": "not"
                          },
                          {
                            "type": "STRING",
                            "value": "in"
                          }
                        ]
                      },
                      {
                        "type": "STRING",
                        "value": "is"
                      },
                      {
                        "type": "SEQ",
                        "members": [
                          {
                            "type": "STRING",
                            "value": "is"
                          },
                          {
                            "type": "STRING",
                            "value": "not"
                          }
                        ]
                      }
                    ]
                  }
                },
                {
                  "type": "SYMBOL",
                  "name": "primary_expression"
                }
              ]
            }
          }
        ]
      }
    },
    "lambda": {
      "type": "PREC",
      "value": -2,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "STRING",
            "value": "lambda"
          },
          {
            "type": "FIELD",
            "name": "parameters",
            "content": {
              "type": "CHOICE",
              "members": [
                {
                  "type": "SYMBOL",
                  "name": "lambda_parameters"
                },
                {
                  "type": "BLANK"
                }
              ]
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
              "name": "expression"
            }
          }
        ]
      }
    },
    "lambda_within_for_in_clause": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "lambda"
        },
        {
          "type": "FIELD",
          "name": "parameters",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "lambda_parameters"
              },
              {
                "type": "BLANK"
              }
            ]
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
            "name": "_expression_within_for_in_clause"
          }
        }
      ]
    },
    "assignment": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "left",
          "content": {
            "type": "SYMBOL",
            "name": "_left_hand_side"
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
                  "value": "="
                },
                {
                  "type": "FIELD",
                  "name": "right",
                  "content": {
                    "type": "SYMBOL",
                    "name": "_right_hand_side"
                  }
                }
              ]
            },
            {
              "type": "SEQ",
              "members": [
                {
                  "type": "STRING",
                  "value": ":"
                },
                {
                  "type": "FIELD",
                  "name": "type",
                  "content": {
                    "type": "SYMBOL",
                    "name": "type"
                  }
                }
              ]
            },
            {
              "type": "SEQ",
              "members": [
                {
                  "type": "STRING",
                  "value": ":"
                },
                {
                  "type": "FIELD",
                  "name": "type",
                  "content": {
                    "type": "SYMBOL",
                    "name": "type"
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
                    "name": "_right_hand_side"
                  }
                }
              ]
            }
          ]
        }
      ]
    },
    "augmented_assignment": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "left",
          "content": {
            "type": "SYMBOL",
            "name": "_left_hand_side"
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
                "value": "@="
              },
              {
                "type": "STRING",
                "value": "//="
              },
              {
                "type": "STRING",
                "value": "%="
              },
              {
                "type": "STRING",
                "value": "**="
              },
              {
                "type": "STRING",
                "value": ">>="
              },
              {
                "type": "STRING",
                "value": "<<="
              },
              {
                "type": "STRING",
                "value": "&="
              },
              {
                "type": "STRING",
                "value": "^="
              },
              {
                "type": "STRING",
                "value": "|="
              }
            ]
          }
        },
        {
          "type": "FIELD",
          "name": "right",
          "content": {
            "type": "SYMBOL",
            "name": "_right_hand_side"
          }
        }
      ]
    },
    "_left_hand_side": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "pattern"
        },
        {
          "type": "SYMBOL",
          "name": "pattern_list"
        }
      ]
    },
    "pattern_list": {
      "type": "SEQ",
      "members": [
        {
          "type": "SYMBOL",
          "name": "pattern"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "STRING",
              "value": ","
            },
            {
              "type": "SEQ",
              "members": [
                {
                  "type": "REPEAT1",
                  "content": {
                    "type": "SEQ",
                    "members": [
                      {
                        "type": "STRING",
                        "value": ","
                      },
                      {
                        "type": "SYMBOL",
                        "name": "pattern"
                      }
                    ]
                  }
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
            }
          ]
        }
      ]
    },
    "_right_hand_side": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "expression"
        },
        {
          "type": "SYMBOL",
          "name": "expression_list"
        },
        {
          "type": "SYMBOL",
          "name": "assignment"
        },
        {
          "type": "SYMBOL",
          "name": "augmented_assignment"
        },
        {
          "type": "SYMBOL",
          "name": "yield"
        }
      ]
    },
    "yield": {
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
                    "value": "from"
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
                    "name": "_expressions"
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
    "attribute": {
      "type": "PREC",
      "value": 20,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "FIELD",
            "name": "object",
            "content": {
              "type": "SYMBOL",
              "name": "primary_expression"
            }
          },
          {
            "type": "STRING",
            "value": "."
          },
          {
            "type": "FIELD",
            "name": "attribute",
            "content": {
              "type": "SYMBOL",
              "name": "identifier"
            }
          }
        ]
      }
    },
    "subscript": {
      "type": "PREC",
      "value": 20,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "FIELD",
            "name": "value",
            "content": {
              "type": "SYMBOL",
              "name": "primary_expression"
            }
          },
          {
            "type": "STRING",
            "value": "["
          },
          {
            "type": "SEQ",
            "members": [
              {
                "type": "FIELD",
                "name": "subscript",
                "content": {
                  "type": "CHOICE",
                  "members": [
                    {
                      "type": "SYMBOL",
                      "name": "expression"
                    },
                    {
                      "type": "SYMBOL",
                      "name": "slice"
                    }
                  ]
                }
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
                      "type": "FIELD",
                      "name": "subscript",
                      "content": {
                        "type": "CHOICE",
                        "members": [
                          {
                            "type": "SYMBOL",
                            "name": "expression"
                          },
                          {
                            "type": "SYMBOL",
                            "name": "slice"
                          }
                        ]
                      }
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
          },
          {
            "type": "STRING",
            "value": "]"
          }
        ]
      }
    },
    "slice": {
      "type": "SEQ",
      "members": [
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
        },
        {
          "type": "STRING",
          "value": ":"
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
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SEQ",
              "members": [
                {
                  "type": "STRING",
                  "value": ":"
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
            },
            {
              "type": "BLANK"
            }
          ]
        }
      ]
    },
    "ellipsis": {
      "type": "STRING",
      "value": "..."
    },
    "call": {
      "type": "PREC",
      "value": 20,
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
            "type": "FIELD",
            "name": "arguments",
            "content": {
              "type": "CHOICE",
              "members": [
                {
                  "type": "SYMBOL",
                  "name": "generator_expression"
                },
                {
                  "type": "SYMBOL",
                  "name": "argument_list"
                }
              ]
            }
          }
        ]
      }
    },
    "typed_parameter": {
      "type": "PREC",
      "value": -1,
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
                "name": "list_splat_pattern"
              },
              {
                "type": "SYMBOL",
                "name": "dictionary_splat_pattern"
              }
            ]
          },
          {
            "type": "STRING",
            "value": ":"
          },
          {
            "type": "FIELD",
            "name": "type",
            "content": {
              "type": "SYMBOL",
              "name": "type"
            }
          }
        ]
      }
    },
    "type": {
      "type": "SYMBOL",
      "name": "expression"
    },
    "keyword_argument": {
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
                "name": "keyword_identifier"
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
          "name": "value",
          "content": {
            "type": "SYMBOL",
            "name": "expression"
          }
        }
      ]
    },
    "list": {
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
              "type": "SYMBOL",
              "name": "_collection_elements"
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
    "set": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "{"
        },
        {
          "type": "SYMBOL",
          "name": "_collection_elements"
        },
        {
          "type": "STRING",
          "value": "}"
        }
      ]
    },
    "tuple": {
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
              "type": "SYMBOL",
              "name": "_collection_elements"
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
    "dictionary": {
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
                      "type": "SYMBOL",
                      "name": "pair"
                    },
                    {
                      "type": "SYMBOL",
                      "name": "dictionary_splat"
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
                            "type": "SYMBOL",
                            "name": "pair"
                          },
                          {
                            "type": "SYMBOL",
                            "name": "dictionary_splat"
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
    "pair": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "key",
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
          "name": "value",
          "content": {
            "type": "SYMBOL",
            "name": "expression"
          }
        }
      ]
    },
    "list_comprehension": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "["
        },
        {
          "type": "FIELD",
          "name": "body",
          "content": {
            "type": "SYMBOL",
            "name": "expression"
          }
        },
        {
          "type": "SYMBOL",
          "name": "_comprehension_clauses"
        },
        {
          "type": "STRING",
          "value": "]"
        }
      ]
    },
    "dictionary_comprehension": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "{"
        },
        {
          "type": "FIELD",
          "name": "body",
          "content": {
            "type": "SYMBOL",
            "name": "pair"
          }
        },
        {
          "type": "SYMBOL",
          "name": "_comprehension_clauses"
        },
        {
          "type": "STRING",
          "value": "}"
        }
      ]
    },
    "set_comprehension": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "{"
        },
        {
          "type": "FIELD",
          "name": "body",
          "content": {
            "type": "SYMBOL",
            "name": "expression"
          }
        },
        {
          "type": "SYMBOL",
          "name": "_comprehension_clauses"
        },
        {
          "type": "STRING",
          "value": "}"
        }
      ]
    },
    "generator_expression": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "("
        },
        {
          "type": "FIELD",
          "name": "body",
          "content": {
            "type": "SYMBOL",
            "name": "expression"
          }
        },
        {
          "type": "SYMBOL",
          "name": "_comprehension_clauses"
        },
        {
          "type": "STRING",
          "value": ")"
        }
      ]
    },
    "_comprehension_clauses": {
      "type": "SEQ",
      "members": [
        {
          "type": "SYMBOL",
          "name": "for_in_clause"
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "for_in_clause"
              },
              {
                "type": "SYMBOL",
                "name": "if_clause"
              }
            ]
          }
        }
      ]
    },
    "parenthesized_expression": {
      "type": "PREC",
      "value": 1,
      "content": {
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
                "type": "SYMBOL",
                "name": "expression"
              },
              {
                "type": "SYMBOL",
                "name": "yield"
              }
            ]
          },
          {
            "type": "STRING",
            "value": ")"
          }
        ]
      }
    },
    "_collection_elements": {
      "type": "SEQ",
      "members": [
        {
          "type": "SEQ",
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
                  "name": "yield"
                },
                {
                  "type": "SYMBOL",
                  "name": "list_splat"
                },
                {
                  "type": "SYMBOL",
                  "name": "parenthesized_list_splat"
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
                        "type": "SYMBOL",
                        "name": "expression"
                      },
                      {
                        "type": "SYMBOL",
                        "name": "yield"
                      },
                      {
                        "type": "SYMBOL",
                        "name": "list_splat"
                      },
                      {
                        "type": "SYMBOL",
                        "name": "parenthesized_list_splat"
                      }
                    ]
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
    "for_in_clause": {
      "type": "PREC_LEFT",
      "value": 0,
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
            "value": "for"
          },
          {
            "type": "FIELD",
            "name": "left",
            "content": {
              "type": "SYMBOL",
              "name": "_left_hand_side"
            }
          },
          {
            "type": "STRING",
            "value": "in"
          },
          {
            "type": "FIELD",
            "name": "right",
            "content": {
              "type": "SEQ",
              "members": [
                {
                  "type": "SYMBOL",
                  "name": "_expression_within_for_in_clause"
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
                        "name": "_expression_within_for_in_clause"
                      }
                    ]
                  }
                }
              ]
            }
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
      }
    },
    "if_clause": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "if"
        },
        {
          "type": "SYMBOL",
          "name": "expression"
        }
      ]
    },
    "conditional_expression": {
      "type": "PREC_RIGHT",
      "value": -1,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "SYMBOL",
            "name": "expression"
          },
          {
            "type": "STRING",
            "value": "if"
          },
          {
            "type": "SYMBOL",
            "name": "expression"
          },
          {
            "type": "STRING",
            "value": "else"
          },
          {
            "type": "SYMBOL",
            "name": "expression"
          }
        ]
      }
    },
    "concatenated_string": {
      "type": "SEQ",
      "members": [
        {
          "type": "SYMBOL",
          "name": "string"
        },
        {
          "type": "REPEAT1",
          "content": {
            "type": "SYMBOL",
            "name": "string"
          }
        }
      ]
    },
    "string": {
      "type": "SEQ",
      "members": [
        {
          "type": "ALIAS",
          "content": {
            "type": "SYMBOL",
            "name": "_string_start"
          },
          "named": false,
          "value": "\""
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "interpolation"
              },
              {
                "type": "SYMBOL",
                "name": "escape_sequence"
              },
              {
                "type": "SYMBOL",
                "name": "_not_escape_sequence"
              },
              {
                "type": "SYMBOL",
                "name": "_string_content"
              }
            ]
          }
        },
        {
          "type": "ALIAS",
          "content": {
            "type": "SYMBOL",
            "name": "_string_end"
          },
          "named": false,
          "value": "\""
        }
      ]
    },
    "interpolation": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "{"
        },
        {
          "type": "SYMBOL",
          "name": "expression"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "type_conversion"
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
              "type": "SYMBOL",
              "name": "format_specifier"
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
    "escape_sequence": {
      "type": "TOKEN",
      "content": {
        "type": "PREC",
        "value": 1,
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
                  "value": "u[a-fA-F\\d]{4}"
                },
                {
                  "type": "PATTERN",
                  "value": "U[a-fA-F\\d]{8}"
                },
                {
                  "type": "PATTERN",
                  "value": "x[a-fA-F\\d]{2}"
                },
                {
                  "type": "PATTERN",
                  "value": "\\d{3}"
                },
                {
                  "type": "PATTERN",
                  "value": "\\r?\\n"
                },
                {
                  "type": "PATTERN",
                  "value": "[''\"abfrntv\\\\]"
                }
              ]
            }
          ]
        }
      }
    },
    "_not_escape_sequence": {
      "type": "STRING",
      "value": "\\"
    },
    "format_specifier": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": ":"
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "TOKEN",
                "content": {
                  "type": "PREC",
                  "value": 1,
                  "content": {
                    "type": "PATTERN",
                    "value": "[^{}\\n]+"
                  }
                }
              },
              {
                "type": "SYMBOL",
                "name": "format_expression"
              }
            ]
          }
        }
      ]
    },
    "format_expression": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "{"
        },
        {
          "type": "SYMBOL",
          "name": "expression"
        },
        {
          "type": "STRING",
          "value": "}"
        }
      ]
    },
    "type_conversion": {
      "type": "PATTERN",
      "value": "![a-z]"
    },
    "integer": {
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
                "type": "REPEAT1",
                "content": {
                  "type": "PATTERN",
                  "value": "_?[A-Fa-f0-9]+"
                }
              },
              {
                "type": "CHOICE",
                "members": [
                  {
                    "type": "PATTERN",
                    "value": "[Ll]"
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
                    "value": "0o"
                  },
                  {
                    "type": "STRING",
                    "value": "0O"
                  }
                ]
              },
              {
                "type": "REPEAT1",
                "content": {
                  "type": "PATTERN",
                  "value": "_?[0-7]+"
                }
              },
              {
                "type": "CHOICE",
                "members": [
                  {
                    "type": "PATTERN",
                    "value": "[Ll]"
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
                    "value": "0b"
                  },
                  {
                    "type": "STRING",
                    "value": "0B"
                  }
                ]
              },
              {
                "type": "REPEAT1",
                "content": {
                  "type": "PATTERN",
                  "value": "_?[0-1]+"
                }
              },
              {
                "type": "CHOICE",
                "members": [
                  {
                    "type": "PATTERN",
                    "value": "[Ll]"
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
                "type": "REPEAT1",
                "content": {
                  "type": "PATTERN",
                  "value": "[0-9]+_?"
                }
              },
              {
                "type": "CHOICE",
                "members": [
                  {
                    "type": "CHOICE",
                    "members": [
                      {
                        "type": "PATTERN",
                        "value": "[Ll]"
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
                        "type": "PATTERN",
                        "value": "[jJ]"
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
        ]
      }
    },
    "float": {
      "type": "TOKEN",
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "CHOICE",
            "members": [
              {
                "type": "SEQ",
                "members": [
                  {
                    "type": "REPEAT1",
                    "content": {
                      "type": "PATTERN",
                      "value": "[0-9]+_?"
                    }
                  },
                  {
                    "type": "STRING",
                    "value": "."
                  },
                  {
                    "type": "CHOICE",
                    "members": [
                      {
                        "type": "REPEAT1",
                        "content": {
                          "type": "PATTERN",
                          "value": "[0-9]+_?"
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
                        "type": "SEQ",
                        "members": [
                          {
                            "type": "PATTERN",
                            "value": "[eE][\\+-]?"
                          },
                          {
                            "type": "REPEAT1",
                            "content": {
                              "type": "PATTERN",
                              "value": "[0-9]+_?"
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
              {
                "type": "SEQ",
                "members": [
                  {
                    "type": "CHOICE",
                    "members": [
                      {
                        "type": "REPEAT1",
                        "content": {
                          "type": "PATTERN",
                          "value": "[0-9]+_?"
                        }
                      },
                      {
                        "type": "BLANK"
                      }
                    ]
                  },
                  {
                    "type": "STRING",
                    "value": "."
                  },
                  {
                    "type": "REPEAT1",
                    "content": {
                      "type": "PATTERN",
                      "value": "[0-9]+_?"
                    }
                  },
                  {
                    "type": "CHOICE",
                    "members": [
                      {
                        "type": "SEQ",
                        "members": [
                          {
                            "type": "PATTERN",
                            "value": "[eE][\\+-]?"
                          },
                          {
                            "type": "REPEAT1",
                            "content": {
                              "type": "PATTERN",
                              "value": "[0-9]+_?"
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
              {
                "type": "SEQ",
                "members": [
                  {
                    "type": "REPEAT1",
                    "content": {
                      "type": "PATTERN",
                      "value": "[0-9]+_?"
                    }
                  },
                  {
                    "type": "SEQ",
                    "members": [
                      {
                        "type": "PATTERN",
                        "value": "[eE][\\+-]?"
                      },
                      {
                        "type": "REPEAT1",
                        "content": {
                          "type": "PATTERN",
                          "value": "[0-9]+_?"
                        }
                      }
                    ]
                  }
                ]
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
                    "type": "PATTERN",
                    "value": "[Ll]"
                  },
                  {
                    "type": "PATTERN",
                    "value": "[jJ]"
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
    },
    "identifier": {
      "type": "PATTERN",
      "value": "[_\\p{XID_Start}][_\\p{XID_Continue}]*"
    },
    "keyword_identifier": {
      "type": "PREC",
      "value": -3,
      "content": {
        "type": "ALIAS",
        "content": {
          "type": "CHOICE",
          "members": [
            {
              "type": "STRING",
              "value": "print"
            },
            {
              "type": "STRING",
              "value": "exec"
            },
            {
              "type": "STRING",
              "value": "async"
            },
            {
              "type": "STRING",
              "value": "await"
            }
          ]
        },
        "named": true,
        "value": "identifier"
      }
    },
    "true": {
      "type": "STRING",
      "value": "True"
    },
    "false": {
      "type": "STRING",
      "value": "False"
    },
    "none": {
      "type": "STRING",
      "value": "None"
    },
    "await": {
      "type": "PREC",
      "value": 18,
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
    "comment": {
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
            "value": ".*"
          }
        ]
      }
    },
    "_semicolon": {
      "type": "STRING",
      "value": ";"
    }
  },
  "extras": [
    {
      "type": "SYMBOL",
      "name": "comment"
    },
    {
      "type": "PATTERN",
      "value": "[\\s\\f\\uFEFF\\u2060\\u200B]|\\\\\\r?\\n"
    }
  ],
  "conflicts": [
    [
      "primary_expression",
      "pattern"
    ],
    [
      "primary_expression",
      "list_splat_pattern"
    ],
    [
      "tuple",
      "tuple_pattern"
    ],
    [
      "list",
      "list_pattern"
    ],
    [
      "with_item",
      "_collection_elements"
    ]
  ],
  "precedences": [],
  "externals": [
    {
      "type": "SYMBOL",
      "name": "_newline"
    },
    {
      "type": "SYMBOL",
      "name": "_indent"
    },
    {
      "type": "SYMBOL",
      "name": "_dedent"
    },
    {
      "type": "SYMBOL",
      "name": "_string_start"
    },
    {
      "type": "SYMBOL",
      "name": "_string_content"
    },
    {
      "type": "SYMBOL",
      "name": "_string_end"
    }
  ],
  "inline": [
    "_simple_statement",
    "_compound_statement",
    "_suite",
    "_expressions",
    "_left_hand_side",
    "keyword_identifier"
  ],
  "supertypes": [
    "_simple_statement",
    "_compound_statement",
    "expression",
    "primary_expression",
    "pattern",
    "parameter"
  ]
}'
]

{ #category : #'as yet unclassified' }
SBPython class >> highlightQuery [
	" https://github.com/tree-sitter/tree-sitter-python/blob/master/queries/highlights.scm "

	^ '; Identifier naming conventions

((identifier) @constructor
 (#match? @constructor "^[A-Z]"))

((identifier) @constant
 (#match? @constant "^[A-Z][A-Z_]*$"))

; Builtin functions

((call
  function: (identifier) @function.builtin)
 (#match?
   @function.builtin
   "^(abs|all|any|ascii|bin|bool|breakpoint|bytearray|bytes|callable|chr|classmethod|compile|complex|delattr|dict|dir|divmod|enumerate|eval|exec|filter|float|format|frozenset|getattr|globals|hasattr|hash|help|hex|id|input|int|isinstance|issubclass|iter|len|list|locals|map|max|memoryview|min|next|object|oct|open|ord|pow|print|property|range|repr|reversed|round|set|setattr|slice|sorted|staticmethod|str|sum|super|tuple|type|vars|zip|__import__)$"))

; Function calls

(decorator) @function

(call
  function: (attribute attribute: (identifier) @function.method))
(call
  function: (identifier) @function)

; Function definitions

(function_definition
  name: (identifier) @function)

(identifier) @variable
(attribute attribute: (identifier) @property)
(type (identifier) @type)

; Literals

[
  (none)
  (true)
  (false)
] @constant.builtin

[
  (integer)
  (float)
] @number

(comment) @comment
(string) @string
(escape_sequence) @escape

(interpolation
  "{" @punctuation.special
  "}" @punctuation.special) @embedded

[
  "-"
  "-="
  "!="
  "*"
  "**"
  "**="
  "*="
  "/"
  "//"
  "//="
  "/="
  "&"
  "%"
  "%="
  "^"
  "+"
  "->"
  "+="
  "<"
  "<<"
  "<="
  "<>"
  "="
  ":="
  "=="
  ">"
  ">="
  ">>"
  "|"
  "~"
  "and"
  "in"
  "is"
  "not"
  "or"
] @operator

[
  "as"
  "assert"
  "async"
  "await"
  "break"
  "class"
  "continue"
  "def"
  "del"
  "elif"
  "else"
  "except"
  "exec"
  "finally"
  "for"
  "from"
  "global"
  "if"
  "import"
  "lambda"
  "nonlocal"
  "pass"
  "print"
  "raise"
  "return"
  "try"
  "while"
  "with"
  "yield"
] @keyword'
]

{ #category : #'as yet unclassified' }
SBPython class >> icon [

	^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 0 0 0 0 523598772 2889186227 3912530609 4281628847 4281628588 3778311850 2603906215 506753958 0 0 0 0 0 0 0 0 3258284979 1882553010 2905897135 4281628588 4281628330 4281627816 4281627558 3308548771 0 0 0 0 0 0 0 0 3425991089 2402580654 3274995628 4281628330 4281627816 4281627558 4281627299 4113854624 0 0 0 0 0 0 0 0 2050259375 2570352557 2570352298 2570352040 4281627558 4281627299 4281626784 4097011358 0 0 0 0 171277236 2419424179 3425991089 3425990830 3425990572 3425990314 3425989800 3425989541 4281627299 4281626784 4281560734 4097011100 2583681352 4294957126 3271546435 503305538 2134211507 4281629361 4281628847 4281628588 4281628330 4281627816 4281627558 4281627299 4281626784 4281560734 4281560475 3979570330 2583681093 4294956612 4294956098 2751451968 3694426801 4281628847 4281628588 4281628330 4281627816 4281627557 4281627299 4281626784 4281560734 4281560475 4281559961 3090377367 2751452739 4294956098 4294955840 3992965438 4281628847 4281628588 4281628330 4281627816 4281627557 3425989283 3425989024 3425988510 3425922460 3425922202 2570283671 1221243504 4127183938 4294955840 4294955326 4294954811 4281628588 4281628330 4281627816 4113855397 1520608143 2583682895 3439320397 3439320139 3439319624 3439319110 3439318596 4294956354 4294955840 4294955326 4294954811 4294954297 3744757418 4281627816 4281627557 2922672804 3053444943 4294958413 4294958155 4294957641 4294957126 4294956612 4294956354 4294955840 4294955326 4294954811 4294954553 3959409719 2402579623 4281627557 4281627299 2570351008 3439320397 4294958155 4294957641 4294957126 4294956612 4294956354 4294955840 4294955326 4294954812 4294954553 4294954039 2415905333 171209637 2922672803 4281626784 2570350494 3439320139 4294957641 4294957126 4294956868 3439318338 3439317824 3439317310 3439317052 3439316537 3439316023 2516568886 184535605 0 0 0 0 3439319625 4294957126 4294956868 4294956354 2583679808 2583679294 2583678779 2550123833 0 0 0 0 0 0 0 0 3439319110 4294956868 4294956354 4294955840 4294955326 3439317052 2248134202 4244622391 0 0 0 0 0 0 0 0 2936002372 4294956354 4294955840 4294955326 4294955068 3372207673 1694485302 3623865141 0 0 0 0 0 0 0 0 218093122 2415907905 3607089727 4294955068 4294954554 3791637560 2919222070 704629301 0 0 0 0)
	offset: 0@0)
]

{ #category : #'as yet unclassified' }
SBPython class >> language [

	^ #python
]

{ #category : #'as yet unclassified' }
SBPython class >> parseAsKeywordArgumentAndReplace: aString [

	^ (self parse: ('a({1})' format: {aString})) childSandblocks first childSandblocks second childSandblocks first applyReplacements
]

{ #category : #'as yet unclassified' }
SBPython class >> parseKeywordArgument: aString [
"encloses aString in a function call, parses and replaces it, then then returns first keyword."
	^ (self parseAndReplace: ('a({1})' format: {aString})) childSandblocks first childSandblocks second childSandblocks first
]

{ #category : #'as yet unclassified' }
SBPython class >> rootRuleName [

	^ 'module'
]

{ #category : #'as yet unclassified' }
SBPython class >> statementContainerTypes [

	^ #('block' 'module')
]

{ #category : #'as yet unclassified' }
SBPython >> browseImplementorsFor: aBlock [

	| identifier method toplevel |
	toplevel := aBlock toplevel valueOfProperty: #module ifAbsent: [^ self].
	identifier := aBlock contents ifNil: [^ self].
	aBlock parentSandblock type = 'attribute' ifFalse: [^ self].
	aBlock parentSandblock access object contents = 'self' ifFalse: [^ self].
	
	toplevel
		queryRecursiveFirstMatch: ('(class_definition (block
	(function_definition name: (identifier) ="{1}") @func))' format: {identifier})
		capturesDo: [:captures | method := captures at: 'func'].
	method ifNil: [^ self].
	
	method
		updateAllHighlights;
		attachToHand: ActiveHand in: aBlock sandblockEditor.
	
	^ method
]

{ #category : #'as yet unclassified' }
SBPython >> configure [

	self noteUncapturedText: #('string').
	self blockInline: #('expression_statement').
	self hardLineBreakMatcher: [:b | ((b isKindOf: SBInlineBlockLabel) and: [b label = ':']) and: [(b submorphAfter ifNotNil: #type) ~= 'type' and: [(b parentSandblock ifNotNil: #type) ~= 'pair']]]
]

{ #category : #'as yet unclassified' }
SBPython >> getModuleForSymbol: aString in: aModule [

	aModule
		queryRecursiveFirstMatch: ('(import_from_statement module_name: (dotted_name) @module name: (dotted_name (identifier) ="{1}"))' format: {aString})
		capturesDo: [:moduleCaptures | ]
]

{ #category : #'as yet unclassified' }
SBPython >> hardLineBreakBetween: aBlock and: anotherBlock [
	"match for TSBlock"

	(super hardLineBreakBetween: aBlock and: anotherBlock) ifTrue: [^ true].
	
	aBlock type = 'decorator' ifTrue: [^ true].
	
	((aBlock isStringMorph and: [aBlock contents = ':']) and: [anotherBlock type ~= 'type' and: [(aBlock parentSandblock ifNotNil: #type) ~= 'pair' and: [(aBlock parentSandblock ifNotNil: #type) ~= 'slice']]]) ifTrue: [^ true].
	
	^ #('else_clause' 'elif_clause') includes: anotherBlock type
]

{ #category : #'as yet unclassified' }
SBPython >> hardLineBreakMatchBetween: aBlock and: anotherBlock [
	"match for InlineBlocks"

	(aBlock isTSRepeat and: [aBlock hasSubmorphs and: [aBlock submorphs first type = 'decorator']]) ifTrue: [^ true].
	aBlock type = 'decorator' ifTrue: [^ true].
	
	((aBlock isTSLabel and: [aBlock label = ':']) and: [anotherBlock type ~= 'type' and: [(aBlock parentSandblock ifNotNil: #type) ~= 'pair' and: [(aBlock parentSandblock ifNotNil: #type) ~= 'slice']]]) ifTrue: [^ true].
	^ #('else_clause' 'elif_clause') includes: anotherBlock firstVisibleType
]

{ #category : #'as yet unclassified' }
SBPython >> indentMatch: aBlock [

	^ aBlock type = 'block'
]

{ #category : #'as yet unclassified' }
SBPython >> isImmutableLabel: aLabelNode [

	^ (super isImmutableLabel: aLabelNode) or: [#(':') includes: aLabelNode label]
]

{ #category : #'as yet unclassified' }
SBPython >> postConfigure [

	blockInline remove: 'block' ifAbsent: [].
	nodesCache at: 'string_content' put: (SBTSNodeContextSensitiveText new
		factory: self;
		validCheck: [:parser :character | character ~= parser slots first firstNode label];
		regexString: (nodesCache at: 'string_content') regexString)
]

{ #category : #'as yet unclassified' }
SBPython >> preprocessGrammar [

	| quotationTemplate |
	quotationTemplate := '{
			"type":"SEQ",
			"members": [
				{
					"type":"CHOICE",
					"members": [
						{"type":"STRING", "value":"''"},
						{"type":"STRING","value":"f''"},
						{"type":"STRING","value":"u''"},
						{"type":"STRING","value":"b''"},
						{"type":"STRING","value":"r''"}
					]
				},
                {
                    "type": "REPEAT",
                    "content": {
                        "type":"CHOICE",
                        "members": [
                            {"type":"SYMBOL", "name": "interpolation"},
                            {"type":"SYMBOL", "name": "escape_sequence"},
                            {"type":"SYMBOL", "name": "_not_escape_sequence"},
                            {"type":"SYMBOL", "name": "_string_content"}
                        ]
                    }
                },
                {"type": "STRING", "value": "''"}
			]
		}'.
	
	self grammar rules at: 'string' put: (Json readFrom: ('\{
	"type":"CHOICE",
	"members": [
		{1},
		{2},
		{3}
	]
\}' format: {
		quotationTemplate.
		quotationTemplate copyReplaceAll: '''' with: '\"'.
		quotationTemplate copyReplaceAll: '''' with: '\"\"\"'}) readStream).
	
	self grammar rules
		at: '_string_content'
		put: (JsonObject fromAssociations: {'type' -> 'PATTERN'. 'value' -> '.*'}).
	self grammar
		at: 'externals'
		put: ((self grammar at: 'externals') reject: [:obj | obj name = '_string_content']).
	self renameSymbol: '_string_content' to: 'string_content'.
	
	(self grammar rules at: '_suite') members: {(self grammar rules at: '_suite') members second}.
	
	"the _simple_statements rule poses a challenge because it leads to a expression+* construct that our repeater logic cannot handle well"
	(self grammar rules at: '_statement') members first name: '_simple_statement'.
	
	#('_indent' '_dedent' '_newline' '_string_start' '_string_end') do: [:sym | self removeSymbol: sym]
]

{ #category : #'as yet unclassified' }
SBPython >> separatorRule [

	^ separatorRule ifNil: [separatorRule := ((self buildRegexString: (grammar rules at: grammar word)), '|\d+') asRegex]
]

{ #category : #'as yet unclassified' }
SBPython >> softLineBreakBetween: aBlock and: anotherBlock [
	"for TSBlock"

	(super softLineBreakBetween: aBlock and: anotherBlock) ifTrue: [^ true].
	
	(aBlock isStringMorph and: [aBlock contents = 'or' or: [aBlock contents = 'and']]) ifTrue: [^ true].
	(anotherBlock isStringMorph and: [anotherBlock contents = '.']) ifTrue: [^ true].
	(aBlock parentSandblock ifNotNil: #type) = 'list_comprehension' ifTrue: [^ true].
	^ false
]

{ #category : #'as yet unclassified' }
SBPython >> softLineBreakMatchBetween: aBlock and: anotherBlock [
	"for SBInlineBlock"

	(aBlock isTSLabel and: [aBlock contents = 'or' or: [aBlock contents = 'and']]) ifTrue: [^ true].
	(anotherBlock isTSLabel and: [anotherBlock contents = '.']) ifTrue: [^ true].
	(aBlock parentSandblock ifNotNil: #type) = 'list_comprehension' ifTrue: [^ true].
	^ false
]

{ #category : #'as yet unclassified' }
SBPython >> validDropDestination: aBlock [

	^ aBlock element type ~= 'expression'
]
