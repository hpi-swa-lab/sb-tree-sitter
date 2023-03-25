Class {
	#name : #SBJson,
	#superclass : #SBTSLanguage,
	#category : #'Sandblocks-Json'
}

{ #category : #'as yet unclassified' }
SBJson class >> allFileSuffixes [ ^ {'json'}
]

{ #category : #properties }
SBJson class >> grammarJson [

    " https://github.com/tree-sitter/tree-sitter-json/blob/master/src/grammar.json "
    ^ '{
  "name": "json",
  "rules": {
    "document": {
      "type": "SYMBOL",
      "name": "_value"
    },
    "_value": {
      "type": "CHOICE",
      "members": [
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
          "name": "number"
        },
        {
          "type": "SYMBOL",
          "name": "string"
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
        }
      ]
    },
    "object": {
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
                  "name": "pair"
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
                        "name": "pair"
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
    },
    "pair": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "key",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "string"
              },
              {
                "type": "SYMBOL",
                "name": "number"
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
          "name": "value",
          "content": {
            "type": "SYMBOL",
            "name": "_value"
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
                  "type": "SYMBOL",
                  "name": "_value"
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
                        "name": "_value"
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
              "value": "\""
            },
            {
              "type": "SYMBOL",
              "name": "string_content"
            },
            {
              "type": "STRING",
              "value": "\""
            }
          ]
        }
      ]
    },
    "string_content": {
      "type": "REPEAT1",
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
                "value": "[^\\\\\"\\n]+"
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
            "type": "PATTERN",
            "value": "(\\\"|\\\\|\\/|b|f|n|r|t|u)"
          }
        ]
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
                "value": "[\\da-fA-F]+"
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
                                "type": "PATTERN",
                                "value": "[1-9]"
                              },
                              {
                                "type": "CHOICE",
                                "members": [
                                  {
                                    "type": "PATTERN",
                                    "value": "\\d+"
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
                  {
                    "type": "STRING",
                    "value": "."
                  },
                  {
                    "type": "CHOICE",
                    "members": [
                      {
                        "type": "PATTERN",
                        "value": "\\d+"
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
                                "value": "\\d+"
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
                    "value": "\\d+"
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
                                "value": "\\d+"
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
                                "type": "PATTERN",
                                "value": "[1-9]"
                              },
                              {
                                "type": "CHOICE",
                                "members": [
                                  {
                                    "type": "PATTERN",
                                    "value": "\\d+"
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
                                "value": "\\d+"
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
                "value": "[0-1]+"
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
                "value": "[0-7]+"
              }
            ]
          }
        ]
      }
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
  "supertypes": [
    "_value"
  ]
}

'
]

{ #category : #properties }
SBJson class >> highlightQuery [

    " https://github.com/tree-sitter/tree-sitter-json/blob/master/src/queries/highlights.scm "
    ^ '(pair
  key: (_) @string.special.key)

(string) @string

(number) @number

[
  (null)
  (true)
  (false)
] @constant.builtin

(escape_sequence) @escape

(comment) @comment
'
]

{ #category : #configuration }
SBJson class >> language [

    ^ #json
]

{ #category : #configuration }
SBJson class >> rootRuleName [

    ^ 'document'
]
