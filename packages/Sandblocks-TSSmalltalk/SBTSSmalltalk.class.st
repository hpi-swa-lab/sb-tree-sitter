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

{ #category : #'configuration - suggestions' }
SBTSSmalltalk class >> allSuggestionOptionsFor: aBlock [

	| guessedClass |
	guessedClass := aBlock type
		caseOf: {
			[#number] -> [(aBlock contents includes: $.) ifTrue: [Float] ifFalse: [Integer]].
			[#string] -> [String].
			[#'literal_array'] -> [Array].
			[#'dynamic_array'] -> [Array].
			[#'byte_array'] -> [ByteArray].
			[#character] -> [Character].
			[#assignment] -> [^ self allSuggestionOptionsFor: aBlock childSandblocks last].
			[#'parenthesized_expression'] -> [^ self allSuggestionOptionsFor: aBlock childSandblocks first].
			[#self] -> [nil].
			[#super] -> [nil].
			[#nil] -> [UndefinedObject].
			[#thisContext] -> [Context].
			[#block] -> [BlockClosure].
			[#identifier] -> [(Symbol lookup: aBlock contents) ifNotNil: [:sym | Smalltalk at: sym ifPresent: [:obj | obj class] ifAbsent: [nil]]]}
		otherwise: [nil].
	
	^ guessedClass
		ifNil: [OrderedCollection withAll: Symbol allSymbols]
		ifNotNil: [Array streamContents: [:stream | guessedClass withAllSuperclassesDo: [:class | stream nextPutAll: class selectors]]]
]

{ #category : #'configuration - editing' }
SBTSSmalltalk class >> blockBodyTypes [

	^ {#block. #method}
]

{ #category : #'configuration - declarations' }
SBTSSmalltalk class >> declarationsInScope: aScopeBlock do: aClosure [

	(aScopeBlock type = #method and: [aScopeBlock parentSandblock isMethod]) ifTrue: [
		aScopeBlock parentSandblock methodClass instVarNames do: [:name |
			aClosure value: (SBTSDeclaration
				block: ((self blockFor: #identifier)
					contents: name;
					yourself)
				label: 'inst var')]].
	
	aScopeBlock childSandblocks do: [:block |
		block type = #'block_argument' ifTrue: [aClosure value: (SBTSDeclaration block: block selector: block contents allButFirst label: 'block arg')].
		block type = #temporaries ifTrue: [block childSandblocks do: [:temp | aClosure value: (SBTSDeclaration block: temp label: 'temporary')]].
		(#(#'binary_selector' #'keyword_selector') includes: block type) ifTrue: [(block allBlocksSelect: [:arg | arg isTSMorph and: [arg type = #identifier]]) do: [:arg | aClosure value: (SBTSDeclaration block: arg label: 'argument')]]].
	
	{
		self blockFor: #self.
		self blockFor: #super.
		self blockFor: #thisContext.
		self blockFor: #true.
		self blockFor: #false.
		self blockFor: #nil} do: [:block | aClosure value: (SBTSDeclaration block: block label: 'keyword')]
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

{ #category : #'configuration - layout' }
SBTSSmalltalk class >> gapBetween: aBlock and: anotherBlock [

	anotherBlock type = #'block_argument' ifTrue: [^ true].
	aBlock treeLabel = '#' ifTrue: [^ false].
	aBlock parentSandblock type = 'pragma' ifTrue: [^ false].
	anotherBlock type = 'ERROR' ifTrue: [^ false].
	^ super gapBetween: aBlock and: anotherBlock
]

{ #category : #properties }
SBTSSmalltalk class >> grammarJson [

    " https://github.com/smalltalk/blob/master/src/grammar.json "
    ^ '{
  "name": "smalltalk",
  "rules": {
    "method": {
      "type": "SEQ",
      "members": [
        {
          "type": "SYMBOL",
          "name": "selector"
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "pragma"
              },
              {
                "type": "SYMBOL",
                "name": "temporaries"
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
      "value": -5,
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
        "type": "ALIAS",
        "content": {
          "type": "SYMBOL",
          "name": "identifier"
        },
        "named": true,
        "value": "unary_identifier"
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
      "value": "[A-Za-z_][A-Za-z0-9_]*:"
    },
    "number": {
      "type": "PATTERN",
      "value": "-?[0-9]+\\.[0-9]+|-?([0-9]+r)?[0-9]+"
    },
    "string": {
      "type": "TOKEN",
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "STRING",
            "value": "''"
          },
          {
            "type": "PATTERN",
            "value": "([^'']|'''')*"
          },
          {
            "type": "STRING",
            "value": "''"
          }
        ]
      }
    },
    "symbol": {
      "type": "TOKEN",
      "content": {
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
                "value": "[A-Za-z0-9_:]+|[-+\\\\/*~<>=@,%|&?!]+"
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
      }
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
      "value": "[-+\\\\/*~<>=@,%|&?!]+"
    },
    "identifier_or_keyword": {
      "type": "TOKEN",
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "PATTERN",
            "value": "[A-Za-z_][A-Za-z0-9_]*"
          },
          {
            "type": "PATTERN",
            "value": ":?"
          }
        ]
      }
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
          "type": "SYMBOL",
          "name": "symbol"
        },
        {
          "type": "ALIAS",
          "content": {
            "type": "PATTERN",
            "value": "[A-Za-z0-9_:]+|[-+\\\\/*~<>=@,%|&?!]+"
          },
          "named": true,
          "value": "symbol"
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
      "value": ": *[A-Za-z_][A-Za-z0-9_]*"
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
            "name": "primary"
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
      "value": "[\\s\\f]"
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

	(#(')' ']' '}') includes: anotherBlock treeLabel) ifTrue: [^ false].
	aBlock type = 'pragma' ifTrue: [^ true].
	aBlock contents = '.' ifTrue: [^ true].
	anotherBlock type = 'ERROR' ifTrue: [^ false].
	anotherBlock contents = '.' ifTrue: [^ false].
	(({#statement. #empty. #comment} includes: aBlock slot lastNode type) and: [{#statement. #empty. #comment. #temporaries} includes: anotherBlock slot lastNode type]) ifTrue: [^ true].
	aBlock contents = ';' ifTrue: [^ true].
	aBlock contents = '[' ifTrue: [^ false].
	(({#statement. #empty. #comment} includes: anotherBlock slot lastNode type) and: [(anotherBlock owner submorphs count: [:m | m slot lastNode type = #statement]) > 1]) ifTrue: [^ true].
	SBToggledCode
		comment: ''
		active: 0
		do: {[(aBlock parentSandblock ifNotNil: #type) = #method ifTrue: [^ true]]}.
	(#(#'keyword_selector' #'unary_selector' #'binary_selector') includes: aBlock type) ifTrue: [^ true].
	((aBlock slot isStatementIn: aBlock parentSandblock) and: [aBlock ~= aBlock parentSandblock childSandblocks last]) ifTrue: [^ true].
	(aBlock field = 'receiver' and: [(aBlock parentNode ifNotNil: [:p | p parentNode ifNotNil: [:p2 | p2 type = #cascade]]) ifNil: [false]]) ifTrue: [^ true].
	^ false
]

{ #category : #properties }
SBTSSmalltalk class >> highlightQuery [
	" https://github.com/smalltalk/blob/master/src/queries/highlights.scm "

	^ '[(self) (true) (false) (thisContext) (super) (nil)] @keyword

(pragma) @annotation
(pragma (unary_identifier) @structure.part)

(number) @number

(string) @string
(symbol) @string
(character) @string
(comment) @comment
(block "|" @punctuation)

(identifier) @variable
(block_argument) @variable

";" @punctuation
"." @punctuation

(unary_message (_) (unary_identifier) @variable.part)
(binary_operator) @variable.part
(keyword) @variable.part

["^" "[" "]" "{" "}"] @important

["(" ")"] @punctuation

(keyword_selector (keyword) @major_declaration.part) @structure.part
(binary_selector (binary_operator) @major_declaration.part) @structure.part
(unary_selector (unary_identifier) @major_declaration.part) @structure.part

[(pragma_keyword_selector) (pragma_unary_selector) (pragma_binary_selector)] @structure.part

(temporaries) @punctuation.part
(temporaries (identifier) @punctuation)'
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

	^ aRepeatNode element type = #statement
]

{ #category : #'as yet unclassified' }
SBTSSmalltalk class >> isStatementTerminatorBetween [

	^ true
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

{ #category : #'configuration - editing' }
SBTSSmalltalk class >> preferNoPopup [

	^ true
]

{ #category : #properties }
SBTSSmalltalk class >> repo [

	^ {'tom95/tree-sitter-smalltalk'. 'main'. ''}
]

{ #category : #configuration }
SBTSSmalltalk class >> rootRuleName [

	^ 'method'
]

{ #category : #'configuration - layout' }
SBTSSmalltalk class >> softLineBreakBetween: aBlock and: anotherBlock [

	(#(')' ']' '}') includes: anotherBlock treeLabel) ifTrue: [^ false].
	anotherBlock type = 'ERROR' ifTrue: [^ false].
	aBlock type = #'block_argument' ifTrue: [^ false].
	anotherBlock contents = '.' ifTrue: [^ false].
	anotherBlock contents = ';' ifTrue: [^ false].
	aBlock treeLabel = '[' ifTrue: [^ false].
	anotherBlock contents = ']' ifTrue: [^ false].
	aBlock type = #keyword ifTrue: [^ false].
	(super softLineBreakBetween: aBlock and: anotherBlock) ifTrue: [^ true].
	aBlock field = #receiver ifTrue: [^ true].
	anotherBlock type = #keyword ifTrue: [^ true].
	^ false
]

{ #category : #'configuration - layout' }
SBTSSmalltalk class >> spaceBetween: aBlock and: anotherBlock lastCharacterOfFirst: aCharacter [

	(aBlock type = 'string' and: [anotherBlock type = 'string']) ifTrue: [^ true].
	anotherBlock type = #'block_argument' ifTrue: [^ true].
	aCharacter = $: ifTrue: [^ true].
	(anotherBlock type = 'ERROR' and: [
		anotherBlock firstDeepChild contents
			ifNotEmpty: [:e | e first isLetter not]
			ifEmpty: [false]]) ifTrue: [^ false].
	(aBlock contents = ':=' or: [anotherBlock contents = ':=']) ifTrue: [^ true].
	anotherBlock alias = #'unary_identifier' ifTrue: [^ true].
	^ super spaceBetween: aBlock and: anotherBlock lastCharacterOfFirst: aCharacter
]

{ #category : #configuration }
SBTSSmalltalk class >> statementTerminator [

	^ '.'
]

{ #category : #'configuration - suggestions' }
SBTSSmalltalk class >> suggestionsFor: aBlock [

	aBlock type = #symbol ifTrue: [
		^ (aBlock
			sortedSuggestions: (OrderedCollection withAll: Symbol allSymbols)
			for: aBlock textMorphs second contents) collect: [:item | SBSuggestionItem selector: item label: 'symbol']].
	((aBlock alias = #'unary_identifier' and: [aBlock parentSandblock type = #'unary_message']) or: [aBlock type = #keyword]) ifTrue: [
		^ (aBlock
			sortedSuggestions: (self allSuggestionOptionsFor: aBlock parentSandblock childSandblocks first)
			for: aBlock contents) collect: [:item |
			SBSuggestionItem
				selector: (item keywords joinSeparatedBy: SBTSInputParser gapCharacter)
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

	^ {
		#'unary_message' -> #'keyword_message'.
		#'cascaded_unary_message' -> #'cascaded_keyword_message'.
		#'unary_selector' -> #'keyword_selector'}
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
