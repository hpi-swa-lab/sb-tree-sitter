"
SBRegex is the Treesitter language for regular expressions (regex).

The SBReBlock class and its subclasses implements verbose replacements for elements of the regex syntax to make regular expressions more easy to read, write and understand. See the comment on that class for more information regarding the design considerations behind the verbose blocks and the structure of the code.

The SBRePalette is a custom palette with the purpose to make the verbose replacements available to the user as well as making all elements of the syntax discoverable.

The Treesitter-Regex grammar does not correspond to a well-known regex dialect. There it the lack of backreferences by number, the \k syntax for named backreferences, the lack of {n,} and {,n} quantifiers and so on. Apart from the \k named backreference, this regex dialect seems to be a subset of JavaScript's regex dialct.
"
Class {
	#name : #SBRegex,
	#superclass : #SBTSLanguage,
	#category : #'Sandblocks-Regex'
}

{ #category : #configuration }
SBRegex class >> grammarJson [
	" https://github.com/tree-sitter/tree-sitter-regex/blob/master/grammar.js "

	^ '{
  "name": "regex",
  "rules": {
    "pattern": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "disjunction"
        },
        {
          "type": "SYMBOL",
          "name": "term"
        }
      ]
    },
    "disjunction": {
      "type": "SEQ",
      "members": [
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "SYMBOL",
              "name": "term"
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "REPEAT1",
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "STRING",
                "value": "|"
              },
              {
                "type": "CHOICE",
                "members": [
                  {
                    "type": "SYMBOL",
                    "name": "term"
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
    "term": {
      "type": "REPEAT1",
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "start_assertion"
              },
              {
                "type": "SYMBOL",
                "name": "end_assertion"
              },
              {
                "type": "SYMBOL",
                "name": "boundary_assertion"
              },
              {
                "type": "SYMBOL",
                "name": "non_boundary_assertion"
              },
              {
                "type": "SYMBOL",
                "name": "lookahead_assertion"
              },
              {
                "type": "SYMBOL",
                "name": "pattern_character"
              },
              {
                "type": "SYMBOL",
                "name": "character_class"
              },
              {
                "type": "SYMBOL",
                "name": "any_character"
              },
              {
                "type": "SYMBOL",
                "name": "decimal_escape"
              },
              {
                "type": "SYMBOL",
                "name": "character_class_escape"
              },
              {
                "type": "SYMBOL",
                "name": "_character_escape"
              },
              {
                "type": "SYMBOL",
                "name": "backreference_escape"
              },
              {
                "type": "SYMBOL",
                "name": "anonymous_capturing_group"
              },
              {
                "type": "SYMBOL",
                "name": "named_capturing_group"
              },
              {
                "type": "SYMBOL",
                "name": "non_capturing_group"
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
                    "type": "SYMBOL",
                    "name": "zero_or_more"
                  },
                  {
                    "type": "SYMBOL",
                    "name": "one_or_more"
                  },
                  {
                    "type": "SYMBOL",
                    "name": "optional"
                  },
                  {
                    "type": "SYMBOL",
                    "name": "count_quantifier"
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
    "any_character": {
      "type": "STRING",
      "value": "."
    },
    "start_assertion": {
      "type": "STRING",
      "value": "^"
    },
    "end_assertion": {
      "type": "STRING",
      "value": "$"
    },
    "boundary_assertion": {
      "type": "STRING",
      "value": "\\b"
    },
    "non_boundary_assertion": {
      "type": "STRING",
      "value": "\\B"
    },
    "lookahead_assertion": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "(?"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "STRING",
              "value": "="
            },
            {
              "type": "STRING",
              "value": "!"
            },
            {
              "type": "STRING",
              "value": "<="
            },
            {
              "type": "STRING",
              "value": "<!"
            }
          ]
        },
        {
          "type": "SYMBOL",
          "name": "pattern"
        },
        {
          "type": "STRING",
          "value": ")"
        }
      ]
    },
    "pattern_character": {
      "type": "PATTERN",
      "value": "[^\\^\\$\\\\\\.\\*\\+\\?\\(\\)\\[\\]\\{\\}\\|\\n]"
    },
    "character_class": {
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
              "type": "STRING",
              "value": "^"
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "class_range"
              },
              {
                "type": "SYMBOL",
                "name": "_class_atom"
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
    "class_range": {
      "type": "PREC_RIGHT",
      "value": 1,
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "SYMBOL",
            "name": "_class_atom"
          },
          {
            "type": "STRING",
            "value": "-"
          },
          {
            "type": "SYMBOL",
            "name": "_class_atom"
          }
        ]
      }
    },
    "_class_atom": {
      "type": "CHOICE",
      "members": [
        {
          "type": "ALIAS",
          "content": {
            "type": "STRING",
            "value": "-"
          },
          "named": true,
          "value": "class_character"
        },
        {
          "type": "SYMBOL",
          "name": "class_character"
        },
        {
          "type": "ALIAS",
          "content": {
            "type": "STRING",
            "value": "\\-"
          },
          "named": true,
          "value": "identity_escape"
        },
        {
          "type": "SYMBOL",
          "name": "character_class_escape"
        },
        {
          "type": "SYMBOL",
          "name": "_character_escape"
        }
      ]
    },
    "class_character": {
      "type": "PATTERN",
      "value": "[^\\\\\\]\\-]"
    },
    "anonymous_capturing_group": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "("
        },
        {
          "type": "SYMBOL",
          "name": "pattern"
        },
        {
          "type": "STRING",
          "value": ")"
        }
      ]
    },
    "named_capturing_group": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "(?<"
        },
        {
          "type": "SYMBOL",
          "name": "group_name"
        },
        {
          "type": "STRING",
          "value": ">"
        },
        {
          "type": "SYMBOL",
          "name": "pattern"
        },
        {
          "type": "STRING",
          "value": ")"
        }
      ]
    },
    "non_capturing_group": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "(?:"
        },
        {
          "type": "SYMBOL",
          "name": "pattern"
        },
        {
          "type": "STRING",
          "value": ")"
        }
      ]
    },
    "zero_or_more": {
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
              "type": "ALIAS",
              "content": {
                "type": "STRING",
                "value": "?"
              },
              "named": true,
              "value": "lazy"
            },
            {
              "type": "BLANK"
            }
          ]
        }
      ]
    },
    "one_or_more": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "+"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "ALIAS",
              "content": {
                "type": "STRING",
                "value": "?"
              },
              "named": true,
              "value": "lazy"
            },
            {
              "type": "BLANK"
            }
          ]
        }
      ]
    },
    "optional": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "?"
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "ALIAS",
              "content": {
                "type": "STRING",
                "value": "?"
              },
              "named": true,
              "value": "lazy"
            },
            {
              "type": "BLANK"
            }
          ]
        }
      ]
    },
    "count_quantifier": {
      "type": "SEQ",
      "members": [
        {
          "type": "SEQ",
          "members": [
            {
              "type": "STRING",
              "value": "{"
            },
            {
              "type": "SEQ",
              "members": [
                {
                  "type": "SYMBOL",
                  "name": "decimal_digits"
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
                          "type": "SYMBOL",
                          "name": "decimal_digits"
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
              "type": "STRING",
              "value": "}"
            }
          ]
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "ALIAS",
              "content": {
                "type": "STRING",
                "value": "?"
              },
              "named": true,
              "value": "lazy"
            },
            {
              "type": "BLANK"
            }
          ]
        }
      ]
    },
    "backreference_escape": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "\\k"
        },
        {
          "type": "SYMBOL",
          "name": "group_name"
        }
      ]
    },
    "decimal_escape": {
      "type": "PATTERN",
      "value": "\\\\[1-9][0-9]+"
    },
    "character_class_escape": {
      "type": "CHOICE",
      "members": [
        {
          "type": "PATTERN",
          "value": "\\\\[dDsSwW]"
        },
        {
          "type": "SEQ",
          "members": [
            {
              "type": "PATTERN",
              "value": "\\\\[pP]"
            },
            {
              "type": "STRING",
              "value": "{"
            },
            {
              "type": "SYMBOL",
              "name": "unicode_property_value_expression"
            },
            {
              "type": "STRING",
              "value": "}"
            }
          ]
        }
      ]
    },
    "unicode_property_value_expression": {
      "type": "SEQ",
      "members": [
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
                    "name": "unicode_property"
                  },
                  "named": true,
                  "value": "unicode_property_name"
                },
                {
                  "type": "STRING",
                  "value": "="
                }
              ]
            },
            {
              "type": "BLANK"
            }
          ]
        },
        {
          "type": "ALIAS",
          "content": {
            "type": "SYMBOL",
            "name": "unicode_property"
          },
          "named": true,
          "value": "unicode_property_value"
        }
      ]
    },
    "unicode_property": {
      "type": "PATTERN",
      "value": "[a-zA-Z_0-9]+"
    },
    "_character_escape": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "control_escape"
        },
        {
          "type": "SYMBOL",
          "name": "control_letter_escape"
        },
        {
          "type": "SYMBOL",
          "name": "identity_escape"
        }
      ]
    },
    "control_escape": {
      "type": "PATTERN",
      "value": "\\\\[bfnrtv0]"
    },
    "control_letter_escape": {
      "type": "PATTERN",
      "value": "\\\\c[a-zA-Z]"
    },
    "identity_escape": {
      "type": "TOKEN",
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "STRING",
            "value": "\\"
          },
          {
            "type": "PATTERN",
            "value": "[^kdDsSpPwWbfnrtv0-9]"
          }
        ]
      }
    },
    "group_name": {
      "type": "PATTERN",
      "value": "[A-Za-z0-9]+"
    },
    "decimal_digits": {
      "type": "PATTERN",
      "value": "\\d+"
    }
  },
  "extras": [
    {
      "type": "STRING",
      "value": "\n"
    }
  ],
  "conflicts": [],
  "precedences": [],
  "externals": [],
  "inline": [
    "_character_escape",
    "_class_atom"
  ],
  "supertypes": []
}

