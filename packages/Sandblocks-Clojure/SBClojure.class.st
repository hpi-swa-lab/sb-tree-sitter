Class {
	#name : #SBClojure,
	#superclass : #SBTSLanguage,
	#category : #'Sandblocks-Clojure'
}

{ #category : #'as yet unclassified' }
SBClojure class >> allFileSuffixes [

	^ {self fileSuffix. 'cljs'}
]

{ #category : #configuration }
SBClojure class >> extraHighlightQuery [

	^ '(list_lit (sym_lit) @variable .)'
]

{ #category : #configuration }
SBClojure class >> fileSuffix [

	^ 'clj'
]

{ #category : #configuration }
SBClojure class >> grammarJson [

    " https://github.com/sogaiu/tree-sitter-clojure/blob/master/src/grammar.json "
    ^ '{
  "name": "clojure",
  "rules": {
    "source": {
      "type": "REPEAT",
      "content": {
        "type": "CHOICE",
        "members": [
          {
            "type": "SYMBOL",
            "name": "_form"
          },
          {
            "type": "SYMBOL",
            "name": "_gap"
          }
        ]
      }
    },
    "_gap": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "_ws"
        },
        {
          "type": "SYMBOL",
          "name": "comment"
        },
        {
          "type": "SYMBOL",
          "name": "dis_expr"
        }
      ]
    },
    "_ws": {
      "type": "TOKEN",
      "content": {
        "type": "REPEAT1",
        "content": {
          "type": "PATTERN",
          "value": "[\\f\\n\\r\\t, \\u000B\\u001C\\u001D\\u001E\\u001F\\u2028\\u2029\\u1680\\u2000\\u2001\\u2002\\u2003\\u2004\\u2005\\u2006\\u2008\\u2009\\u200a\\u205f\\u3000]"
        }
      }
    },
    "comment": {
      "type": "TOKEN",
      "content": {
        "type": "PATTERN",
        "value": "(;|#!).*\\n?"
      }
    },
    "dis_expr": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "marker",
          "content": {
            "type": "STRING",
            "value": "#_"
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_gap"
          }
        },
        {
          "type": "FIELD",
          "name": "value",
          "content": {
            "type": "SYMBOL",
            "name": "_form"
          }
        }
      ]
    },
    "_form": {
      "type": "CHOICE",
      "members": [
        {
          "type": "SYMBOL",
          "name": "num_lit"
        },
        {
          "type": "SYMBOL",
          "name": "kwd_lit"
        },
        {
          "type": "SYMBOL",
          "name": "str_lit"
        },
        {
          "type": "SYMBOL",
          "name": "char_lit"
        },
        {
          "type": "SYMBOL",
          "name": "nil_lit"
        },
        {
          "type": "SYMBOL",
          "name": "bool_lit"
        },
        {
          "type": "SYMBOL",
          "name": "sym_lit"
        },
        {
          "type": "SYMBOL",
          "name": "list_lit"
        },
        {
          "type": "SYMBOL",
          "name": "map_lit"
        },
        {
          "type": "SYMBOL",
          "name": "vec_lit"
        },
        {
          "type": "SYMBOL",
          "name": "set_lit"
        },
        {
          "type": "SYMBOL",
          "name": "anon_fn_lit"
        },
        {
          "type": "SYMBOL",
          "name": "regex_lit"
        },
        {
          "type": "SYMBOL",
          "name": "read_cond_lit"
        },
        {
          "type": "SYMBOL",
          "name": "splicing_read_cond_lit"
        },
        {
          "type": "SYMBOL",
          "name": "ns_map_lit"
        },
        {
          "type": "SYMBOL",
          "name": "var_quoting_lit"
        },
        {
          "type": "SYMBOL",
          "name": "sym_val_lit"
        },
        {
          "type": "SYMBOL",
          "name": "evaling_lit"
        },
        {
          "type": "SYMBOL",
          "name": "tagged_or_ctor_lit"
        },
        {
          "type": "SYMBOL",
          "name": "derefing_lit"
        },
        {
          "type": "SYMBOL",
          "name": "quoting_lit"
        },
        {
          "type": "SYMBOL",
          "name": "syn_quoting_lit"
        },
        {
          "type": "SYMBOL",
          "name": "unquote_splicing_lit"
        },
        {
          "type": "SYMBOL",
          "name": "unquoting_lit"
        }
      ]
    },
    "num_lit": {
      "type": "TOKEN",
      "content": {
        "type": "PREC",
        "value": 10,
        "content": {
          "type": "SEQ",
          "members": [
            {
              "type": "CHOICE",
              "members": [
                {
                  "type": "PATTERN",
                  "value": "[+-]"
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
                      "value": "0"
                    },
                    {
                      "type": "PATTERN",
                      "value": "[xX]"
                    },
                    {
                      "type": "REPEAT1",
                      "content": {
                        "type": "PATTERN",
                        "value": "[0-9a-fA-F]"
                      }
                    },
                    {
                      "type": "CHOICE",
                      "members": [
                        {
                          "type": "STRING",
                          "value": "N"
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
                      "value": "0"
                    },
                    {
                      "type": "REPEAT1",
                      "content": {
                        "type": "PATTERN",
                        "value": "[0-7]"
                      }
                    },
                    {
                      "type": "CHOICE",
                      "members": [
                        {
                          "type": "STRING",
                          "value": "N"
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
                        "value": "[0-9]"
                      }
                    },
                    {
                      "type": "PATTERN",
                      "value": "[rR]"
                    },
                    {
                      "type": "REPEAT1",
                      "content": {
                        "type": "PATTERN",
                        "value": "[0-9a-zA-Z]"
                      }
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
                        "value": "[0-9]"
                      }
                    },
                    {
                      "type": "STRING",
                      "value": "/"
                    },
                    {
                      "type": "REPEAT1",
                      "content": {
                        "type": "PATTERN",
                        "value": "[0-9]"
                      }
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
                        "value": "[0-9]"
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
                              "value": "."
                            },
                            {
                              "type": "REPEAT",
                              "content": {
                                "type": "PATTERN",
                                "value": "[0-9]"
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
                              "type": "PATTERN",
                              "value": "[eE]"
                            },
                            {
                              "type": "CHOICE",
                              "members": [
                                {
                                  "type": "PATTERN",
                                  "value": "[+-]"
                                },
                                {
                                  "type": "BLANK"
                                }
                              ]
                            },
                            {
                              "type": "REPEAT1",
                              "content": {
                                "type": "PATTERN",
                                "value": "[0-9]"
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
                          "value": "M"
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
                        "value": "[0-9]"
                      }
                    },
                    {
                      "type": "CHOICE",
                      "members": [
                        {
                          "type": "PATTERN",
                          "value": "[MN]"
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
      }
    },
    "kwd_lit": {
      "type": "TOKEN",
      "content": {
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
                    "type": "STRING",
                    "value": "/"
                  },
                  {
                    "type": "SEQ",
                    "members": [
                      {
                        "type": "PATTERN",
                        "value": "[^\\f\\n\\r\\t ()\\[\\]{}\"@~^;`\\\\,:/\\u000B\\u001C\\u001D\\u001E\\u001F\\u2028\\u2029\\u1680\\u2000\\u2001\\u2002\\u2003\\u2004\\u2005\\u2006\\u2008\\u2009\\u200a\\u205f\\u3000]"
                      },
                      {
                        "type": "REPEAT",
                        "content": {
                          "type": "CHOICE",
                          "members": [
                            {
                              "type": "PATTERN",
                              "value": "[:''/]"
                            },
                            {
                              "type": "PATTERN",
                              "value": "[^\\f\\n\\r\\t ()\\[\\]{}\"@~^;`\\\\,:/\\u000B\\u001C\\u001D\\u001E\\u001F\\u2028\\u2029\\u1680\\u2000\\u2001\\u2002\\u2003\\u2004\\u2005\\u2006\\u2008\\u2009\\u200a\\u205f\\u3000]"
                            }
                          ]
                        }
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
                "type": "TOKEN",
                "content": {
                  "type": "STRING",
                  "value": "::"
                }
              },
              {
                "type": "SEQ",
                "members": [
                  {
                    "type": "PATTERN",
                    "value": "[^\\f\\n\\r\\t ()\\[\\]{}\"@~^;`\\\\,:/\\u000B\\u001C\\u001D\\u001E\\u001F\\u2028\\u2029\\u1680\\u2000\\u2001\\u2002\\u2003\\u2004\\u2005\\u2006\\u2008\\u2009\\u200a\\u205f\\u3000]"
                  },
                  {
                    "type": "REPEAT",
                    "content": {
                      "type": "CHOICE",
                      "members": [
                        {
                          "type": "PATTERN",
                          "value": "[:''/]"
                        },
                        {
                          "type": "PATTERN",
                          "value": "[^\\f\\n\\r\\t ()\\[\\]{}\"@~^;`\\\\,:/\\u000B\\u001C\\u001D\\u001E\\u001F\\u2028\\u2029\\u1680\\u2000\\u2001\\u2002\\u2003\\u2004\\u2005\\u2006\\u2008\\u2009\\u200a\\u205f\\u3000]"
                        }
                      ]
                    }
                  }
                ]
              }
            ]
          }
        ]
      }
    },
    "str_lit": {
      "type": "TOKEN",
      "content": {
        "type": "SEQ",
        "members": [
          {
            "type": "STRING",
            "value": "\""
          },
          {
            "type": "REPEAT",
            "content": {
              "type": "PATTERN",
              "value": "[^\"\\\\]"
            }
          },
          {
            "type": "REPEAT",
            "content": {
              "type": "SEQ",
              "members": [
                {
                  "type": "STRING",
                  "value": "\\"
                },
                {
                  "type": "PATTERN",
                  "value": "."
                },
                {
                  "type": "REPEAT",
                  "content": {
                    "type": "PATTERN",
                    "value": "[^\"\\\\]"
                  }
                }
              ]
            }
          },
          {
            "type": "STRING",
            "value": "\""
          }
        ]
      }
    },
    "char_lit": {
      "type": "TOKEN",
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
                "type": "SEQ",
                "members": [
                  {
                    "type": "STRING",
                    "value": "o"
                  },
                  {
                    "type": "CHOICE",
                    "members": [
                      {
                        "type": "SEQ",
                        "members": [
                          {
                            "type": "PATTERN",
                            "value": "[0-9]"
                          },
                          {
                            "type": "PATTERN",
                            "value": "[0-9]"
                          },
                          {
                            "type": "PATTERN",
                            "value": "[0-9]"
                          }
                        ]
                      },
                      {
                        "type": "SEQ",
                        "members": [
                          {
                            "type": "PATTERN",
                            "value": "[0-9]"
                          },
                          {
                            "type": "PATTERN",
                            "value": "[0-9]"
                          }
                        ]
                      },
                      {
                        "type": "SEQ",
                        "members": [
                          {
                            "type": "PATTERN",
                            "value": "[0-9]"
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
                    "type": "STRING",
                    "value": "backspace"
                  },
                  {
                    "type": "STRING",
                    "value": "formfeed"
                  },
                  {
                    "type": "STRING",
                    "value": "newline"
                  },
                  {
                    "type": "STRING",
                    "value": "return"
                  },
                  {
                    "type": "STRING",
                    "value": "space"
                  },
                  {
                    "type": "STRING",
                    "value": "tab"
                  }
                ]
              },
              {
                "type": "SEQ",
                "members": [
                  {
                    "type": "STRING",
                    "value": "u"
                  },
                  {
                    "type": "PATTERN",
                    "value": "[0-9a-fA-F]"
                  },
                  {
                    "type": "PATTERN",
                    "value": "[0-9a-fA-F]"
                  },
                  {
                    "type": "PATTERN",
                    "value": "[0-9a-fA-F]"
                  },
                  {
                    "type": "PATTERN",
                    "value": "[0-9a-fA-F]"
                  }
                ]
              },
              {
                "type": "PATTERN",
                "value": ".|\\n"
              }
            ]
          }
        ]
      }
    },
    "nil_lit": {
      "type": "TOKEN",
      "content": {
        "type": "STRING",
        "value": "nil"
      }
    },
    "bool_lit": {
      "type": "TOKEN",
      "content": {
        "type": "CHOICE",
        "members": [
          {
            "type": "STRING",
            "value": "false"
          },
          {
            "type": "STRING",
            "value": "true"
          }
        ]
      }
    },
    "sym_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_metadata_lit"
          }
        },
        {
          "type": "TOKEN",
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "PATTERN",
                "value": "[^\\f\\n\\r\\t ()\\[\\]{}\"@~^;`\\\\,:#''0-9\\u000B\\u001C\\u001D\\u001E\\u001F\\u2028\\u2029\\u1680\\u2000\\u2001\\u2002\\u2003\\u2004\\u2005\\u2006\\u2008\\u2009\\u200a\\u205f\\u3000]"
              },
              {
                "type": "REPEAT",
                "content": {
                  "type": "CHOICE",
                  "members": [
                    {
                      "type": "PATTERN",
                      "value": "[^\\f\\n\\r\\t ()\\[\\]{}\"@~^;`\\\\,:#''0-9\\u000B\\u001C\\u001D\\u001E\\u001F\\u2028\\u2029\\u1680\\u2000\\u2001\\u2002\\u2003\\u2004\\u2005\\u2006\\u2008\\u2009\\u200a\\u205f\\u3000]"
                    },
                    {
                      "type": "PATTERN",
                      "value": "[:#''0-9]"
                    }
                  ]
                }
              }
            ]
          }
        }
      ]
    },
    "_metadata_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "FIELD",
              "name": "meta",
              "content": {
                "type": "SYMBOL",
                "name": "meta_lit"
              }
            },
            {
              "type": "FIELD",
              "name": "old_meta",
              "content": {
                "type": "SYMBOL",
                "name": "old_meta_lit"
              }
            }
          ]
        },
        {
          "type": "CHOICE",
          "members": [
            {
              "type": "REPEAT",
              "content": {
                "type": "SYMBOL",
                "name": "_gap"
              }
            },
            {
              "type": "BLANK"
            }
          ]
        }
      ]
    },
    "meta_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "marker",
          "content": {
            "type": "STRING",
            "value": "^"
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_gap"
          }
        },
        {
          "type": "FIELD",
          "name": "value",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "read_cond_lit"
              },
              {
                "type": "SYMBOL",
                "name": "map_lit"
              },
              {
                "type": "SYMBOL",
                "name": "str_lit"
              },
              {
                "type": "SYMBOL",
                "name": "kwd_lit"
              },
              {
                "type": "SYMBOL",
                "name": "sym_lit"
              }
            ]
          }
        }
      ]
    },
    "old_meta_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "marker",
          "content": {
            "type": "STRING",
            "value": "#^"
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_gap"
          }
        },
        {
          "type": "FIELD",
          "name": "value",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "read_cond_lit"
              },
              {
                "type": "SYMBOL",
                "name": "map_lit"
              },
              {
                "type": "SYMBOL",
                "name": "str_lit"
              },
              {
                "type": "SYMBOL",
                "name": "kwd_lit"
              },
              {
                "type": "SYMBOL",
                "name": "sym_lit"
              }
            ]
          }
        }
      ]
    },
    "list_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_metadata_lit"
          }
        },
        {
          "type": "SYMBOL",
          "name": "_bare_list_lit"
        }
      ]
    },
    "_bare_list_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "open",
          "content": {
            "type": "STRING",
            "value": "("
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "FIELD",
                "name": "value",
                "content": {
                  "type": "SYMBOL",
                  "name": "_form"
                }
              },
              {
                "type": "SYMBOL",
                "name": "_gap"
              }
            ]
          }
        },
        {
          "type": "FIELD",
          "name": "close",
          "content": {
            "type": "STRING",
            "value": ")"
          }
        }
      ]
    },
    "map_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_metadata_lit"
          }
        },
        {
          "type": "SYMBOL",
          "name": "_bare_map_lit"
        }
      ]
    },
    "_bare_map_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "open",
          "content": {
            "type": "STRING",
            "value": "{"
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "FIELD",
                "name": "value",
                "content": {
                  "type": "SYMBOL",
                  "name": "_form"
                }
              },
              {
                "type": "SYMBOL",
                "name": "_gap"
              }
            ]
          }
        },
        {
          "type": "FIELD",
          "name": "close",
          "content": {
            "type": "STRING",
            "value": "}"
          }
        }
      ]
    },
    "vec_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_metadata_lit"
          }
        },
        {
          "type": "SYMBOL",
          "name": "_bare_vec_lit"
        }
      ]
    },
    "_bare_vec_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "open",
          "content": {
            "type": "STRING",
            "value": "["
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "FIELD",
                "name": "value",
                "content": {
                  "type": "SYMBOL",
                  "name": "_form"
                }
              },
              {
                "type": "SYMBOL",
                "name": "_gap"
              }
            ]
          }
        },
        {
          "type": "FIELD",
          "name": "close",
          "content": {
            "type": "STRING",
            "value": "]"
          }
        }
      ]
    },
    "set_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_metadata_lit"
          }
        },
        {
          "type": "SYMBOL",
          "name": "_bare_set_lit"
        }
      ]
    },
    "_bare_set_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "marker",
          "content": {
            "type": "STRING",
            "value": "#"
          }
        },
        {
          "type": "FIELD",
          "name": "open",
          "content": {
            "type": "STRING",
            "value": "{"
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "FIELD",
                "name": "value",
                "content": {
                  "type": "SYMBOL",
                  "name": "_form"
                }
              },
              {
                "type": "SYMBOL",
                "name": "_gap"
              }
            ]
          }
        },
        {
          "type": "FIELD",
          "name": "close",
          "content": {
            "type": "STRING",
            "value": "}"
          }
        }
      ]
    },
    "anon_fn_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_metadata_lit"
          }
        },
        {
          "type": "FIELD",
          "name": "marker",
          "content": {
            "type": "STRING",
            "value": "#"
          }
        },
        {
          "type": "SYMBOL",
          "name": "_bare_list_lit"
        }
      ]
    },
    "regex_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "marker",
          "content": {
            "type": "STRING",
            "value": "#"
          }
        },
        {
          "type": "TOKEN",
          "content": {
            "type": "SEQ",
            "members": [
              {
                "type": "STRING",
                "value": "\""
              },
              {
                "type": "REPEAT",
                "content": {
                  "type": "PATTERN",
                  "value": "[^\"\\\\]"
                }
              },
              {
                "type": "REPEAT",
                "content": {
                  "type": "SEQ",
                  "members": [
                    {
                      "type": "STRING",
                      "value": "\\"
                    },
                    {
                      "type": "PATTERN",
                      "value": "."
                    },
                    {
                      "type": "REPEAT",
                      "content": {
                        "type": "PATTERN",
                        "value": "[^\"\\\\]"
                      }
                    }
                  ]
                }
              },
              {
                "type": "STRING",
                "value": "\""
              }
            ]
          }
        }
      ]
    },
    "read_cond_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_metadata_lit"
          }
        },
        {
          "type": "FIELD",
          "name": "marker",
          "content": {
            "type": "STRING",
            "value": "#?"
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_ws"
          }
        },
        {
          "type": "SYMBOL",
          "name": "_bare_list_lit"
        }
      ]
    },
    "splicing_read_cond_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_metadata_lit"
          }
        },
        {
          "type": "FIELD",
          "name": "marker",
          "content": {
            "type": "STRING",
            "value": "#?@"
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_ws"
          }
        },
        {
          "type": "SYMBOL",
          "name": "_bare_list_lit"
        }
      ]
    },
    "auto_res_mark": {
      "type": "TOKEN",
      "content": {
        "type": "STRING",
        "value": "::"
      }
    },
    "ns_map_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_metadata_lit"
          }
        },
        {
          "type": "FIELD",
          "name": "marker",
          "content": {
            "type": "STRING",
            "value": "#"
          }
        },
        {
          "type": "FIELD",
          "name": "prefix",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "auto_res_mark"
              },
              {
                "type": "SYMBOL",
                "name": "kwd_lit"
              }
            ]
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_gap"
          }
        },
        {
          "type": "SYMBOL",
          "name": "_bare_map_lit"
        }
      ]
    },
    "var_quoting_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_metadata_lit"
          }
        },
        {
          "type": "FIELD",
          "name": "marker",
          "content": {
            "type": "STRING",
            "value": "#''"
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_gap"
          }
        },
        {
          "type": "FIELD",
          "name": "value",
          "content": {
            "type": "SYMBOL",
            "name": "_form"
          }
        }
      ]
    },
    "sym_val_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "FIELD",
          "name": "marker",
          "content": {
            "type": "STRING",
            "value": "##"
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_gap"
          }
        },
        {
          "type": "FIELD",
          "name": "value",
          "content": {
            "type": "SYMBOL",
            "name": "sym_lit"
          }
        }
      ]
    },
    "evaling_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_metadata_lit"
          }
        },
        {
          "type": "FIELD",
          "name": "marker",
          "content": {
            "type": "STRING",
            "value": "#="
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_gap"
          }
        },
        {
          "type": "FIELD",
          "name": "value",
          "content": {
            "type": "CHOICE",
            "members": [
              {
                "type": "SYMBOL",
                "name": "list_lit"
              },
              {
                "type": "SYMBOL",
                "name": "read_cond_lit"
              },
              {
                "type": "SYMBOL",
                "name": "sym_lit"
              }
            ]
          }
        }
      ]
    },
    "tagged_or_ctor_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_metadata_lit"
          }
        },
        {
          "type": "FIELD",
          "name": "marker",
          "content": {
            "type": "STRING",
            "value": "#"
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_gap"
          }
        },
        {
          "type": "FIELD",
          "name": "tag",
          "content": {
            "type": "SYMBOL",
            "name": "sym_lit"
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_gap"
          }
        },
        {
          "type": "FIELD",
          "name": "value",
          "content": {
            "type": "SYMBOL",
            "name": "_form"
          }
        }
      ]
    },
    "derefing_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_metadata_lit"
          }
        },
        {
          "type": "FIELD",
          "name": "marker",
          "content": {
            "type": "STRING",
            "value": "@"
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_gap"
          }
        },
        {
          "type": "FIELD",
          "name": "value",
          "content": {
            "type": "SYMBOL",
            "name": "_form"
          }
        }
      ]
    },
    "quoting_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_metadata_lit"
          }
        },
        {
          "type": "FIELD",
          "name": "marker",
          "content": {
            "type": "STRING",
            "value": "''"
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_gap"
          }
        },
        {
          "type": "FIELD",
          "name": "value",
          "content": {
            "type": "SYMBOL",
            "name": "_form"
          }
        }
      ]
    },
    "syn_quoting_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_metadata_lit"
          }
        },
        {
          "type": "FIELD",
          "name": "marker",
          "content": {
            "type": "STRING",
            "value": "`"
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_gap"
          }
        },
        {
          "type": "FIELD",
          "name": "value",
          "content": {
            "type": "SYMBOL",
            "name": "_form"
          }
        }
      ]
    },
    "unquote_splicing_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_metadata_lit"
          }
        },
        {
          "type": "FIELD",
          "name": "marker",
          "content": {
            "type": "STRING",
            "value": "~@"
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_gap"
          }
        },
        {
          "type": "FIELD",
          "name": "value",
          "content": {
            "type": "SYMBOL",
            "name": "_form"
          }
        }
      ]
    },
    "unquoting_lit": {
      "type": "SEQ",
      "members": [
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_metadata_lit"
          }
        },
        {
          "type": "FIELD",
          "name": "marker",
          "content": {
            "type": "STRING",
            "value": "~"
          }
        },
        {
          "type": "REPEAT",
          "content": {
            "type": "SYMBOL",
            "name": "_gap"
          }
        },
        {
          "type": "FIELD",
          "name": "value",
          "content": {
            "type": "SYMBOL",
            "name": "_form"
          }
        }
      ]
    }
  },
  "extras": [],
  "conflicts": [],
  "precedences": [],
  "externals": [],
  "inline": [],
  "supertypes": []
}

