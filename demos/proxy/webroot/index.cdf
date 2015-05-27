{
  "t": "html",
  "s": {
    "lang": "en"
  },
  "c": [
    {
      "t": "head",
      "c": [
        {
          "t": "meta",
          "s": {
            "charset": "utf8"
          }
        },
        {
          "t": "title",
          "c": [{"text": "CDF Behavior Demos"}]
        },
        {
          "t": "meta",
          "s": {
            "name": "viewport",
            "content": "width=device-width, initial-scale=1"
          }
        },
        {
          "t": "link",
          "s": {
            "href": "/stylesheets/bootstrap.min.css",
            "media": "all",
            "rel": "stylesheet",
            "type": "text/css"
          }
        },
        {
          "t": "link",
          "s": {
            "href": "/stylesheets/bootstrap-theme.min.css",
            "media": "all",
            "rel": "stylesheet",
            "type": "text/css"
          }
        },
        {
          "t": "link",
          "s": {
            "href": "/stylesheets/styles.css",
            "media": "all",
            "rel": "stylesheet",
            "type": "text/css"
          }
        }
      ]
    },
    {
      "t": "body",
      "c": [
        {
          "t": "div",
          "s": {
            "class": ["container"]
          },
          "c": [
            {
              "t": "header",
              "s": {
                "class": ["row"]
              },
              "c": [
                {
                  "t": "div",
                  "s": {
                    "class": ["col-md-12"]
                  },
                  "c": [
                    {
                      "t": "h1",
                      "s": {
                        "id": "main-bean"
                      },
                      "c": [
                        {"text": "CDF Behavior Demos"},
                        {
                          "t": "small",
                          "c": [{"text": "Hold on to your butts..."}]
                        }
                      ]
                    }
                  ]
                }
              ]
            },
            {
              "t": "div",
              "s": {
                "class": ["row"],
                "id": "tab-row"
              },
              "c": [
                {
                  "t": "div",
                  "s": {
                    "class": ["col-md-12"]
                  },
                  "c": [
                    {
                      "t": "ul",
                      "s": {
                        "class": ["nav", "nav-tabs"],
                        "id": "main-tabs"
                      },
                      "c": [
                        {
                          "t": "li",
                          "s": {
                            "class": ["first"]
                          },
                          "c": [
                            {
                              "t": "a",
                              "s": {
                                "href": "#"
                              },
                              "c": [{"text": "First Tab"}]
                            }
                          ],
                          "e": [
                            {
                              "t": "click",
                              "b": [
                                {
                                  "t": "states",
                                  "s": {
                                    "stateId": "main-tabs-state",
                                    "index": 0,
                                    "initial": 1,
                                    "common": [
                                      [
                                        "#main-tabs li",
                                        {
                                          "t": "classes",
                                          "s": {
                                            "action": "remove",
                                            "change": ["active"]
                                          }
                                        }
                                      ],
                                      [
                                        ".tab-content",
                                        {
                                          "t": "classes",
                                          "s": {
                                            "action": "add",
                                            "change": ["hidden"]
                                          }
                                        }
                                      ]
                                    ],
                                    "states": [
                                      [
                                        [
                                          "#main-tabs li.first",
                                          {
                                            "t": "classes",
                                            "s": {
                                              "action": "add",
                                              "change": ["active"]
                                            }
                                          }
                                        ],
                                        [
                                          "#main-tabs-first-tab-content",
                                          {
                                            "t": "classes",
                                            "s": {
                                              "action": "remove",
                                              "change": ["hidden"]
                                            }
                                          }
                                        ]
                                      ],
                                      [
                                        [
                                          "#main-tabs li.second",
                                          {
                                            "t": "classes",
                                            "s": {
                                              "action": "add",
                                              "change": ["active"]
                                            }
                                          }
                                        ],
                                        [
                                          "#main-tabs-second-tab-content",
                                          {
                                            "t": "classes",
                                            "s": {
                                              "action": "remove",
                                              "change": ["hidden"]
                                            }
                                          }
                                        ]
                                      ],
                                      [
                                        [
                                          "#main-tabs li.third",
                                          {
                                            "t": "classes",
                                            "s": {
                                              "action": "add",
                                              "change": ["active"]
                                            }
                                          }
                                        ],
                                        [
                                          "#main-tabs-third-tab-content",
                                          {
                                            "t": "classes",
                                            "s": {
                                              "action": "remove",
                                              "change": ["hidden"]
                                            }
                                          }
                                        ]
                                      ]
                                    ]
                                  }
                                }
                              ]
                            }
                          ]
                        },
                        {
                          "t": "li",
                          "s": {
                            "class": ["second"]
                          },
                          "c": [
                            {
                              "t": "a",
                              "s": {
                                "href": "#"
                              },
                              "c": [{"text": "'Appears' Tab"}]
                            }
                          ],
                          "e": [
                            {
                              "t": "click",
                              "b": [
                                {
                                  "t": "states",
                                  "s": {
                                    "stateId": "main-tabs-state",
                                    "index": 1
                                  }
                                }
                              ]
                            }
                          ]
                        },
                        {
                          "t": "li",
                          "s": {
                            "class": ["third"]
                          },
                          "c": [
                            {
                              "t": "a",
                              "s": {
                                "href": "#"
                              },
                              "c": [{"text": "Third Tab"}]
                            }
                          ],
                          "e": [
                            {
                              "t": "click",
                              "b": [
                                {
                                  "t": "states",
                                  "s": {
                                    "stateId": "main-tabs-state",
                                    "index": 2
                                  }
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
            {
              "t": "div",
              "s": {
                "class": ["row"],
                "id": "main-tabs-container"
              },
              "c": [
                {
                  "t": "div",
                  "s": {
                    "class": ["tab-content", "col-md-12"],
                    "id": "main-tabs-first-tab-content"
                  },
                  "c": [
                    {
                      "t": "h2",
                      "c": [{"text": "First Tab Content"}]
                    },
                    {
                      "t": "ul",
                      "c": [
                        {
                          "t": "li",
                          "c": [
                            {
                              "t": "img",
                              "s": {
                                "src": "/images/dog-teddy.jpg"
                              }
                            }
                          ]
                        },
                        {
                          "t": "li",
                          "c": [
                            {
                              "t": "img",
                              "s": {
                                "src": "/images/sick-o-cat.jpg"
                              }
                            }
                          ]
                        }
                      ]
                    }
                  ]
                },
                {
                  "t": "div",
                  "s": {
                    "class": ["tab-content", "col-md-12"],
                    "id": "main-tabs-second-tab-content"
                  },
                  "c": [
                    {
                      "t": "h2",
                      "c": [{"text": "Appears Demo"}]
                    },
                    {
                      "t": "div",
                      "s": {
                        "id": "appears-demo-message",
                        "class": ["alert", "alert-info"]
                      },
                      "c": [
                        {
                          "t": "span",
                          "c": [
                            {"text": "Last element is on screen"}
                          ]
                        }
                      ]
                    },
                    {
                      "t": "ol",
                      "c": [
                        {"t": "li", "c": [{"text": "-"}]},
                        {"t": "li", "c": [{"text": "-"}]},
                        {"t": "li", "c": [{"text": "-"}]},
                        {"t": "li", "c": [{"text": "-"}]},
                        {"t": "li", "c": [{"text": "-"}]},
                        {"t": "li", "c": [{"text": "-"}]},
                        {"t": "li", "c": [{"text": "-"}]},
                        {"t": "li", "c": [{"text": "-"}]},
                        {"t": "li", "c": [{"text": "-"}]},
                        {"t": "li", "c": [{"text": "-"}]},
                        {"t": "li", "c": [{"text": "-"}]},
                        {"t": "li", "c": [{"text": "-"}]},
                        {"t": "li", "c": [{"text": "-"}]},
                        {"t": "li", "c": [{"text": "-"}]},
                        {"t": "li", "c": [{"text": "-"}]},
                        {"t": "li", "c": [{"text": "-"}]},
                        {"t": "li", "c": [{"text": "-"}]},
                        {"t": "li", "c": [{"text": "-"}]},
                        {
                          "t": "li",
                          "c": [{"text": "Last"}],
                          "e": [
                            {
                              "t": "appear",
                              "b": [
                                {
                                  "t": "states",
                                  "s": {
                                    "stateId": "appears-demo-message-state",
                                    "index": 0,
                                    "common": [
                                      [
                                        "#appears-demo-message",
                                        {
                                          "t": "classes",
                                          "s": {
                                            "action": "remove",
                                            "change": ["alert-info", "alert-warning"]
                                          }
                                        }
                                      ]
                                    ],
                                    "states": [
                                      [
                                        [
                                          "#appears-demo-message",
                                          {
                                            "t": "classes",
                                            "s": {
                                              "action": "add",
                                              "change": ["alert-info"]
                                            }
                                          }
                                        ],
                                        [
                                          "#appears-demo-message span",
                                          {
                                            "t": "update-subtree",
                                            "s": {
                                              "action": "replace",
                                              "change": [
                                                {
                                                  "t": "span",
                                                  "c": [
                                                    {"text": "Last element is ON screen"}
                                                  ]
                                                }
                                              ]
                                            }
                                          }
                                        ]
                                      ],
                                      [
                                        [
                                          "#appears-demo-message",
                                          {
                                            "t": "classes",
                                            "s": {
                                              "action": "add",
                                              "change": ["alert-warning"]
                                            }
                                          }
                                        ],
                                        [
                                          "#appears-demo-message span",
                                          {
                                            "t": "update-subtree",
                                            "s": {
                                              "action": "replace",
                                              "change": [
                                                {"t": "span",
                                                  "c": [
                                                    {"text": "Last element is OFF screen"}
                                                  ]
                                                }
                                              ]
                                            }
                                          }
                                        ]
                                      ]
                                    ]
                                  }
                                }
                              ]
                            },
                            {
                              "t": "disappear",
                              "b": [
                                {
                                  "t": "states",
                                  "s": {
                                    "stateId": "appears-demo-message-state",
                                    "index": 1
                                  }
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
                  "t": "div",
                  "s": {
                    "class": ["tab-content", "col-md-12"],
                    "id": "main-tabs-third-tab-content"
                  },
                  "c": [
                    {
                      "t": "h2",
                      "c": [{"text": "Third Tab Content"}]
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