'
]

{ #category : #configuration }
SBRegex class >> highlightQuery [

	^ '[
	(character_class)
	(any_character)
	(character_class_escape)
	(class_range)
] @keyword

[
	(control_escape)
	(control_letter_escape)
] @escape

[
	(start_assertion)
	(end_assertion)
	(lookahead_assertion)
] @important

[
	(anonymous_capturing_group)
	(named_capturing_group)
	(non_capturing_group)
] @variable

[
	(count_quantifier)
	(zero_or_more)
	(optional)
	(one_or_more)
] @operator'
]

{ #category : #'configuration - layout' }
SBRegex class >> isBlockInlined: aSymbol [

	^ aSymbol = #term or: [super isBlockInlined: aSymbol]
]

{ #category : #'configuration - editing' }
SBRegex class >> isStatementContainer: aRepeatNode in: aBlock [

	^ false
]

{ #category : #configuration }
SBRegex class >> language [

	^ #regex
]

{ #category : #configuration }
SBRegex class >> rootRuleName [

	^ 'pattern'
]

{ #category : #'configuration - layout' }
SBRegex class >> softLineBreakBetween: aBlock and: anotherBlock [

	^ true
]

{ #category : #'configuration - layout' }
SBRegex class >> spaceBetween: aBlock and: anotherBlock lastCharacterOfFirst: aCharacter [

	^ false
]

{ #category : #palette }
SBRegex >> highlightFor: aBlock [

	^ (aBlock type caseOf: {
			"things that can be one of many other things"
			['character_class'] -> [Color green].
			['any_character'] -> [Color green].
			['character_class_escape'] -> [Color green].
			['class_range'] -> [Color green].

			"escapes"
			['control_escape'] -> [Color magenta].
			['control_letter_escape'] -> [Color magenta].
		
			"assertions"
			['start_assertion'] -> [Color blue].
			['end_assertion'] -> [Color blue].
			['lookahead_assertion'] -> [Color blue].

			"quantifier"
			['count_quantifier'] -> [Color red].
			['zero_or_more'] -> [Color red].
			['optional'] -> [Color red].
			['one_or_more'] -> [Color red].
			['count_quantifier'] -> [Color red].

			"groups"
			['anonymous_capturing_group'] -> [Color orange].
			['named_capturing_group'] -> [Color orange].
			['non_capturing_group'] -> [Color orange]
		}
		otherwise: [nil]) ifNotNil: [:color | color muchLighter]
]

{ #category : #palette }
SBRegex >> palettesFor: aBlock [

	^ {SBRePalette}
]

{ #category : #grammar }
SBRegex >> preprocessGrammar [


	self grammar rules keysAndValuesDo: [:name :rule | rule at: #name put: name].
	(self grammar rules at: #lookahead_assertion) members second  at: #name put: 'type'
]

{ #category : #palette }
SBRegex >> softLineBreakBetween: aBlock and: anotherBlock [

	^ true
]
