Class {
	#name : #SBTsq,
	#superclass : #SBTSLanguage,
	#category : #'Sandblocks-Tsq'
}

{ #category : #properties }
SBTsq class >> grammarJson [

    " https://github.com/tree-sitter/tree-sitter-tsq/blob/master/src/grammar.json "
    ^ '{
  "name": "tsq",
  "word": "_identifier",
  "rules": {
    "query": {
      "type": "REPEAT",
      "content": {
        "type": "CHOICE",
        "members": [
          {
            "type": "SYMBOL",
            "name": "pattern"
          },
          {
            "type": "SYMBOL",
            "name": "predicate"
          }
        ]
      }
    },
    "pattern": {
      "type": "SYMBOL",
      "name": "_pattern"
    },
    "comment": {
      "type": "TOKEN",
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "STRING",
            "value": ";"
          },
          {
            "type": "PATTERN",
            "value": ".*"
          }
        ]
      }
    },
    "_pattern": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "pattern",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "alternation"
              },
              {
                "type": "SYMBOL",
                "name": "anonymous_leaf"
              },
              {
                "type": "SYMBOL",
                "name": "group"
              },
              {
                "type": "SYMBOL",
                "name": "named_node"
              },
              {
                "type": "SYMBOL",
                "name": "wildcard_node"
              }
            ]
          }
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "FIELD",
              "name": "quantifier",
              "content": {
                "type": "SYMBOL",
                "name": "_quantifier"
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
              "name": "capture"
            },
            {
              "type": "BLANK"
            }
          ]
        }
      ]
    },
    "_quantifier": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "one_or_more"
        },
        {
          "type": "SYMBOL",
          "name": "zero_or_one"
        },
        {
          "type": "SYMBOL",
          "name": "zero_or_more"
        }
      ]
    },
    "one_or_more": {
      "type": "STRING",
      "value": "+"
    },
    "zero_or_one": {
      "type": "STRING",
      "value": "?"
    },
    "zero_or_more": {
      "type": "STRING",
      "value": "*"
    },
    "capture": {
      "type": "PATTERN",
      "value": "@[a-zA-Z0-9_-][a-zA-Z0-9.?!_-]*"
    },
    "alternation": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "["
        },
        {
          "type": "REPEAT1",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "choice"
              },
              {
                "type": "SYMBOL",
                "name": "predicate"
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
    "choice": {
      "type": "SYMBOL",
      "name": "_pattern"
    },
    "anonymous_leaf": {
      "type": "SYMBOL",
      "name": "_string"
    },
    "_string": {
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
                "type": "IMMEDIATE_TOKEN",
                "content": {
                  "type": "PREC",
                  "value": 1,
                  "content": {
                    "type": "PATTERN",
                    "value": "[^\"\\n\\\\]+"
                  }
                }
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
                "type": "STRING",
                "value": "n"
              },
              {
                "type": "STRING",
                "value": "r"
              },
              {
                "type": "STRING",
                "value": "t"
              },
              {
                "type": "STRING",
                "value": "0"
              },
              {
                "type": "STRING",
                "value": "\\"
              }
            ]
          }
        ]
      }
    },
    "_identifier": {
      "type": "PATTERN",
      "value": "[a-zA-Z0-9_-][a-zA-Z0-9.?!_-]*"
    },
    "group": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "("
        },
        {
          "type": "REPEAT1",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "pattern"
              },
              {
                "type": "SYMBOL",
                "name": "predicate"
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
    "named_node": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "("
        },
        {
          "type": "SYMBOL",
          "name": "node_name"
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
                    "type": "SEQ",
                    "members": [
                      {
                        "type": "CHOICE",
                        "members": [
                          {
                            "type": "SYMBOL",
                            "name": "anchor"
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
                            "name": "child"
                          },
                          {
                            "type": "SYMBOL",
                            "name": "negated_child"
                          },
                          {
                            "type": "SYMBOL",
                            "name": "predicate"
                          }
                        ]
                      }
                    ]
                  }
                },
                {
                  "type": "CHOICE",
                  "members": [
                    {
                      "type": "SYMBOL",
                      "name": "anchor"
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
    "node_name": {
      "type": "SYMBOL",
      "name": "_identifier"
    },
    "anchor": {
      "type": "STRING",
      "value": "."
    },
    "child": {
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
                  "name": "field_name"
                },
                {
                  "type": "STRING",
                  "value": ":"
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
          "name": "_pattern"
        }
      ]
    },
    "field_name": {
      "type": "SYMBOL",
      "name": "_identifier"
    },
    "negated_child": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "!"
        },
        {
          "type": "SYMBOL",
          "name": "field_name"
        }
      ]
    },
    "predicate": {
      "type": "SEQ",
      "members": [
        {
          "type": "STRING",
          "value": "("
        },
        {
          "type": "SYMBOL",
          "name": "predicate_name"
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "capture"
              },
              {
                "type": "SYMBOL",
                "name": "string"
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
    "predicate_name": {
      "type": "PATTERN",
      "value": "#[a-zA-Z0-9_-][a-zA-Z0-9.?!_-]*"
    },
    "string": {
      "type": "SYMBOL",
      "name": "_string"
    },
    "wildcard_node": {
      "type": "PREC_RIGHT",
      "value": 0,
      "content": {
        "type": "CHOICE",
        "members": [
          {
            "type": "STRING",
            "value": "_"
          },
          {
            "type": "SEQ",
            "members": [
              {
                "type": "STRING",
                "value": "("
              },
              {
                "type": "STRING",
                "value": "_"
              },
              {
                "type": "STRING",
                "value": ")"
              }
            ]
          }
        ]
      }
    }
  },
  "extras": [
    {
      "type": "PATTERN",
      "value": "\\s"
    },
    {
      "type": "SYMBOL",
      "name": "comment"
    }
  ],
  "conflicts": [],
  "precedences": [],
  "externals": [],
  "inline": [],
  "supertypes": []
}

'
]

{ #category : #properties }
SBTsq class >> language [

    ^ #tsq
]

{ #category : #properties }
SBTsq class >> rootRuleName [

	^ 'query'
]
