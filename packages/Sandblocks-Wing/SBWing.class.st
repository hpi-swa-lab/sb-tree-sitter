Class {
	#name : #SBWing,
	#superclass : #SBTSLanguage,
	#category : #'Sandblocks-Wing'
}

{ #category : #'as yet unclassified' }
SBWing class >> buildToggleFor: aBlock [

	| expr |
	expr := self parseExpression: '[() => {return _a}][0]()'.
	(expr queryNode: '(reference_identifier) ="_a" @') replaceBlock: aBlock copyBlock.
	^ expr
]

{ #category : #'configuration - declarations' }
SBWing class >> declarationsInScope: aScopeBlock do: aClosure [

	aScopeBlock type = 'function' ifTrue: [
		aScopeBlock childSandblocksDo: [:block | ((block compatibleWithType: 'pattern') or: [block compatibleWithType: 'assignment_pattern']) ifTrue: [block allBlocksDo: [:b | b type = 'identifier' ifTrue: [aClosure value: (SBTSDeclaration block: b label: 'func arg')]]]].
		self declarationsInScope: (aScopeBlock get: 'body') do: aClosure].
	(aScopeBlock type = 'block' or: [aScopeBlock type = 'source']) ifTrue: [aScopeBlock childSandblocksDo: [:statement | statement type = 'variable_definition_statement' ifTrue: [aClosure value: (SBTSDeclaration block: (statement get: 'name') label: 'lexical decl')]]]
]

{ #category : #configuration }
SBWing class >> fileSuffix [

	^ 'w'
]

{ #category : #properties }
SBWing class >> grammarJson [

    " https://github.com/winglang/wing/blob/master/src/grammar.json "
    ^ '{
  "name": "wing",
  "word": "identifier",
  "rules": {
    "source": {
      "type": "REPEAT",
      "content": {
        "type": "SYMBOL",
        "name": "_statement"
      }
    },
    "block": {
      "type": "CHOICE",
      "members": [
        {
          "type": "CHOICE",
          "members": [
            {
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
                      "type": "REPEAT",
                      "content": {
                        "type": "SYMBOL",
                        "name": "_statement"
                      }
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
          ]
        },
        {
          "type": "SYMBOL",
          "name": "AUTOMATIC_BLOCK"
        }
      ]
    },
    "_semicolon": {
      "type": "CHOICE",
      "members": [
        {
          "type": "STRING",
          "value": ";"
        },
        {
          "type": "SYMBOL",
          "name": "AUTOMATIC_SEMICOLON"
        }
      ]
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
    "reference": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "nested_identifier"
        },
        {
          "type": "SYMBOL",
          "name": "_reference_identifier"
        },
        {
          "type": "SYMBOL",
          "name": "structured_access_expression"
        }
      ]
    },
    "identifier": {
      "type": "PATTERN",
      "value": "([A-Za-z_$][A-Za-z_$0-9]*|[A-Z][A-Z0-9_]*)"
    },
    "_type_identifier": {
      "type": "ALIAS",
      "content": {
        "type": "SYMBOL",
        "name": "identifier"
      },
      "named": true,
      "value": "type_identifier"
    },
    "_member_identifier": {
      "type": "ALIAS",
      "content": {
        "type": "SYMBOL",
        "name": "identifier"
      },
      "named": true,
      "value": "member_identifier"
    },
    "_reference_identifier": {
      "type": "ALIAS",
      "content": {
        "type": "SYMBOL",
        "name": "identifier"
      },
      "named": true,
      "value": "reference_identifier"
    },
    "custom_type": {
      "type": "PREC_RIGHT",
      "value": 0,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "FIELD",
            "name": "object",
            "content": {
              "type": "SYMBOL",
              "name": "_type_identifier"
            }
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
                  "type": "CHOICE",
                  "members": [
                    {
                      "type": "FIELD",
                      "name": "fields",
                      "content": {
                        "type": "SYMBOL",
                        "name": "_type_identifier"
                      }
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
      }
    },
    "nested_identifier": {
      "type": "PREC",
      "value": 150,
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
                  "name": "json_container_type"
                }
              ]
            }
          },
          {
            "type": "FIELD",
            "name": "accessor_type",
            "content": {
              "type": "SYMBOL",
              "name": "_accessor"
            }
          },
          {
            "type": "CHOICE",
            "members": [
              {
                "type": "FIELD",
                "name": "property",
                "content": {
                  "type": "SYMBOL",
                  "name": "_member_identifier"
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
    "_accessor": {
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
    "inflight_specifier": {
      "type": "STRING",
      "value": "inflight"
    },
    "_statement": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "test_statement"
        },
        {
          "type": "SYMBOL",
          "name": "short_import_statement"
        },
        {
          "type": "SYMBOL",
          "name": "expression_statement"
        },
        {
          "type": "SYMBOL",
          "name": "variable_definition_statement"
        },
        {
          "type": "SYMBOL",
          "name": "variable_assignment_statement"
        },
        {
          "type": "SYMBOL",
          "name": "return_statement"
        },
        {
          "type": "SYMBOL",
          "name": "class_definition"
        },
        {
          "type": "SYMBOL",
          "name": "resource_definition"
        },
        {
          "type": "SYMBOL",
          "name": "interface_definition"
        },
        {
          "type": "SYMBOL",
          "name": "for_in_loop"
        },
        {
          "type": "SYMBOL",
          "name": "while_statement"
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
          "name": "if_statement"
        },
        {
          "type": "SYMBOL",
          "name": "if_let_statement"
        },
        {
          "type": "SYMBOL",
          "name": "struct_definition"
        },
        {
          "type": "SYMBOL",
          "name": "enum_definition"
        },
        {
          "type": "SYMBOL",
          "name": "try_catch_statement"
        }
      ]
    },
    "short_import_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "bring"
        },
        {
          "type": "FIELD",
          "name": "module_name",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "identifier"
              },
              {
                "type": "SYMBOL",
                "name": "string"
              }
            ]
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
        },
        {
          "type": "SYMBOL",
          "name": "_semicolon"
        }
      ]
    },
    "struct_definition": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "struct"
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
              "type": "SEQ",
              "members": [
                {
                  "type": "STRING",
                  "value": "extends"
                },
                {
                  "type": "CHOICE",
                  "members": [
                    {
                      "type": "SEQ",
                      "members": [
                        {
                          "type": "FIELD",
                          "name": "extends",
                          "content": {
                            "type": "SYMBOL",
                            "name": "custom_type"
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
                                "name": "extends",
                                "content": {
                                  "type": "SYMBOL",
                                  "name": "custom_type"
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
          "type": "CHOICE",
          "members": [
            {
              "type": "SEQ",
              "members": [
                {
                  "type": "STRING",
                  "value": "{"
                },
                {
                  "type": "REPEAT",
                  "content": {
                    "type": "FIELD",
                    "name": "field",
                    "content": {
                      "type": "SYMBOL",
                      "name": "struct_field"
                    }
                  }
                },
                {
                  "type": "STRING",
                  "value": "}"
                }
              ]
            }
          ]
        }
      ]
    },
    "struct_field": {
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
          "type": "SYMBOL",
          "name": "_type_annotation"
        },
        {
          "type": "SYMBOL",
          "name": "_semicolon"
        }
      ]
    },
    "enum_definition": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "enum"
        },
        {
          "type": "FIELD",
          "name": "enum_name",
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
                            "name": "identifier"
                          },
                          "named": true,
                          "value": "enum_field"
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
                                  "name": "identifier"
                                },
                                "named": true,
                                "value": "enum_field"
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
          ]
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
              "type": "FIELD",
              "name": "expression",
              "content": {
                "type": "SYMBOL",
                "name": "expression"
              }
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
    "variable_assignment_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "name",
          "content": {
            "type": "ALIAS",
            "content": {
              "type": "SYMBOL",
              "name": "reference"
            },
            "named": true,
            "value": "lvalue"
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
        },
        {
          "type": "SYMBOL",
          "name": "_semicolon"
        }
      ]
    },
    "expression_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "SYMBOL",
          "name": "expression"
        },
        {
          "type": "SYMBOL",
          "name": "_semicolon"
        }
      ]
    },
    "reassignable": {
      "type": "STRING",
      "value": "var"
    },
    "static": {
      "type": "STRING",
      "value": "static"
    },
    "variable_definition_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "let"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "FIELD",
              "name": "reassignable",
              "content": {
                "type": "SYMBOL",
                "name": "reassignable"
              }
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
            "name": "identifier"
          }
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "_type_annotation"
            },
            {
              "type": "BLANK"
            }
          ]
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
        },
        {
          "type": "SYMBOL",
          "name": "_semicolon"
        }
      ]
    },
    "_type_annotation": {
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
            "name": "_type"
          }
        }
      ]
    },
    "class_definition": {
      "type": "SEQ",
      "members": [
        {
          "type": "SYMBOL",
          "name": "inflight_specifier"
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
              "type": "SEQ",
              "members": [
                {
                  "type": "STRING",
                  "value": "extends"
                },
                {
                  "type": "FIELD",
                  "name": "parent",
                  "content": {
                    "type": "SYMBOL",
                    "name": "custom_type"
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
              "type": "SEQ",
              "members": [
                {
                  "type": "STRING",
                  "value": "impl"
                },
                {
                  "type": "FIELD",
                  "name": "implements",
                  "content": {
                    "type": "SEQ",
                    "members": [
                      {
                        "type": "SYMBOL",
                        "name": "custom_type"
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
                              "name": "custom_type"
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
          "name": "implementation",
          "content": {
            "type": "SYMBOL",
            "name": "class_implementation"
          }
        }
      ]
    },
    "class_implementation": {
      "type": "CHOICE",
      "members": [
        {
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
                    "name": "initializer"
                  },
                  {
                    "type": "SYMBOL",
                    "name": "method_definition"
                  },
                  {
                    "type": "SYMBOL",
                    "name": "inflight_method_definition"
                  },
                  {
                    "type": "SYMBOL",
                    "name": "class_field"
                  }
                ]
              }
            },
            {
              "type": "STRING",
              "value": "}"
            }
          ]
        }
      ]
    },
    "class_field": {
      "type": "SEQ",
      "members": [
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "FIELD",
              "name": "access_modifier",
              "content": {
                "type": "SYMBOL",
                "name": "access_modifier"
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
              "name": "static",
              "content": {
                "type": "SYMBOL",
                "name": "static"
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
              "name": "phase_modifier",
              "content": {
                "type": "SYMBOL",
                "name": "inflight_specifier"
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
              "name": "reassignable",
              "content": {
                "type": "SYMBOL",
                "name": "reassignable"
              }
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
            "name": "identifier"
          }
        },
        {
          "type": "SYMBOL",
          "name": "_type_annotation"
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
                  "name": "initializer",
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
        },
        {
          "type": "SYMBOL",
          "name": "_semicolon"
        }
      ]
    },
    "resource_definition": {
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
          "type": "CHOICE",
          "members": [
            {
              "type": "SEQ",
              "members": [
                {
                  "type": "STRING",
                  "value": "extends"
                },
                {
                  "type": "FIELD",
                  "name": "parent",
                  "content": {
                    "type": "SYMBOL",
                    "name": "custom_type"
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
              "type": "SEQ",
              "members": [
                {
                  "type": "STRING",
                  "value": "impl"
                },
                {
                  "type": "FIELD",
                  "name": "implements",
                  "content": {
                    "type": "SEQ",
                    "members": [
                      {
                        "type": "SYMBOL",
                        "name": "custom_type"
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
                              "name": "custom_type"
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
          "name": "implementation",
          "content": {
            "type": "SYMBOL",
            "name": "resource_implementation"
          }
        }
      ]
    },
    "resource_implementation": {
      "type": "CHOICE",
      "members": [
        {
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
                    "name": "initializer"
                  },
                  {
                    "type": "SYMBOL",
                    "name": "method_definition"
                  },
                  {
                    "type": "SYMBOL",
                    "name": "inflight_method_definition"
                  },
                  {
                    "type": "SYMBOL",
                    "name": "class_field"
                  }
                ]
              }
            },
            {
              "type": "STRING",
              "value": "}"
            }
          ]
        }
      ]
    },
    "interface_definition": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "interface"
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
              "type": "SEQ",
              "members": [
                {
                  "type": "STRING",
                  "value": "extends"
                },
                {
                  "type": "FIELD",
                  "name": "extends",
                  "content": {
                    "type": "SEQ",
                    "members": [
                      {
                        "type": "SYMBOL",
                        "name": "custom_type"
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
                              "name": "custom_type"
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
          "name": "implementation",
          "content": {
            "type": "SYMBOL",
            "name": "interface_implementation"
          }
        }
      ]
    },
    "interface_implementation": {
      "type": "CHOICE",
      "members": [
        {
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
                    "name": "method_signature"
                  },
                  {
                    "type": "SYMBOL",
                    "name": "inflight_method_signature"
                  },
                  {
                    "type": "SYMBOL",
                    "name": "class_field"
                  }
                ]
              }
            },
            {
              "type": "STRING",
              "value": "}"
            }
          ]
        }
      ]
    },
    "inclusive_range": {
      "type": "STRING",
      "value": "="
    },
    "loop_range": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "start",
          "content": {
            "type": "SYMBOL",
            "name": "expression"
          }
        },
        {
          "type": "STRING",
          "value": ".."
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "FIELD",
              "name": "inclusive",
              "content": {
                "type": "SYMBOL",
                "name": "inclusive_range"
              }
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "FIELD",
          "name": "end",
          "content": {
            "type": "SYMBOL",
            "name": "expression"
          }
        }
      ]
    },
    "for_in_loop": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "for"
        },
        {
          "type": "FIELD",
          "name": "iterator",
          "content": {
            "type": "SYMBOL",
            "name": "identifier"
          }
        },
        {
          "type": "STRING",
          "value": "in"
        },
        {
          "type": "FIELD",
          "name": "iterable",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "expression"
              },
              {
                "type": "SYMBOL",
                "name": "loop_range"
              }
            ]
          }
        },
        {
          "type": "FIELD",
          "name": "block",
          "content": {
            "type": "SYMBOL",
            "name": "block"
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
          "type": "FIELD",
          "name": "block",
          "content": {
            "type": "SYMBOL",
            "name": "block"
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
          "type": "SYMBOL",
          "name": "_semicolon"
        }
      ]
    },
    "if_let_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "if let"
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
        },
        {
          "type": "FIELD",
          "name": "block",
          "content": {
            "type": "SYMBOL",
            "name": "block"
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
                  "value": "else"
                },
                {
                  "type": "FIELD",
                  "name": "else_block",
                  "content": {
                    "type": "SYMBOL",
                    "name": "block"
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
          "type": "FIELD",
          "name": "block",
          "content": {
            "type": "SYMBOL",
            "name": "block"
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "FIELD",
            "name": "elif_block",
            "content": {
              "type": "SYMBOL",
              "name": "elif_block"
            }
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
                  "value": "else"
                },
                {
                  "type": "FIELD",
                  "name": "else_block",
                  "content": {
                    "type": "SYMBOL",
                    "name": "block"
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
    "elif_block": {
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
          "type": "FIELD",
          "name": "block",
          "content": {
            "type": "SYMBOL",
            "name": "block"
          }
        }
      ]
    },
    "try_catch_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "try"
        },
        {
          "type": "FIELD",
          "name": "block",
          "content": {
            "type": "SYMBOL",
            "name": "block"
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
                  "value": "catch"
                },
                {
                  "type": "CHOICE",
                  "members": [
                    {
                      "type": "FIELD",
                      "name": "exception_identifier",
                      "content": {
                        "type": "SYMBOL",
                        "name": "identifier"
                      }
                    },
                    {
                      "type": "BLANK"
                    }
                  ]
                },
                {
                  "type": "FIELD",
                  "name": "catch_block",
                  "content": {
                    "type": "SYMBOL",
                    "name": "block"
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
              "type": "SEQ",
              "members": [
                {
                  "type": "STRING",
                  "value": "finally"
                },
                {
                  "type": "FIELD",
                  "name": "finally_block",
                  "content": {
                    "type": "SYMBOL",
                    "name": "block"
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
    "expression": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "binary_expression"
        },
        {
          "type": "SYMBOL",
          "name": "unary_expression"
        },
        {
          "type": "SYMBOL",
          "name": "new_expression"
        },
        {
          "type": "SYMBOL",
          "name": "_literal"
        },
        {
          "type": "SYMBOL",
          "name": "reference"
        },
        {
          "type": "SYMBOL",
          "name": "call"
        },
        {
          "type": "SYMBOL",
          "name": "preflight_closure"
        },
        {
          "type": "SYMBOL",
          "name": "inflight_closure"
        },
        {
          "type": "SYMBOL",
          "name": "await_expression"
        },
        {
          "type": "SYMBOL",
          "name": "defer_expression"
        },
        {
          "type": "SYMBOL",
          "name": "_collection_literal"
        },
        {
          "type": "SYMBOL",
          "name": "parenthesized_expression"
        },
        {
          "type": "SYMBOL",
          "name": "json_literal"
        },
        {
          "type": "SYMBOL",
          "name": "struct_literal"
        },
        {
          "type": "SYMBOL",
          "name": "optional_test"
        }
      ]
    },
    "_literal": {
      "type": "CHOICE",
      "members": [
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
          "name": "bool"
        },
        {
          "type": "SYMBOL",
          "name": "duration"
        },
        {
          "type": "SYMBOL",
          "name": "nil_value"
        }
      ]
    },
    "number": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "_integer"
        },
        {
          "type": "SYMBOL",
          "name": "_decimal"
        }
      ]
    },
    "_integer": {
      "type": "CHOICE",
      "members": [
        {
          "type": "STRING",
          "value": "0"
        },
        {
          "type": "PATTERN",
          "value": "[1-9]\\d*"
        }
      ]
    },
    "_decimal": {
      "type": "CHOICE",
      "members": [
        {
          "type": "PATTERN",
          "value": "0\\.\\d+"
        },
        {
          "type": "PATTERN",
          "value": "[1-9]\\d*\\.\\d+"
        }
      ]
    },
    "bool": {
      "type": "CHOICE",
      "members": [
        {
          "type": "STRING",
          "value": "true"
        },
        {
          "type": "STRING",
          "value": "false"
        }
      ]
    },
    "duration": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "seconds"
        },
        {
          "type": "SYMBOL",
          "name": "minutes"
        },
        {
          "type": "SYMBOL",
          "name": "hours"
        }
      ]
    },
    "seconds": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "value",
          "content": {
            "type": "SYMBOL",
            "name": "number"
          }
        },
        {
          "type": "STRING",
          "value": "s"
        }
      ]
    },
    "minutes": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "value",
          "content": {
            "type": "SYMBOL",
            "name": "number"
          }
        },
        {
          "type": "STRING",
          "value": "m"
        }
      ]
    },
    "hours": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "value",
          "content": {
            "type": "SYMBOL",
            "name": "number"
          }
        },
        {
          "type": "STRING",
          "value": "h"
        }
      ]
    },
    "nil_value": {
      "type": "STRING",
      "value": "nil"
    },
    "string": {
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
                "type": "SYMBOL",
                "name": "_string_fragment"
              },
              {
                "type": "SYMBOL",
                "name": "_escape_sequence"
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
          "value": "\""
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
          "name": "expression"
        },
        {
          "type": "STRING",
          "value": "}"
        }
      ]
    },
    "_string_fragment": {
      "type": "IMMEDIATE_TOKEN",
      "content": {
        "type": "PREC",
        "value": 1,
        "content": {
          "type": "PATTERN",
          "value": "[^$\"\\\\]+"
        }
      }
    },
    "_escape_sequence": {
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
                "type": "STRING",
                "value": "$"
              },
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
    "optional_test": {
      "type": "PREC_RIGHT",
      "value": 130,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "SYMBOL",
            "name": "expression"
          },
          {
            "type": "STRING",
            "value": "?"
          }
        ]
      }
    },
    "_callable_expression": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "nested_identifier"
        },
        {
          "type": "SYMBOL",
          "name": "identifier"
        },
        {
          "type": "SYMBOL",
          "name": "call"
        },
        {
          "type": "SYMBOL",
          "name": "parenthesized_expression"
        }
      ]
    },
    "call": {
      "type": "PREC_LEFT",
      "value": 160,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "FIELD",
            "name": "caller",
            "content": {
              "type": "SYMBOL",
              "name": "expression"
            }
          },
          {
            "type": "FIELD",
            "name": "args",
            "content": {
              "type": "SYMBOL",
              "name": "argument_list"
            }
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
              "type": "CHOICE",
              "members": [
                {
                  "type": "SEQ",
                  "members": [
                    {
                      "type": "SYMBOL",
                      "name": "positional_argument"
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
                            "name": "positional_argument"
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
                      "type": "SYMBOL",
                      "name": "keyword_argument"
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
                            "name": "keyword_argument"
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
                },
                {
                  "type": "BLANK"
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
                          "type": "SYMBOL",
                          "name": "positional_argument"
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
                                "name": "positional_argument"
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
                    },
                    {
                      "type": "BLANK"
                    }
                  ]
                },
                {
                  "type": "STRING",
                  "value": ","
                },
                {
                  "type": "CHOICE",
                  "members": [
                    {
                      "type": "SEQ",
                      "members": [
                        {
                          "type": "SYMBOL",
                          "name": "keyword_argument"
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
                                "name": "keyword_argument"
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
          "value": ")"
        }
      ]
    },
    "positional_argument": {
      "type": "SYMBOL",
      "name": "expression"
    },
    "keyword_argument": {
      "type": "PREC",
      "value": 3,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "ALIAS",
            "content": {
              "type": "SYMBOL",
              "name": "identifier"
            },
            "named": true,
            "value": "keyword_argument_key"
          },
          {
            "type": "STRING",
            "value": ":"
          },
          {
            "type": "ALIAS",
            "content": {
              "type": "SYMBOL",
              "name": "expression"
            },
            "named": true,
            "value": "keyword_argument_value"
          }
        ]
      }
    },
    "new_expression": {
      "type": "PREC_RIGHT",
      "value": 0,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "STRING",
            "value": "new"
          },
          {
            "type": "FIELD",
            "name": "class",
            "content": {
              "type": "CHOICE",
              "members": [
                {
                  "type": "SYMBOL",
                  "name": "custom_type"
                },
                {
                  "type": "SYMBOL",
                  "name": "mutable_container_type"
                }
              ]
            }
          },
          {
            "type": "FIELD",
            "name": "args",
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
            "type": "FIELD",
            "name": "id",
            "content": {
              "type": "CHOICE",
              "members": [
                {
                  "type": "SYMBOL",
                  "name": "new_object_id"
                },
                {
                  "type": "BLANK"
                }
              ]
            }
          },
          {
            "type": "FIELD",
            "name": "scope",
            "content": {
              "type": "CHOICE",
              "members": [
                {
                  "type": "SYMBOL",
                  "name": "new_object_scope"
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
    "new_object_id": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "as"
        },
        {
          "type": "SYMBOL",
          "name": "string"
        }
      ]
    },
    "new_object_scope": {
      "type": "PREC_RIGHT",
      "value": 0,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "STRING",
            "value": "in"
          },
          {
            "type": "SYMBOL",
            "name": "expression"
          }
        ]
      }
    },
    "_type": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "custom_type"
        },
        {
          "type": "SYMBOL",
          "name": "builtin_type"
        },
        {
          "type": "SYMBOL",
          "name": "_builtin_container_type"
        },
        {
          "type": "SYMBOL",
          "name": "json_container_type"
        },
        {
          "type": "SYMBOL",
          "name": "function_type"
        },
        {
          "type": "SYMBOL",
          "name": "optional"
        }
      ]
    },
    "optional": {
      "type": "SEQ",
      "members": [
        {
          "type": "SYMBOL",
          "name": "_type"
        },
        {
          "type": "STRING",
          "value": "?"
        }
      ]
    },
    "function_type": {
      "type": "PREC_RIGHT",
      "value": 0,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "CHOICE",
            "members": [
              {
                "type": "FIELD",
                "name": "inflight",
                "content": {
                  "type": "SYMBOL",
                  "name": "inflight_specifier"
                }
              },
              {
                "type": "BLANK"
              }
            ]
          },
          {
            "type": "FIELD",
            "name": "parameter_types",
            "content": {
              "type": "SYMBOL",
              "name": "parameter_type_list"
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
                    "value": ":"
                  },
                  {
                    "type": "FIELD",
                    "name": "return_type",
                    "content": {
                      "type": "SYMBOL",
                      "name": "_type"
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
    "parameter_type_list": {
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
                  "type": "SYMBOL",
                  "name": "_type"
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
                        "name": "_type"
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
    "builtin_type": {
      "type": "CHOICE",
      "members": [
        {
          "type": "STRING",
          "value": "num"
        },
        {
          "type": "STRING",
          "value": "bool"
        },
        {
          "type": "STRING",
          "value": "any"
        },
        {
          "type": "STRING",
          "value": "str"
        },
        {
          "type": "STRING",
          "value": "void"
        },
        {
          "type": "STRING",
          "value": "duration"
        }
      ]
    },
    "initializer": {
      "type": "SEQ",
      "members": [
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "FIELD",
              "name": "inflight",
              "content": {
                "type": "SYMBOL",
                "name": "inflight_specifier"
              }
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "STRING",
          "value": "init"
        },
        {
          "type": "FIELD",
          "name": "parameter_list",
          "content": {
            "type": "SYMBOL",
            "name": "parameter_list"
          }
        },
        {
          "type": "FIELD",
          "name": "block",
          "content": {
            "type": "SYMBOL",
            "name": "block"
          }
        }
      ]
    },
    "extern_modifier": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "extern"
        },
        {
          "type": "SYMBOL",
          "name": "string"
        }
      ]
    },
    "_return_type": {
      "type": "SYMBOL",
      "name": "_type_annotation"
    },
    "method_signature": {
      "type": "SEQ",
      "members": [
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "FIELD",
              "name": "async",
              "content": {
                "type": "SYMBOL",
                "name": "async_modifier"
              }
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
            "name": "identifier"
          }
        },
        {
          "type": "FIELD",
          "name": "parameter_list",
          "content": {
            "type": "SYMBOL",
            "name": "parameter_list"
          }
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "_return_type"
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
    "method_definition": {
      "type": "SEQ",
      "members": [
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "FIELD",
              "name": "extern_modifier",
              "content": {
                "type": "SYMBOL",
                "name": "extern_modifier"
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
              "name": "access_modifier",
              "content": {
                "type": "SYMBOL",
                "name": "access_modifier"
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
              "name": "static",
              "content": {
                "type": "SYMBOL",
                "name": "static"
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
              "name": "async",
              "content": {
                "type": "SYMBOL",
                "name": "async_modifier"
              }
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
            "name": "identifier"
          }
        },
        {
          "type": "FIELD",
          "name": "parameter_list",
          "content": {
            "type": "SYMBOL",
            "name": "parameter_list"
          }
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "_return_type"
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
              "name": "block",
              "content": {
                "type": "SYMBOL",
                "name": "block"
              }
            },
            {
              "type": "SYMBOL",
              "name": "_semicolon"
            }
          ]
        }
      ]
    },
    "inflight_method_signature": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "phase_modifier",
          "content": {
            "type": "SYMBOL",
            "name": "inflight_specifier"
          }
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
          "name": "parameter_list",
          "content": {
            "type": "SYMBOL",
            "name": "parameter_list"
          }
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "_return_type"
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
    "inflight_method_definition": {
      "type": "SEQ",
      "members": [
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "FIELD",
              "name": "extern_modifier",
              "content": {
                "type": "SYMBOL",
                "name": "extern_modifier"
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
              "name": "access_modifier",
              "content": {
                "type": "SYMBOL",
                "name": "access_modifier"
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
              "name": "static",
              "content": {
                "type": "SYMBOL",
                "name": "static"
              }
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "FIELD",
          "name": "phase_modifier",
          "content": {
            "type": "SYMBOL",
            "name": "inflight_specifier"
          }
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
          "name": "parameter_list",
          "content": {
            "type": "SYMBOL",
            "name": "parameter_list"
          }
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "_return_type"
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
              "name": "block",
              "content": {
                "type": "SYMBOL",
                "name": "block"
              }
            },
            {
              "type": "SYMBOL",
              "name": "_semicolon"
            }
          ]
        }
      ]
    },
    "async_modifier": {
      "type": "STRING",
      "value": "async"
    },
    "access_modifier": {
      "type": "CHOICE",
      "members": [
        {
          "type": "STRING",
          "value": "public"
        },
        {
          "type": "STRING",
          "value": "private"
        },
        {
          "type": "STRING",
          "value": "protected"
        }
      ]
    },
    "parameter_definition": {
      "type": "SEQ",
      "members": [
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "FIELD",
              "name": "reassignable",
              "content": {
                "type": "SYMBOL",
                "name": "reassignable"
              }
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
            "name": "identifier"
          }
        },
        {
          "type": "SYMBOL",
          "name": "_type_annotation"
        }
      ]
    },
    "parameter_list": {
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
                  "type": "SYMBOL",
                  "name": "parameter_definition"
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
                        "name": "parameter_definition"
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
    "immutable_container_type": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "collection_type",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "STRING",
                "value": "Array"
              },
              {
                "type": "STRING",
                "value": "Set"
              },
              {
                "type": "STRING",
                "value": "Map"
              },
              {
                "type": "STRING",
                "value": "Promise"
              }
            ]
          }
        },
        {
          "type": "SYMBOL",
          "name": "_container_value_type"
        }
      ]
    },
    "mutable_container_type": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SEQ",
          "members": [
            {
              "type": "FIELD",
              "name": "collection_type",
              "content": {
                "type": "CHOICE",
                "members": [
                  {
                    "type": "STRING",
                    "value": "MutSet"
                  },
                  {
                    "type": "STRING",
                    "value": "MutMap"
                  },
                  {
                    "type": "STRING",
                    "value": "MutArray"
                  }
                ]
              }
            },
            {
              "type": "SYMBOL",
              "name": "_container_value_type"
            }
          ]
        }
      ]
    },
    "_builtin_container_type": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "immutable_container_type"
        },
        {
          "type": "SYMBOL",
          "name": "mutable_container_type"
        }
      ]
    },
    "_container_value_type": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "<"
        },
        {
          "type": "FIELD",
          "name": "type_parameter",
          "content": {
            "type": "SYMBOL",
            "name": "_type"
          }
        },
        {
          "type": "STRING",
          "value": ">"
        }
      ]
    },
    "unary_expression": {
      "type": "CHOICE",
      "members": [
        {
          "type": "PREC_LEFT",
          "value": 120,
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "FIELD",
                "name": "op",
                "content": {
                  "type": "STRING",
                  "value": "--"
                }
              },
              {
                "type": "FIELD",
                "name": "arg",
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
          "value": 120,
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "FIELD",
                "name": "op",
                "content": {
                  "type": "STRING",
                  "value": "-"
                }
              },
              {
                "type": "FIELD",
                "name": "arg",
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
          "value": 120,
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "FIELD",
                "name": "op",
                "content": {
                  "type": "STRING",
                  "value": "!"
                }
              },
              {
                "type": "FIELD",
                "name": "arg",
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
    "binary_expression": {
      "type": "CHOICE",
      "members": [
        {
          "type": "PREC_LEFT",
          "value": 100,
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
                "name": "op",
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
          "value": 100,
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
                "name": "op",
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
          "value": 110,
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
                "name": "op",
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
          "value": 110,
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
                "name": "op",
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
          "value": 110,
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
                "name": "op",
                "content": {
                  "type": "STRING",
                  "value": "\\"
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
          "value": 110,
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
                "name": "op",
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
          "value": 140,
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
                "name": "op",
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
                "name": "op",
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
          "value": 20,
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
                "name": "op",
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
          "value": 60,
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
                "name": "op",
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
          "value": 60,
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
                "name": "op",
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
          "value": 70,
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
                "name": "op",
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
          "value": 70,
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
                "name": "op",
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
          "value": 70,
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
                "name": "op",
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
          "value": 70,
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
                "name": "op",
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
          "value": 80,
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
                "name": "op",
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
        }
      ]
    },
    "preflight_closure": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "parameter_list",
          "content": {
            "type": "SYMBOL",
            "name": "parameter_list"
          }
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "_return_type"
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "STRING",
          "value": "=>"
        },
        {
          "type": "FIELD",
          "name": "block",
          "content": {
            "type": "SYMBOL",
            "name": "block"
          }
        }
      ]
    },
    "inflight_closure": {
      "type": "SEQ",
      "members": [
        {
          "type": "SYMBOL",
          "name": "inflight_specifier"
        },
        {
          "type": "FIELD",
          "name": "parameter_list",
          "content": {
            "type": "SYMBOL",
            "name": "parameter_list"
          }
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "_return_type"
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "STRING",
          "value": "=>"
        },
        {
          "type": "FIELD",
          "name": "block",
          "content": {
            "type": "SYMBOL",
            "name": "block"
          }
        }
      ]
    },
    "await_expression": {
      "type": "PREC_RIGHT",
      "value": 0,
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
    "defer_expression": {
      "type": "PREC_RIGHT",
      "value": 0,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "STRING",
            "value": "defer"
          },
          {
            "type": "SYMBOL",
            "name": "expression"
          }
        ]
      }
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
          "name": "expression"
        },
        {
          "type": "STRING",
          "value": ")"
        }
      ]
    },
    "_collection_literal": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "array_literal"
        },
        {
          "type": "SYMBOL",
          "name": "set_literal"
        },
        {
          "type": "SYMBOL",
          "name": "map_literal"
        }
      ]
    },
    "array_literal": {
      "type": "SEQ",
      "members": [
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "FIELD",
              "name": "type",
              "content": {
                "type": "SYMBOL",
                "name": "_builtin_container_type"
              }
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
          "type": "CHOICE",
          "members": [
            {
              "type": "SEQ",
              "members": [
                {
                  "type": "FIELD",
                  "name": "element",
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
                        "name": "element",
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
    "set_literal": {
      "type": "SEQ",
      "members": [
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "FIELD",
              "name": "type",
              "content": {
                "type": "SYMBOL",
                "name": "_builtin_container_type"
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
                          "type": "FIELD",
                          "name": "element",
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
                                "name": "element",
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
          ]
        }
      ]
    },
    "map_literal": {
      "type": "SEQ",
      "members": [
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "FIELD",
              "name": "type",
              "content": {
                "type": "SYMBOL",
                "name": "_builtin_container_type"
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
                          "type": "FIELD",
                          "name": "member",
                          "content": {
                            "type": "SYMBOL",
                            "name": "map_literal_member"
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
                                "name": "member",
                                "content": {
                                  "type": "SYMBOL",
                                  "name": "map_literal_member"
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
          ]
        }
      ]
    },
    "struct_literal": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "type",
          "content": {
            "type": "SYMBOL",
            "name": "custom_type"
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
                  "value": "{"
                },
                {
                  "type": "CHOICE",
                  "members": [
                    {
                      "type": "SEQ",
                      "members": [
                        {
                          "type": "FIELD",
                          "name": "fields",
                          "content": {
                            "type": "SYMBOL",
                            "name": "struct_literal_member"
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
                                "name": "fields",
                                "content": {
                                  "type": "SYMBOL",
                                  "name": "struct_literal_member"
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
          ]
        }
      ]
    },
    "map_literal_member": {
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
              "name": "string"
            }
          ]
        },
        {
          "type": "STRING",
          "value": ":"
        },
        {
          "type": "SYMBOL",
          "name": "expression"
        }
      ]
    },
    "struct_literal_member": {
      "type": "SEQ",
      "members": [
        {
          "type": "SYMBOL",
          "name": "identifier"
        },
        {
          "type": "STRING",
          "value": ":"
        },
        {
          "type": "SYMBOL",
          "name": "expression"
        }
      ]
    },
    "structured_access_expression": {
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
      }
    },
    "json_literal": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "type",
          "content": {
            "type": "SYMBOL",
            "name": "json_container_type"
          }
        },
        {
          "type": "FIELD",
          "name": "element",
          "content": {
            "type": "SYMBOL",
            "name": "expression"
          }
        }
      ]
    },
    "json_container_type": {
      "type": "SYMBOL",
      "name": "_json_types"
    },
    "_json_types": {
      "type": "CHOICE",
      "members": [
        {
          "type": "STRING",
          "value": "Json"
        },
        {
          "type": "STRING",
          "value": "MutJson"
        }
      ]
    },
    "test_statement": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "test"
        },
        {
          "type": "FIELD",
          "name": "name",
          "content": {
            "type": "SYMBOL",
            "name": "string"
          }
        },
        {
          "type": "FIELD",
          "name": "block",
          "content": {
            "type": "SYMBOL",
            "name": "block"
          }
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
      "_reference_identifier",
      "_type_identifier"
    ]
  ],
  "precedences": [
    [
      {
        "type": "SYMBOL",
        "name": "map_literal"
      },
      {
        "type": "SYMBOL",
        "name": "set_literal"
      }
    ],
    [
      {
        "type": "SYMBOL",
        "name": "json_literal"
      },
      {
        "type": "SYMBOL",
        "name": "structured_access_expression"
      }
    ]
  ],
  "externals": [
    {
      "type": "SYMBOL",
      "name": "AUTOMATIC_SEMICOLON"
    },
    {
      "type": "SYMBOL",
      "name": "AUTOMATIC_BLOCK"
    }
  ],
  "inline": [],
  "supertypes": [
    "expression",
    "_literal"
  ]
}