'
]

{ #category : #configuration }
SBClojure class >> highlightQuery [
	" https://github.com/sogaiu/tree-sitter-clojure/blob/master/src/queries/highlights.scm "

	^ ';; Literals

(num_lit) @number

[
  (char_lit)
  (str_lit)
] @string

[
 (bool_lit)
 (nil_lit)
] @constant.builtin

(kwd_lit) @constant

;; Comments

(comment) @comment

;; Treat quasiquotation as operators for the purpose of highlighting.

[
 "''"
 "`"
 "~"
 "@"
 "~@"
] @operator
', self extraHighlightQuery
]

{ #category : #configuration }
SBClojure class >> icon [

	^ Form
		extent: 16 @ 16
		depth: 32
		fromArray: #(0 0 0 0 805306367 2533359615 3640064252 4192857336 4192923128 3640129788 2533359615 838860799 0 0 0 0 0 0 167772159 2550136831 4259111668 4287998434 4284253145 4283990488 4283990488 4284253145 4287932898 4259045876 2566914047 167772159 0 0 0 167772159 3221028094 4289641704 4283990488 4283990488 4283990488 4283990488 4283990488 4283990488 4283990488 4283990488 4289510375 3220962558 167772159 0 0 2566914047 4292994806 4292666100 4292929013 4291022317 4289050085 4291351022 4291416814 4288984293 4284318937 4283990488 4283990488 4289510375 2550136831 0 822083583 4261412863 4294178801 4291617220 4292011211 4294835965 4294770175 4290235646 4289841406 4292009726 4293257976 4286224093 4283990488 4283990488 4258980083 822083583 2533359615 4293193440 4285576780 4284985913 4293259488 4289651847 4292014016 4291944190 4287673598 4287673598 4289512958 4293257976 4284384473 4283990488 4287801313 2516582399 3640524540 4286889322 4284723506 4289187225 4292014017 4287749191 4288011601 4293719538 4287739390 4287673598 4287673598 4291878398 4289115878 4283990488 4284187608 3623221244 4192858854 4284723506 4284723506 4291551428 4289914253 4287749191 4287749191 4292867027 4289578750 4287673598 4287673598 4289710078 4291548143 4283990488 4283990488 4192726007 4192924391 4284723506 4284723506 4291616964 4289848716 4287749191 4288733292 4293129688 4292075519 4287673598 4287673598 4289710078 4291548399 4283990488 4283990488 4192660215 3640064757 4284920376 4284723506 4289318555 4291948223 4287749191 4292407752 4289126774 4293719537 4287936510 4287673598 4291878398 4289181670 4283990488 4285370075 3623484157 2533359615 4288202373 4284723506 4285051708 4293325281 4290045585 4293523424 4287749191 4292079554 4291944190 4289381630 4293323769 4284450265 4285107162 4292665844 2516582399 822083583 4259048150 4284723506 4284723506 4286758248 4293587943 4293720294 4289717384 4290242196 4294770427 4294835967 4293389304 4292863221 4294507261 4261412863 822083583 0 2550136831 4289647009 4284723506 4284723506 4285117246 4289449885 4291748551 4291682758 4289515422 4288399241 4290172331 4290172075 4291748807 2550136831 0 0 167772159 3220962810 4289647009 4284723506 4284723506 4284723506 4284723506 4284723506 4284723506 4284723506 4284723506 4289515422 3220962554 167772159 0 0 0 167772159 2550136831 4258982357 4288071042 4284854838 4284723506 4284723506 4284854837 4287939712 4258916563 2566914047 167772159 0 0 0 0 0 0 805306367 2516582399 3623221747 4192727267 4192661731 3623156210 2533359615 838860799 0 0 0 0)
		offset: 0 @ 0
]

{ #category : #'as yet unclassified' }
SBClojure class >> isExpression: aBlock [

	^ true
]

{ #category : #'configuration - editing' }
SBClojure class >> isStatementContainer: aRepeatNode in: aBlock [

	^ aBlock type = #source and: [aRepeatNode element isTSChoice and: [aRepeatNode element alternatives anySatisfy: [:sym | sym type = #'sym_lit']]]
]

{ #category : #configuration }
SBClojure class >> language [

    ^ #clojure
]

{ #category : #configuration }
SBClojure class >> preprocessGrammar: aGrammar [
	"clojure usually tracks whitespaces specifically which creates a lot of nodes in our system. mark these as extras for now such that they are skipped during block creation."

	aGrammar extras: {'\s*' asRegex}
]

{ #category : #configuration }
SBClojure class >> rootRuleName [

	^ 'source'
]

{ #category : #actions }
SBClojure class >> showHelp: aBlock [
	<action>

	aBlock containingArtefact showHelpFor: aBlock
]

{ #category : #builder }
SBClojure class >> sourceForSlider: aBlock [

	| slider |
	slider := self parseExpression: '(nth [0 ''slider] 0)'.
	slider childSandblocks second childSandblocks first replaceBlock: aBlock.
	^ (slider adaptSlotFor: aBlock slot ifFailed: [self error: 'blocks not compatible']) applyReplacement
]

{ #category : #'configuration - layout' }
SBClojure class >> spaceBetween: aBlock and: anotherBlock lastCharacterOfFirst: aCharacter [

	(SBToggledCode comment: '' active: 2 do: {
		[true].
		[(#('map_lit' 'vec_lit' 'list_lit') includes: aBlock owner type) and: [aBlock ~= aBlock owner firstSubmorph and: [anotherBlock ~= aBlock owner lastSubmorph]]]}) ifTrue: [^ true].
	^ super spaceBetween: aBlock and: anotherBlock lastCharacterOfFirst: aCharacter
]

{ #category : #'configuration - suggestions' }
SBClojure class >> suggestionsForInsert: aCommand [

	(aCommand container containingArtefact notNil and: [aCommand container type = 'list_lit' and: [aCommand insertIndex > 2 and: [aCommand container childSandblocks first type = 'sym_lit']]]) ifTrue: [ | signatures |
		signatures := ((aCommand container containingArtefact evaluateString: ('(:arglists (meta #''{1}))' format: {aCommand container childSandblocks first contents})) ifNil: [Dictionary new])
			at: 'value'
			ifAbsent: [^ #()].
		signatures := SBScmParser new parse: signatures readStream.
		^ signatures firstSubmorph submorphs collect: [:expr | | signature |
			signature := expr sourceString.
			(SBInsertSuggestionItem selector: signature label: 'arg')
				morph: (aCommand element buildEmpty first placeholderText: signature)
					previewOnly: true;
				yourself]].
	^ super suggestionsForInsert: aCommand
]

{ #category : #'as yet unclassified' }
SBClojure >> suggestionsForInsert: aCommand [

	(aCommand container containingArtefact notNil and: [aCommand container type = 'list_lit' and: [aCommand insertIndex > 2 and: [aCommand container childSandblocks first type = 'sym_lit']]]) ifTrue: [ | signatures |
		signatures := (aCommand container containingArtefact evaluateString: ('(:arglists (meta #''{1}))' format: {aCommand container childSandblocks first contents}))
			at: 'value'
			ifAbsent: [^ #()].
		signatures := SBScmParser new parse: signatures readStream.
		^ signatures firstSubmorph submorphs collect: [:expr | | signature |
			signature := expr sourceString.
			(SBInsertSuggestionItem selector: signature label: 'arg')
				morph: (aCommand element buildEmpty first placeholderText: signature)
					previewOnly: true;
				yourself]].
	^ super suggestionsForInsert: aCommand
]
