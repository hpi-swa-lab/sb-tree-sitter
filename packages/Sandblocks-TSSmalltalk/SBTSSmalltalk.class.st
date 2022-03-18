Class {
	#name : #SBTSSmalltalk,
	#superclass : #SBGrammarLanguage,
	#category : #'Sandblocks-TSSmalltalk'
}

{ #category : #properties }
SBTSSmalltalk class >> grammarJson [

    " https://github.com/smalltalk/blob/master/src/grammar.json "
    ^ '{
  "name": "smalltalk",
  "word": "keyword",
  "rules": {
    "method": {
      "type": "SEQ",
      "members": [
        {
          "type": "SYMBOL",
          "name": "selector"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "temporaries"
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
                      "type": "SYMBOL",
                      "name": "statement"
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
                        "value": "."
                      },
                      {
                        "type": "CHOICE",
                        "members": [
                          {
                            "type": "SYMBOL",
                            "name": "statement"
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
        }
      ]
    },
    "temporaries": {
      "type": "PREC_DYNAMIC",
      "value": 10,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "STRING",
            "value": "|"
          },
          {
            "type": "REPEAT",
            "content": {
              "type": "SYMBOL",
              "name": "identifier"
            }
          },
          {
            "type": "STRING",
            "value": "|"
          }
        ]
      }
    },
    "selector": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "unary_selector"
        },
        {
          "type": "SYMBOL",
          "name": "binary_selector"
        },
        {
          "type": "SYMBOL",
          "name": "keyword_selector"
        }
      ]
    },
    "unary_selector": {
      "type": "SYMBOL",
      "name": "identifier"
    },
    "binary_selector": {
      "type": "SEQ",
      "members": [
        {
          "type": "SYMBOL",
          "name": "binary_operator"
        },
        {
          "type": "SYMBOL",
          "name": "identifier"
        }
      ]
    },
    "keyword_selector": {
      "type": "REPEAT1",
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "SYMBOL",
            "name": "keyword"
          },
          {
            "type": "SYMBOL",
            "name": "identifier"
          }
        ]
      }
    },
    "unary_message": {
      "type": "PREC",
      "value": 4,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "SYMBOL",
            "name": "expression"
          },
          {
            "type": "SYMBOL",
            "name": "identifier"
          }
        ]
      }
    },
    "binary_message": {
      "type": "PREC_LEFT",
      "value": 3,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "SYMBOL",
            "name": "expression"
          },
          {
            "type": "SYMBOL",
            "name": "binary_operator"
          },
          {
            "type": "SYMBOL",
            "name": "expression"
          }
        ]
      }
    },
    "keyword_message": {
      "type": "PREC_DYNAMIC",
      "value": -1,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "SYMBOL",
            "name": "expression"
          },
          {
            "type": "REPEAT1",
            "content": {
              "type": "SYMBOL",
              "name": "keyword_part"
            }
          }
        ]
      }
    },
    "keyword_part": {
      "type": "SEQ",
      "members": [
        {
          "type": "SYMBOL",
          "name": "keyword"
        },
        {
          "type": "SYMBOL",
          "name": "expression"
        }
      ]
    },
    "assignment": {
      "type": "PREC_LEFT",
      "value": -2,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "SYMBOL",
            "name": "identifier"
          },
          {
            "type": "STRING",
            "value": ":="
          },
          {
            "type": "SYMBOL",
            "name": "expression"
          }
        ]
      }
    },
    "keyword": {
      "type": "PATTERN",
      "value": "[A-Za-z_]+:"
    },
    "number": {
      "type": "PATTERN",
      "value": "([0-9]+r)?[0-9]+"
    },
    "string": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "''"
        },
        {
          "type": "PATTERN",
          "value": "[^'']*"
        },
        {
          "type": "STRING",
          "value": "''"
        }
      ]
    },
    "symbol": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "#"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "PATTERN",
              "value": "[A-Za-z0-9_:]+|[+\\-/*~<>=@,%|&?!]+"
            },
            {
              "type": "SEQ",
              "members": [
                {
                  "type": "STRING",
                  "value": "''"
                },
                {
                  "type": "PATTERN",
                  "value": "[^'']*"
                },
                {
                  "type": "STRING",
                  "value": "''"
                }
              ]
            }
          ]
        }
      ]
    },
    "character": {
      "type": "PATTERN",
      "value": "\\$(\\s|.)"
    },
    "identifier": {
      "type": "PATTERN",
      "value": "[A-Za-z_]+"
    },
    "binary_operator": {
      "type": "PATTERN",
      "value": "[+\\-/*~<>=@,%|&?!]+"
    },
    "statement": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "expression"
        },
        {
          "type": "SYMBOL",
          "name": "return"
        }
      ]
    },
    "return": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "^"
        },
        {
          "type": "SYMBOL",
          "name": "expression"
        }
      ]
    },
    "dynamic_array": {
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
                        "value": "."
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
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "STRING",
              "value": "."
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
    "byte_array": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "#["
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "number"
          }
        },
        {
          "type": "STRING",
          "value": "]"
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
          "name": "expression"
        },
        {
          "type": "STRING",
          "value": ")"
        }
      ]
    },
    "block_argument": {
      "type": "PATTERN",
      "value": ":[A-Za-z_]+"
    },
    "block": {
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
                  "type": "REPEAT",
                  "content": {
                    "type": "SYMBOL",
                    "name": "block_argument"
                  }
                },
                {
                  "type": "STRING",
                  "value": "|"
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
              "type": "SYMBOL",
              "name": "temporaries"
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
                  "name": "statement"
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
                        "name": "statement"
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
              "value": "."
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
    "true": {
      "type": "STRING",
      "value": "true"
    },
    "false": {
      "type": "STRING",
      "value": "false"
    },
    "thisContext": {
      "type": "STRING",
      "value": "thisContext"
    },
    "self": {
      "type": "STRING",
      "value": "self"
    },
    "super": {
      "type": "STRING",
      "value": "super"
    },
    "nil": {
      "type": "STRING",
      "value": "nil"
    },
    "primary": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "identifier"
        },
        {
          "type": "SYMBOL",
          "name": "dynamic_array"
        },
        {
          "type": "SYMBOL",
          "name": "byte_array"
        },
        {
          "type": "SYMBOL",
          "name": "parenthesized_expression"
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
          "name": "character"
        },
        {
          "type": "SYMBOL",
          "name": "symbol"
        },
        {
          "type": "SYMBOL",
          "name": "block"
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
          "name": "thisContext"
        },
        {
          "type": "SYMBOL",
          "name": "self"
        },
        {
          "type": "SYMBOL",
          "name": "super"
        },
        {
          "type": "SYMBOL",
          "name": "nil"
        }
      ]
    },
    "expression": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "unary_message"
        },
        {
          "type": "SYMBOL",
          "name": "assignment"
        },
        {
          "type": "SYMBOL",
          "name": "binary_message"
        },
        {
          "type": "SYMBOL",
          "name": "keyword_message"
        },
        {
          "type": "SYMBOL",
          "name": "primary"
        }
      ]
    }
  },
  "extras": [
    {
      "type": "PATTERN",
      "value": "\\s"
    }
  ],
  "conflicts": [
    [
      "keyword_message",
      "keyword_message"
    ],
    [
      "temporaries",
      "primary"
    ],
    [
      "temporaries",
      "temporaries"
    ]
  ],
  "precedences": [],
  "externals": [],
  "inline": [
    "keyword_part"
  ],
  "supertypes": [
    "selector",
    "expression",
    "primary"
  ]
}

'
]

{ #category : #properties }
SBTSSmalltalk class >> highlightQuery [

    " https://github.com/smalltalk/blob/master/src/queries/highlights.scm "
    ^ '["this" "self" "true" "false" "thisContext" "super" "nil"] @keyword
(number) @number
(string) @string
(identifier) @variable
["^" "[" "]" "{" "}"] @important
'
]

{ #category : #'as yet unclassified' }
SBTSSmalltalk class >> icon [

	^ SBStASTNode icon
]

{ #category : #'as yet unclassified' }
SBTSSmalltalk class >> language [

	^ #smalltalk
]

{ #category : #'as yet unclassified' }
SBTSSmalltalk class >> rootRuleName [

	^ 'method'
]

{ #category : #'as yet unclassified' }
SBTSSmalltalk class >> statementContainerTypes [

	^ #('method' 'block')
]

{ #category : #'as yet unclassified' }
SBTSSmalltalk >> hardLineBreakMatchBetween: aBlock and: anotherBlock [

	^ aBlock parentSandblock type = 'method'
]

{ #category : #'as yet unclassified' }
SBTSSmalltalk >> postConfigure [

	self blockInline: #('statement')
]