'
]

{ #category : #properties }
SBWing class >> highlightQuery [

    " https://github.com/winglang/wing/blob/master/src/queries/highlights.scm "
    ^ '; Classes

(custom_type) @type
(class_field 
  name: (identifier) @member
) 
(class_definition 
  name: (identifier) @type
)
(method_definition
  name: (identifier) @function
)
(inflight_method_definition
  name: (identifier) @function
)

; Functions

(keyword_argument_key) @variable.parameter
(call 
  caller: (reference 
  	(nested_identifier 
    	property: (member_identifier) @function.method)) 
)
(call 
  caller: (reference 
  	(reference_identifier) @function.method)
)

; Primitives

[
 (number)
 (duration)
] @constant.builtin
(string) @string
(bool) @constant.builtin
(builtin_type) @type.builtin
(json_container_type) @type.builtin

; Special

(comment) @comment

[
  "("
  ")"
  "{"
  "}"
]  @punctuation.bracket

[
  "-"
  "+"
  "*"
  "/"
  "%"
  "<"
  "<="
  "="
  "=="
  "!"
  "!="
  ">"
  ">="
  "&&"
  "??"
  "||"
] @operator

[
  ";"
  "."
  ","
] @punctuation.delimiter

[
  "as"
  "bring"
  "class"
  "else"
  "for"
  "if"
  "in"
  "init"
  "let"
  "new"
  "return"
  (inflight_specifier)
] @keyword

(identifier) @variable
(reference_identifier) @variable
(member_identifier) @property'
]

{ #category : #'as yet unclassified' }
SBWing class >> icon [

	^ Form
		extent: 16 @ 16
		depth: 32
		fromArray: #(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1166057375 1166057375 1166057375 1166057375 897621919 109093024 0 0 0 0 109093024 847290271 1166057375 1166057375 1166057375 1166057375 4202667935 4202667935 4202667935 4202667935 4152336287 2894110880 276865184 0 0 276865184 2827002016 4152336287 4202667935 4202667935 4202667935 4202667935 3095371679 4236222367 4219445151 2810159007 3581910943 4252999583 2189402015 41983903 41983903 2256510879 4252999583 3649019807 2759827359 4169113503 4252999583 3212812191 243310752 3179257759 4219445151 1468047520 679518111 3867123615 3917455263 444637087 511745951 3967786911 3984564127 696295327 1451270304 4219445151 3229589407 192979104 0 1249943712 4202667935 2994708383 125870240 2340462495 4252999583 1971298207 1954520991 4236222367 2407571359 125869983 3011485599 4202667935 1300275360 0 0 226533279 3598688159 4068450207 696295327 880844703 4152336287 3414138783 3414138783 4152336287 931176608 645963679 4118781855 3598688159 176201888 0 0 25206687 2273288095 4252999583 1971298207 142647199 3296698271 4269776799 4269776799 3246366623 125870240 2038407071 4252999583 2256510879 25206687 0 0 0 763404191 4135559071 3531579295 243310752 1786814367 4252999583 4252999583 1887412127 327196575 3716128671 4118781855 713072543 0 0 0 0 75538335 2860490655 4236222367 2290065311 1803591583 4219445151 4219445151 1686151328 2357174175 4252999583 2860490655 92315808 0 0 0 0 0 696295327 3816791967 4236222367 4219445151 4219445151 4219445151 4202667935 4236222367 3867123615 713072543 0 0 0 0 0 0 25206944 864067487 2659164063 2977931167 1501601952 1384161440 2910822303 2776604575 830513055 25206944 0 0 0 0 0 0 0 0 58761119 75538335 0 0 75538335 75538335 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
		offset: 0 @ 0
]

{ #category : #'configuration - editing' }
SBWing class >> isBlockInlined: aSymbol [

	^ aSymbol = #'expression_statement' or: [(super isBlockInlined: aSymbol) or: [aSymbol = #reference or: [aSymbol = #'positional_argument']]]
]

{ #category : #'configuration - declarations' }
SBWing class >> isIdentifier: aBlock [

	^ (super isIdentifier: aBlock) or: [aBlock alias = 'reference_identifier']
]

{ #category : #configuration }
SBWing class >> language [

    ^ #wing
]

{ #category : #configuration }
SBWing class >> preprocessGrammar: aGrammar [

	super preprocessGrammar: aGrammar.
	
	aGrammar removeRule: 'AUTOMATIC_SEMICOLON'.
	
	aGrammar rules
		at: 'AUTOMATIC_BLOCK'
		put: (SBTSNodeSymbol new type: '_statement' factory: aGrammar).
	aGrammar inlinedRules add: 'AUTOMATIC_BLOCK'.
	
	aGrammar rules at: 'argument_list' put: (SBTSNodeSeq new
		elements: {
			SBTSNodeLabel new
				label: '(';
				factory: aGrammar.
			SBTSNodeRepeat new
				delimiter: ',';
				multiple: true required: false element: (SBTSNodeChoice new
					alternatives: {
						SBTSNodeSymbol new type: 'positional_argument' factory: aGrammar.
						SBTSNodeSymbol new type: 'keyword_argument' factory: aGrammar};
					factory: aGrammar);
				factory: aGrammar.
			SBTSNodeLabel new
				label: ')';
				factory: aGrammar};
		factory: aGrammar)
]

{ #category : #configuration }
SBWing class >> rootRuleName [

    ^ 'source'
]

{ #category : #configuration }
SBWing class >> shouldSkipParsing: aTypeString cursor: aCursor [

	^ (super shouldSkipParsing: aTypeString cursor: aCursor) or: [aTypeString = 'AUTOMATIC_SEMICOLON']
]

{ #category : #'configuration - layout' }
SBWing class >> softLineBreakBetween: aBlock and: anotherBlock [

	anotherBlock contents = '=' ifTrue: [^ false].
	(aBlock contents = ':' and: [aBlock isTextMorph]) ifTrue: [^ false].
	(aBlock contents = '{' or: [anotherBlock contents = '}']) ifTrue: [^ true].
	anotherBlock contents = '=>' ifTrue: [^ false].
	^ super softLineBreakBetween: aBlock and: anotherBlock
]

{ #category : #configuration }
SBWing class >> statementTerminator [

	^ ';'
]
