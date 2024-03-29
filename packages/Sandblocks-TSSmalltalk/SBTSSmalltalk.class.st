Class {
	#name : #SBTSSmalltalk,
	#superclass : #SBTSLanguage,
	#category : #'Sandblocks-TSSmalltalk'
}

{ #category : #'configuration - layout' }
SBTSSmalltalk class >> addIndent: aBlock [

	(super addIndent: aBlock) ifTrue: [^ true].
	aBlock field = #receiver ifTrue: [^ true].
	^ false
]

{ #category : #'configuration - declarations' }
SBTSSmalltalk class >> declarationsInScope: aScopeBlock do: aClosure [

	aScopeBlock childSandblocks do: [:block |
		block type = #'block_argument' ifTrue: [aClosure value: (SBTSDeclaration block: block selector: block contents allButFirst label: 'block arg')].
		block type = #temporaries ifTrue: [block childSandblocks do: [:temp | aClosure value: (SBTSDeclaration block: temp label: 'temporary')]].
		(#(#'binary_selector' #'keyword_selector') includes: block type) ifTrue: [(block childSandblocks select: [:arg | arg type = #identifier]) do: [:arg | aClosure value: (SBTSDeclaration block: arg label: 'argument')]]]
]

{ #category : #configuration }
SBTSSmalltalk class >> defaultRuntimeClass [

	^ SBStSqueakRuntime
]

{ #category : #configuration }
SBTSSmalltalk class >> expressionTypes [

	^ #(#expression)
]

{ #category : #configuration }
SBTSSmalltalk class >> fileSuffix [

	^ 'st'
]

{ #category : #configuration }
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
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "pragma"
          }
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
      "type": "ALIAS",
      "content": {
        "type": "SYMBOL",
        "name": "identifier"
      },
      "named": true,
      "value": "unary_identifier"
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
            "type": "FIELD",
            "name": "receiver",
            "content": {
              "type": "SYMBOL",
              "name": "expression"
            }
          },
          {
            "type": "ALIAS",
            "content": {
              "type": "SYMBOL",
              "name": "identifier"
            },
            "named": true,
            "value": "unary_identifier"
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
            "type": "FIELD",
            "name": "receiver",
            "content": {
              "type": "SYMBOL",
              "name": "expression"
            }
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
      "type": "PREC",
      "value": -1,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "FIELD",
            "name": "receiver",
            "content": {
              "type": "SYMBOL",
              "name": "expression"
            }
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
      "value": -10,
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
    "cascade": {
      "type": "PREC",
      "value": -2,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "FIELD",
            "name": "receiver",
            "content": {
              "type": "SYMBOL",
              "name": "expression"
            }
          },
          {
            "type": "REPEAT1",
            "content": {
              "type": "SEQ",
              "members": [
                {
                  "type": "STRING",
                  "value": ";"
                },
                {
                  "type": "SYMBOL",
                  "name": "_cascaded_send"
                }
              ]
            }
          }
        ]
      }
    },
    "_cascaded_send": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "cascaded_unary_message"
        },
        {
          "type": "SYMBOL",
          "name": "cascaded_binary_message"
        },
        {
          "type": "SYMBOL",
          "name": "cascaded_keyword_message"
        }
      ]
    },
    "cascaded_unary_message": {
      "type": "PREC",
      "value": -2,
      "content": {
        "type": "SYMBOL",
        "name": "identifier"
      }
    },
    "cascaded_binary_message": {
      "type": "PREC",
      "value": -3,
      "content": {
        "type": "SEQ",
        "members": [
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
    "cascaded_keyword_message": {
      "type": "PREC",
      "value": -4,
      "content": {
        "type": "REPEAT1",
        "content": {
          "type": "SYMBOL",
          "name": "keyword_part"
        }
      }
    },
    "keyword": {
      "type": "PATTERN",
      "value": "[A-Za-z_]+:"
    },
    "number": {
      "type": "PATTERN",
      "value": "[0-9]+\\.[0-9]+|([0-9]+r)?[0-9]+"
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
      "value": "[A-Za-z_][A-Za-z0-9_]*"
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
    "literal_array": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "#("
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_literal_array_element"
          }
        },
        {
          "type": "STRING",
          "value": ")"
        }
      ]
    },
    "_literal_array_element": {
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
          "name": "character"
        },
        {
          "type": "SYMBOL",
          "name": "nil"
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
          "type": "ALIAS",
          "content": {
            "type": "SYMBOL",
            "name": "binary_operator"
          },
          "named": true,
          "value": "symbol"
        },
        {
          "type": "ALIAS",
          "content": {
            "type": "PATTERN",
            "value": "\\."
          },
          "named": true,
          "value": "symbol"
        },
        {
          "type": "ALIAS",
          "content": {
            "type": "STRING",
            "value": ":="
          },
          "named": true,
          "value": "symbol"
        },
        {
          "type": "ALIAS",
          "content": {
            "type": "STRING",
            "value": "^"
          },
          "named": true,
          "value": "symbol"
        },
        {
          "type": "ALIAS",
          "content": {
            "type": "SYMBOL",
            "name": "identifier"
          },
          "named": true,
          "value": "symbol"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "ALIAS",
              "content": {
                "type": "SYMBOL",
                "name": "nested_array_literal"
              },
              "named": true,
              "value": "literal_array"
            },
            {
              "type": "SYMBOL",
              "name": "literal_array"
            }
          ]
        }
      ]
    },
    "nested_array_literal": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "("
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_literal_array_element"
          }
        },
        {
          "type": "STRING",
          "value": ")"
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
          "name": "literal_array"
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
          "name": "cascade"
        },
        {
          "type": "SYMBOL",
          "name": "primary"
        }
      ]
    },
    "pragma": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "<"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "pragma_unary_selector"
            },
            {
              "type": "SYMBOL",
              "name": "pragma_binary_selector"
            },
            {
              "type": "SYMBOL",
              "name": "pragma_keyword_selector"
            }
          ]
        },
        {
          "type": "STRING",
          "value": ">"
        }
      ]
    },
    "pragma_unary_selector": {
      "type": "ALIAS",
      "content": {
        "type": "SYMBOL",
        "name": "identifier"
      },
      "named": true,
      "value": "unary_identifier"
    },
    "pragma_binary_selector": {
      "type": "SEQ",
      "members": [
        {
          "type": "SYMBOL",
          "name": "binary_operator"
        },
        {
          "type": "SYMBOL",
          "name": "expression"
        }
      ]
    },
    "pragma_keyword_selector": {
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
            "value": "\""
          },
          {
            "type": "PATTERN",
            "value": "[^\"]*"
          },
          {
            "type": "STRING",
            "value": "\""
          }
        ]
      }
    }
  },
  "extras": [
    {
      "type": "SYMBOL",
      "name": "comment"
    },
    {
      "type": "PATTERN",
      "value": "[\\s]"
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

{ #category : #'configuration - layout' }
SBTSSmalltalk class >> hardLineBreakBetween: aBlock and: anotherBlock [

	(aBlock slot lastNode type = #statement and: [anotherBlock slot lastNode type = #statement]) ifTrue: [^ true].
	(anotherBlock slot lastNode type = #statement and: [(anotherBlock owner submorphs count: [:m | m slot lastNode type = #statement]) > 1]) ifTrue: [^ true].
	(aBlock parentSandblock ifNotNil: #type) = #method ifTrue: [^ true].
	^ false
]

{ #category : #configuration }
SBTSSmalltalk class >> highlightQuery [
	" https://github.com/smalltalk/blob/master/src/queries/highlights.scm "

	^ '[(self) (true) (false) (thisContext) (super) (nil)] @keyword

(number) @number

(string) @string
(symbol) @string
(character) @string

(identifier) @variable
(block_argument) @variable

(unary_message (_) (unary_identifier) @variable.part)
(binary_operator) @variable.part
(keyword) @variable.part

["^" "[" "]" "{" "}"] @important

(keyword_selector (keyword) @major_declaration)
(binary_selector (binary_operator) @major_declaration)
(unary_selector (unary_identifier) @major_declaration)'
]

{ #category : #configuration }
SBTSSmalltalk class >> icon [

	^ SBStASTNode icon
]

{ #category : #'configuration - editing' }
SBTSSmalltalk class >> isBlockInlined: aSymbol [

	^ aSymbol = #statement or: [super isBlockInlined: aSymbol]
]

{ #category : #configuration }
SBTSSmalltalk class >> isExpression: aBlock [

	^ #expression = aBlock type
]

{ #category : #'configuration - editing' }
SBTSSmalltalk class >> isImmutableLabel: aLabelNode [

	^ (super isImmutableLabel: aLabelNode) or: [#('|') includes: aLabelNode label]
]

{ #category : #'configuration - editing' }
SBTSSmalltalk class >> isStatementContainer: aRepeatNode in: aBlock [

	^ aRepeatNode element type = 'statement'
]

{ #category : #configuration }
SBTSSmalltalk class >> language [

	^ #smalltalk
]

{ #category : #'configuration - suggestions' }
SBTSSmalltalk class >> lowercaseSuggestionsFor: aBlock [

	^ Array streamContents: [:stream |
		self
			scopesAround: aBlock
			do: [:scope :declarations | declarations do: [:decl | (decl contents sandblockMatch: aBlock contents) ifTrue: [stream nextPut: decl]]]]
]

{ #category : #configuration }
SBTSSmalltalk class >> rootRuleName [

	^ 'method'
]

{ #category : #'configuration - layout' }
SBTSSmalltalk class >> softLineBreakBetween: aBlock and: anotherBlock [

	aBlock type = #'block_argument' ifTrue: [^ false].
	(super softLineBreakBetween: aBlock and: anotherBlock) ifTrue: [^ true].
	aBlock field = #receiver ifTrue: [^ true].
	anotherBlock type = #keyword ifTrue: [^ true].
	^ false
]

{ #category : #'configuration - suggestions' }
SBTSSmalltalk class >> suggestionsFor: aBlock [

	((aBlock alias = #'unary_identifier' and: [aBlock parentSandblock type = #'unary_message']) or: [aBlock type = #keyword]) ifTrue: [
		^ (aBlock sortedSuggestions: (OrderedCollection withAll: Symbol allSymbols) for: aBlock contents) collect: [:item |
			SBSuggestionItem
				selector: (item keywords joinSeparatedBy: (Character value: 1))
				label: 'send']].
	aBlock type = #identifier ifTrue: [
		^ aBlock
			sortedSuggestions: (aBlock contents first isUppercase
				ifTrue: [self uppercaseSuggestionsFor: aBlock]
				ifFalse: [self lowercaseSuggestionsFor: aBlock])
			for: aBlock contents].
	^ #()
]

{ #category : #'configuration - editing' }
SBTSSmalltalk class >> transitionPairs [

	^ {#'unary_message' -> #'keyword_message'}
]

{ #category : #'configuration - suggestions' }
SBTSSmalltalk class >> uppercaseSuggestionsFor: aBlock [

	self flag: #todo.
	"pool dict etc"
	^ Array streamContents: [:stream |
		Smalltalk globals keysAndValuesDo: [:key :value |
			(key sandblockMatch: aBlock contents) ifTrue: [
				stream nextPut: (SBSuggestionItem selector: key label: ((value isBehavior and: [key == value name])
					ifTrue: ['class']
					ifFalse: ['global']))]]]
]

{ #category : #'as yet unclassified' }
SBTSSmalltalk >> addIndent: aBlock [

	(aBlock submorphIndex = 1 and: [aBlock owner type = 'keyword_message']) ifTrue: [^ true].
	(aBlock contents = '[' and: [aBlock containingSandblock type = 'block']) ifTrue: [^ true].
	(aBlock contents = ';' and: [aBlock submorphIndex = 2]) ifTrue: [^ true].
	^ super addIndent: aBlock
]

{ #category : #'as yet unclassified' }
SBTSSmalltalk >> declarationsInScope: aScopeBlock do: aClosure [

	aScopeBlock childSandblocks do: [:block |
		block type = #'block_argument' ifTrue: [aClosure value: (SBTSDeclaration block: block selector: block contents allButFirst label: 'block arg')].
		block type = #temporaries ifTrue: [block childSandblocks do: [:temp | aClosure value: (SBTSDeclaration block: temp label: 'temporary')]].
		(#(#'binary_selector' #'keyword_selector') includes: block type) ifTrue: [(block childSandblocks select: [:arg | arg type = #identifier]) do: [:arg | aClosure value: (SBTSDeclaration block: arg label: 'argument')]]]
]

{ #category : #'as yet unclassified' }
SBTSSmalltalk >> hardLineBreakBetween: aBlock and: anotherBlock [

	aBlock parentSandblock type = 'block' ifTrue: [^ aBlock parentSandblock childSandblocks size > 1 and: [anotherBlock contents ~= ']']].
	aBlock contents = ';' ifTrue: [^ true].
	(super hardLineBreakBetween: aBlock and: anotherBlock) ifTrue: [^ true].
	^ false
]

{ #category : #'as yet unclassified' }
SBTSSmalltalk >> hardLineBreakMatchBetween: aBlock and: anotherBlock [

	^ aBlock parentSandblock type = 'method'
]

{ #category : #'as yet unclassified' }
SBTSSmalltalk >> isExpression: aBlock [

	^ #expression = aBlock type
]

{ #category : #'as yet unclassified' }
SBTSSmalltalk >> lowercaseSuggestionsFor: aBlock [

	^ Array streamContents: [:stream |
		self
			scopesAround: aBlock
			do: [:scope :declarations | declarations do: [:decl | (decl contents sandblockMatch: aBlock contents) ifTrue: [stream nextPut: decl]]]]
]

{ #category : #'as yet unclassified' }
SBTSSmalltalk >> postConfigure [

	self blockInline: #('statement').
	self noteUncapturedText: #('symbol' 'string')
]

{ #category : #'as yet unclassified' }
SBTSSmalltalk >> removeIndent: aBlock [

	(aBlock contents = ']' and: [aBlock containingSandblock type = 'block']) ifTrue: [^ true].
	^ super removeIndent: aBlock
]

{ #category : #'as yet unclassified' }
SBTSSmalltalk >> softLineBreakBetween: aBlock and: anotherBlock [

	(super softLineBreakBetween: aBlock and: anotherBlock) ifTrue: [^ true].
	anotherBlock type = 'keyword' ifTrue: [^ true].
	^ false
]

{ #category : #'as yet unclassified' }
SBTSSmalltalk >> suggestionsFor: aBlock [

	((aBlock type = #identifier and: [aBlock parentSandblock type = #'unary_message']) or: [aBlock type = #keyword]) ifTrue: [
		^ (aBlock sortedSuggestions: (OrderedCollection withAll: Symbol allSymbols) for: aBlock contents) collect: [:item |
			SBSuggestionItem
				selector: (item keywords joinSeparatedBy: (Character value: 1))
				label: 'send']].
	aBlock type = #identifier ifTrue: [
		^ aBlock
			sortedSuggestions: (aBlock contents first isUppercase
				ifTrue: [self uppercaseSuggestionsFor: aBlock]
				ifFalse: [self lowercaseSuggestionsFor: aBlock])
			for: aBlock contents].
	^ #()
]

{ #category : #'as yet unclassified' }
SBTSSmalltalk >> transitionPairs [

	^ {#'unary_message' -> #'keyword_message'}
]

{ #category : #'as yet unclassified' }
SBTSSmalltalk >> uppercaseSuggestionsFor: aBlock [

	self flag: #todo.
	"pool dict etc"
	^ Array streamContents: [:stream |
		Smalltalk globals keysAndValuesDo: [:key :value |
			(key sandblockMatch: aBlock contents) ifTrue: [
				stream nextPut: (SBSuggestionItem selector: key label: ((value isBehavior and: [key == value name])
					ifTrue: ['class']
					ifFalse: ['global']))]]]
]
