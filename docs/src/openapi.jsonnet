local Delete = import 'delete.jsonnet';
local Get = import 'get.jsonnet';
local Patch = import 'patch.jsonnet';
local Post = import 'post.jsonnet';
local Put = import 'put.jsonnet';

local ParamDay = import 'day.param.jsonnet';
local ParamMonth = import 'month.param.jsonnet';
local ParamPath = import 'path.param.jsonnet';
local ParamPeriod = import 'period.param.jsonnet';
local ParamYear = import 'year.param.jsonnet';


std.manifestYamlDoc(
  {
    openapi: '3.0.2',
    info: {
      title: 'Local REST API for Obsidian',
      description: "You can use this interface for trying out your Local REST API in Obsidian.\n\nBefore trying the below tools, you will want to make sure you press the \"Authorize\" button below and provide the API Key you are shown when you open the \"Local REST API\" section of your Obsidian settings.  All requests to the API require a valid API Key; so you won't get very far without doing that.\n\nWhen using this tool you may see browser security warnings due to your browser not trusting the self-signed certificate the plugin will generate on its first run.  If you do, you can make those errors disappear by adding the certificate as a \"Trusted Certificate\" in your browser or operating system's settings.\n",
      version: '1.0',
    },
    servers: [
      {
        url: 'https://{host}:{port}',
        description: 'HTTPS (Secure Mode)',
        variables: {
          port: {
            default: '27124',
            description: 'HTTPS port',
          },
          host: {
            default: '127.0.0.1',
            description: 'Binding host',
          },
        },
      },
      {
        url: 'http://{host}:{port}',
        description: 'HTTP (Insecure Mode)',
        variables: {
          port: {
            default: '27123',
            description: 'HTTP port',
          },
          host: {
            default: '127.0.0.1',
            description: 'Binding host',
          },
        },
      },
    ],
    components: {
      securitySchemes: {
        apiKeyAuth: {
          description: 'Find your API Key in your Obsidian settings\nin the "Local REST API" section under "Plugins".\n',
          type: 'http',
          scheme: 'bearer',
        },
      },
      schemas: {
        NoteJson: {
          type: 'object',
          required: [
            'tags',
            'frontmatter',
            'stat',
            'path',
            'content',
          ],
          properties: {
            tags: {
              type: 'array',
              items: {
                type: 'string',
              },
            },
            frontmatter: {
              type: 'object',
            },
            stat: {
              type: 'object',
              required: [
                'ctime',
                'mtime',
                'size',
              ],
              properties: {
                ctime: {
                  type: 'number',
                },
                mtime: {
                  type: 'number',
                },
                size: {
                  type: 'number',
                },
              },
            },
            path: {
              type: 'string',
            },
            content: {
              type: 'string',
            },
          },
        },
        Error: {
          type: 'object',
          properties: {
            message: {
              type: 'string',
              description: 'Message describing the error.',
              example: 'A brief description of the error.',
            },
            errorCode: {
              type: 'number',
              description: 'A 5-digit error code uniquely identifying this particular type of error.\n',
              example: 40149,
            },
          },
        },
      },
    },
    security: [
      {
        apiKeyAuth: [],
      },
    ],
    paths: {
      '/active/': {
        get: Get {
          tags: ['Active File'],
          summary: 'Return the content of the active file open in Obsidian.\n',
          description: 'Returns the content of the currently active file in Obsidian.\n\nIf you specify the header `Accept: application/vnd.olrapi.note+json`, will return a JSON representation of your note including parsed tag and frontmatter data as well as filesystem metadata.  See "responses" below for details.\n',
        },
        put: Put {
          tags: [
            'Active File',
          ],
          summary: 'Update the content of the active file open in Obsidian.\n',
        },
        post: Post {
          tags: [
            'Active File',
          ],
          summary: 'Append content to the active file open in Obsidian.\n',
          description: "Appends content to the end of the currently-open note.\n\nIf you would like to insert text relative to a particular heading instead of appending to the end of the file, see 'patch'.\n",
        },
        patch: Patch {
          tags: [
            'Active File',
          ],
          summary: 'Partially update content in the currently open note.\n',
          description: 'Inserts content into the currently-open note relative to a heading, block refeerence, or frontmatter field within that document.\n\n' + Patch.description,
        },
        delete: Delete {
          tags: [
            'Active File',
          ],
          summary: 'Deletes the currently-active file in Obsidian.\n',
        },
      },
      '/vault/{filename}': {
        get: Get {
          tags: [
            'Vault Files',
          ],
          summary: 'Return the content of a single file in your vault.\n',
          description: 'Returns the content of the file at the specified path in your vault should the file exist.\n\nIf you specify the header `Accept: application/vnd.olrapi.note+json`, will return a JSON representation of your note including parsed tag and frontmatter data as well as filesystem metadata.  See "responses" below for details.\n',
          parameters+: [ParamPath],
        },
        put: Put {
          tags: [
            'Vault Files',
          ],
          summary: 'Create a new file in your vault or update the content of an existing one.\n',
          description: 'Creates a new file in your vault or updates the content of an existing one if the specified file already exists.\n',
          parameters+: [ParamPath],
        },
        post: Post {
          tags: [
            'Vault Files',
          ],
          summary: 'Append content to a new or existing file.\n',
          description: "Appends content to the end of an existing note. If the specified file does not yet exist, it will be created as an empty file.\n\nIf you would like to insert text relative to a particular heading, block reference, or frontmatter field instead of appending to the end of the file, see 'patch'.\n",
          parameters+: [ParamPath],
        },
        patch: Patch {
          tags: [
            'Vault Files',
          ],
          summary: 'Partially update content in an existing note.\n',
          description: 'Inserts content into an existing note relative to a heading, block refeerence, or frontmatter field within that document.\n\n' + Patch.description,
          parameters+: [ParamPath],
        },
        delete: Delete {
          tags: [
            'Vault Files',
          ],
          summary: 'Delete a particular file in your vault.\n',
          parameters: Delete.parameters + [ParamPath],
        },
      },
      '/vault/': {
        get: {
          tags: [
            'Vault Directories',
          ],
          summary: 'List files that exist in the root of your vault.\n',
          description: 'Lists files in the root directory of your vault.\n\nNote: that this is exactly the same API endpoint as the below "List files that exist in the specified directory." and exists here only due to a quirk of this particular interactive tool.\n',
          responses: {
            '200': {
              description: 'Success',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      files: {
                        type: 'array',
                        items: {
                          type: 'string',
                        },
                      },
                    },
                  },
                  example: {
                    files: [
                      'mydocument.md',
                      'somedirectory/',
                    ],
                  },
                },
              },
            },
            '404': {
              description: 'Directory does not exist',
              content: {
                'application/json': {
                  schema: {
                    '$ref': '#/components/schemas/Error',
                  },
                },
              },
            },
          },
        },
      },
      '/vault/{pathToDirectory}/': {
        get: {
          tags: [
            'Vault Directories',
          ],
          summary: 'List files that exist in the specified directory.\n',
          parameters: [
            {
              name: 'pathToDirectory',
              'in': 'path',
              description: 'Path to list files from (relative to your vault root).  Note that empty directories will not be returned.\n\nNote: this particular interactive tool requires that you provide an argument for this field, but the API itself will allow you to list the root folder of your vault. If you would like to try listing content in the root of your vault using this interactive tool, use the above "List files that exist in the root of your vault" form above.\n',
              required: true,
              schema: {
                type: 'string',
                format: 'path',
              },
            },
          ],
          responses: {
            '200': {
              description: 'Success',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      files: {
                        type: 'array',
                        items: {
                          type: 'string',
                        },
                      },
                    },
                  },
                  example: {
                    files: [
                      'mydocument.md',
                      'somedirectory/',
                    ],
                  },
                },
              },
            },
            '404': {
              description: 'Directory does not exist',
              content: {
                'application/json': {
                  schema: {
                    '$ref': '#/components/schemas/Error',
                  },
                },
              },
            },
          },
        },
      },
      '/periodic/{period}/': {
        get: Get {
          tags: [
            'Periodic Notes',
          ],
          summary: 'Get current periodic note for the specified period.\n',
          parameters+: [ParamPeriod],
        },
        put: Put {
          tags: [
            'Periodic Notes',
          ],
          summary: 'Update the content of the current periodic note for the specified period.\n',
          parameters+: [ParamPeriod],
        },
        post: Post {
          tags: [
            'Periodic Notes',
          ],
          summary: 'Append content to the current periodic note for the specified period.\n',
          description: 'Note that this will create the relevant periodic note if necessary.\n',
          parameters+: [ParamPeriod],
        },
        patch: Patch {
          tags: [
            'Periodic Notes',
          ],
          summary: 'Partially update content in the current periodic note for the specified period.\n',
          description: 'Inserts content into the current periodic note for the specified period relative to a heading, block refeerence, or frontmatter field within that document.\n\n' + Patch.description,
          parameters+: [ParamPeriod],
        },
        delete: Delete {
          tags: [
            'Periodic Notes',
          ],
          summary: 'Delete the current periodic note for the specified period.\n',
          parameters+: [ParamPeriod],
        },
      },
      '/periodic/{period}/{year}/{month}/{day}/': {
        get: Get {
          tags: [
            'Periodic Notes',
          ],
          summary: 'Get the periodic note for the specified period and date.\n',
          parameters+: [ParamYear, ParamMonth, ParamDay, ParamPeriod],
        },
        put: Put {
          tags: [
            'Periodic Notes',
          ],
          summary: 'Update the content of the periodic note for the specified period and date.\n',
          parameters+: [ParamYear, ParamMonth, ParamDay, ParamPeriod],
        },
        post: Post {
          tags: [
            'Periodic Notes',
          ],
          summary: 'Append content to the periodic note for the specified period and date.\n',
          description: 'This will create the relevant periodic note if necessary.\n',
          parameters+: [ParamYear, ParamMonth, ParamDay, ParamPeriod],
        },
        patch: Patch {
          tags: [
            'Periodic Notes',
          ],
          summary: 'Partially update content in the periodic note for the specified period and date.\n',
          description: 'Inserts content into a periodic note relative to a heading, block refeerence, or frontmatter field within that document.\n\n' + Patch.description,
          parameters+: [ParamYear, ParamMonth, ParamDay, ParamPeriod],
        },
        delete: Delete {
          tags: [
            'Periodic Notes',
          ],
          summary: 'Delete the periodic note for the specified period and date.\n',
          description: 'Deletes the periodic note for the specified period.\n',
          parameters+: [ParamYear, ParamMonth, ParamDay, ParamPeriod],
        },
      },
      '/commands/': {
        get: {
          tags: [
            'Commands',
          ],
          summary: 'Get a list of available commands.\n',
          responses: {
            '200': {
              description: 'A list of available commands.',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      commands: {
                        type: 'array',
                        items: {
                          type: 'object',
                          properties: {
                            id: {
                              type: 'string',
                            },
                            name: {
                              type: 'string',
                            },
                          },
                        },
                      },
                    },
                  },
                  example: {
                    commands: [
                      {
                        id: 'global-search:open',
                        name: 'Search: Search in all files',
                      },
                      {
                        id: 'graph:open',
                        name: 'Graph view: Open graph view',
                      },
                    ],
                  },
                },
              },
            },
          },
        },
      },
      '/commands/{commandId}/': {
        post: {
          tags: [
            'Commands',
          ],
          summary: 'Execute a command.\n',
          parameters: [
            {
              name: 'commandId',
              'in': 'path',
              description: 'The id of the command to execute',
              required: true,
              schema: {
                type: 'string',
              },
            },
          ],
          responses: {
            '204': {
              description: 'Success',
            },
            '404': {
              description: 'The command you specified does not exist.',
              content: {
                'application/json': {
                  schema: {
                    '$ref': '#/components/schemas/Error',
                  },
                },
              },
            },
          },
        },
      },
      '/search/': {
        post: {
          tags: [
            'Search',
          ],
          summary: 'Search for documents matching a specified search query\n',
          description: "Evaluates a provided query against each file in your vault.\n\nThis endpoint supports multiple query formats.  Your query should be specified in your request's body, and will be interpreted according to the `Content-type` header you specify from the below options.Additional query formats may be added in the future.\n\n# Dataview DQL (`application/vnd.olrapi.dataview.dql+txt`)\n\nAccepts a `TABLE`-type Dataview query as a text string.  See [Dataview](https://blacksmithgu.github.io/obsidian-dataview/query/queries/)'s query documentation for information on how to construct a query.\n\n# JsonLogic (`application/vnd.olrapi.jsonlogic+json`)\n\nAccepts a JsonLogic query specified as JSON.  See [JsonLogic](https://jsonlogic.com/operations.html)'s documentation for information about the base set of operators available, but in addition to those operators the following operators are available:\n\n- `glob: [PATTERN, VALUE]`: Returns `true` if a string matches a glob pattern.  E.g.: `{\"glob\": [\"*.foo\", \"bar.foo\"]}` is `true` and `{\"glob\": [\"*.bar\", \"bar.foo\"]}` is `false`.\n- `regexp: [PATTERN, VALUE]`: Returns `true` if a string matches a regular expression.  E.g.: `{\"regexp\": [\".*\\.foo\", \"bar.foo\"]` is `true` and `{\"regexp\": [\".*\\.bar\", \"bar.foo\"]}` is `false`.\n\nReturns only non-falsy results.  \"Non-falsy\" here treats the following values as \"falsy\":\n\n- `false`\n- `null` or `undefined`\n- `0`\n- `[]`\n- `{}`\n\nFiles are represented as an object having the schema described\nin the Schema named 'NoteJson' at the bottom of this page.\nUnderstanding the shape of a JSON object from a schema can be\ntricky; so you may find it helpful to examine the generated metadata\nfor individual files in your vault to understand exactly what values\nare returned.  To see that, access the `GET` `/vault/{filePath}`\nroute setting the header:\n`Accept: application/vnd.olrapi.note+json`.  See examples below\nfor working examples of queries performing common search operations.\n",
          requestBody: {
            required: true,
            content: {
              'application/vnd.olrapi.dataview.dql+txt': {
                schema: {
                  type: 'object',
                  externalDocs: {
                    url: 'https://blacksmithgu.github.io/obsidian-dataview/query/queries/',
                  },
                },
                examples: {
                  find_fields_by_tag: {
                    summary: 'List data from files having the #game tag.',
                    value: 'TABLE\n  time-played AS "Time Played",\n  length AS "Length",\n  rating AS "Rating"\nFROM #game\nSORT rating DESC\n',
                  },
                },
              },
              'application/vnd.olrapi.jsonlogic+json': {
                schema: {
                  type: 'object',
                  externalDocs: {
                    url: 'https://jsonlogic.com/operations.html',
                  },
                },
                examples: {
                  find_by_frontmatter_value: {
                    summary: 'Find notes having a certain frontmatter field value.',
                    value: '{\n  "==": [\n    {"var": "frontmatter.myField"},\n    "myValue"\n  ]\n}\n',
                  },
                  find_by_frontmatter_url_glob: {
                    summary: 'Find notes having URL or a matching URL glob frontmatter field.',
                    value: '{\n  "or": [\n    {"===": [{"var": "frontmatter.url"}, "https://myurl.com/some/path/"]},\n    {"glob": [{"var": "frontmatter.url-glob"}, "https://myurl.com/some/path/"]}\n  ]\n}\n',
                  },
                  find_by_tag: {
                    summary: 'Find notes having a certain tag',
                    value: '{\n  "in": [\n    "myTag",\n    {"var": "tags"}\n  ]\n}\n',
                  },
                },
              },
            },
          },
          responses: {
            '200': {
              description: 'Success',
              content: {
                'application/json': {
                  schema: {
                    type: 'array',
                    items: {
                      type: 'object',
                      required: [
                        'filename',
                        'result',
                      ],
                      properties: {
                        filename: {
                          type: 'string',
                          description: 'Path to the matching file',
                        },
                        result: {
                          oneOf: [
                            {
                              type: 'string',
                            },
                            {
                              type: 'number',
                            },
                            {
                              type: 'array',
                            },
                            {
                              type: 'object',
                            },
                            {
                              type: 'boolean',
                            },
                          ],
                        },
                      },
                    },
                  },
                },
              },
            },
            '400': {
              description: 'Bad request.  Make sure you have specified an acceptable\nContent-Type for your search query.\n',
              content: {
                'application/json': {
                  schema: {
                    '$ref': '#/components/schemas/Error',
                  },
                },
              },
            },
          },
        },
      },
      '/search/simple/': {
        post: {
          tags: [
            'Search',
          ],
          summary: 'Search for documents matching a specified text query\n',
          parameters: [
            {
              name: 'query',
              'in': 'query',
              description: 'Your search query',
              required: true,
              schema: {
                type: 'string',
              },
            },
            {
              name: 'contextLength',
              'in': 'query',
              description: 'How much context to return around the matching string',
              required: false,
              schema: {
                type: 'number',
                default: 100,
              },
            },
          ],
          responses: {
            '200': {
              description: 'Success',
              content: {
                'application/json': {
                  schema: {
                    type: 'array',
                    items: {
                      type: 'object',
                      properties: {
                        filename: {
                          type: 'string',
                          description: 'Path to the matching file',
                        },
                        score: {
                          type: 'number',
                        },
                        matches: {
                          type: 'array',
                          items: {
                            type: 'object',
                            required: [
                              'match',
                              'context',
                            ],
                            properties: {
                              match: {
                                type: 'object',
                                required: [
                                  'start',
                                  'end',
                                ],
                                properties: {
                                  start: {
                                    type: 'number',
                                  },
                                  end: {
                                    type: 'number',
                                  },
                                },
                              },
                              context: {
                                type: 'string',
                              },
                            },
                          },
                        },
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
      '/search/fulltext/': {
        post: {
          tags: [
            'Search',
          ],
          summary: 'Perform advanced fulltext search with context snippets and filters\n',
          description: 'Performs a comprehensive fulltext search across your vault with advanced options including regex support, file filtering, path restrictions, context windows, and case sensitivity controls. This search uses Obsidian\'s vault APIs to provide consistent and secure search functionality.\n\n## Features:\n\n- **Query Types**: Literal text search with regex support\n- **Context Windows**: Configurable character context around matches\n- **File Filtering**: Search specific file extensions or all files\n- **Path Restrictions**: Limit search to specific vault folders\n- **Case Sensitivity**: Optional case-sensitive or case-insensitive search\n- **Security**: Prevents directory traversal and unauthorized access\n\n## Examples:\n\n- Basic search: `{"query": "obsidian vault", "contextLength": 100}`\n- Regex search: `{"query": "\\\\w+@\\\\w+\\\\.\\\\w+", "useRegex": true, "contextLength": 150}`\n- Advanced search: `{"query": "project timeline", "path": "work/projects/", "fileExtension": ".md", "contextLength": 250, "caseSensitive": true}`\n',
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: [
                    'query',
                  ],
                  properties: {
                    query: {
                      type: 'string',
                      description: 'The search query string. Can be literal text or regex pattern.',
                      example: 'obsidian vault',
                    },
                    contextLength: {
                      type: 'number',
                      description: 'Number of characters to include before and after each match for context.',
                      default: 200,
                      example: 100,
                    },
                    useRegex: {
                      type: 'boolean',
                      description: 'Whether to treat the query as a regular expression pattern.',
                      default: false,
                      example: false,
                    },
                    path: {
                      type: 'string',
                      description: 'Restrict search to files within this path (relative to vault root). Must not contain ".." or be an absolute path.',
                      example: 'notes/',
                    },
                    fileExtension: {
                      type: 'string',
                      description: 'File extension to search. Use ".md" for markdown files, ".*" for all files, or specify custom extensions like ".txt".',
                      default: '.md',
                      example: '.md',
                    },
                    caseSensitive: {
                      type: 'boolean',
                      description: 'Whether the search should be case-sensitive.',
                      default: false,
                      example: false,
                    },
                  },
                },
                examples: {
                  basic_search: {
                    summary: 'Basic text search',
                    value: {
                      query: 'obsidian vault',
                      contextLength: 100,
                    },
                  },
                  regex_search: {
                    summary: 'Regex pattern search for email addresses',
                    value: {
                      query: '\\\\w+@\\\\w+\\\\.\\\\w+',
                      useRegex: true,
                      contextLength: 150,
                    },
                  },
                  advanced_search: {
                    summary: 'Advanced search with all features',
                    value: {
                      query: 'project timeline',
                      path: 'work/projects/',
                      fileExtension: '.md',
                      contextLength: 250,
                      caseSensitive: true,
                      useRegex: false,
                    },
                  },
                },
              },
            },
          },
          responses: {
            '200': {
              description: 'Successful search with results',
              content: {
                'application/json': {
                  schema: {
                    type: 'array',
                    items: {
                      type: 'object',
                      required: [
                        'filename',
                        'matches',
                      ],
                      properties: {
                        filename: {
                          type: 'string',
                          description: 'Path to the file containing matches (relative to vault root)',
                          example: 'notes/getting-started.md',
                        },
                        matches: {
                          type: 'array',
                          description: 'Array of matches found in the file',
                          items: {
                            type: 'object',
                            required: [
                              'line',
                              'snippet',
                              'matchStart',
                              'matchEnd',
                            ],
                            properties: {
                              line: {
                                type: 'number',
                                description: '1-based line number where the match was found',
                                example: 3,
                              },
                              snippet: {
                                type: 'string',
                                description: 'Context snippet containing the match',
                                example: 'Welcome to your Obsidian vault! This powerful tool helps you organize notes.',
                              },
                              matchStart: {
                                type: 'number',
                                description: 'Character position where the match starts within the snippet',
                                example: 20,
                              },
                              matchEnd: {
                                type: 'number',
                                description: 'Character position where the match ends within the snippet',
                                example: 34,
                              },
                            },
                          },
                        },
                      },
                    },
                  },
                  examples: {
                    search_results: {
                      summary: 'Example search results',
                      value: [
                        {
                          filename: 'notes/getting-started.md',
                          matches: [
                            {
                              line: 3,
                              snippet: 'Welcome to your Obsidian vault! This powerful tool helps you organize notes.',
                              matchStart: 20,
                              matchEnd: 34,
                            },
                          ],
                        },
                        {
                          filename: 'projects/work-notes.md',
                          matches: [
                            {
                              line: 5,
                              snippet: 'The Obsidian vault system allows you to manage your knowledge effectively.',
                              matchStart: 4,
                              matchEnd: 18,
                            },
                          ],
                        },
                      ],
                    },
                  },
                },
              },
            },
            '400': {
              description: 'Bad request - invalid parameters',
              content: {
                'application/json': {
                  schema: {
                    '$ref': '#/components/schemas/Error',
                  },
                  examples: {
                    missing_query: {
                      summary: 'Missing required query parameter',
                      value: {
                        errorCode: 40000,
                        message: 'Bad Request\\nQuery parameter is required',
                      },
                    },
                    invalid_path: {
                      summary: 'Invalid path with directory traversal attempt',
                      value: {
                        errorCode: 40000,
                        message: 'Bad Request\\nSearch path must be relative and within vault bounds',
                      },
                    },
                  },
                },
              },
            },
            '401': {
              description: 'Unauthorized - missing or invalid API key',
              content: {
                'application/json': {
                  schema: {
                    '$ref': '#/components/schemas/Error',
                  },
                },
              },
            },
            '500': {
              description: 'Internal server error during search',
              content: {
                'application/json': {
                  schema: {
                    '$ref': '#/components/schemas/Error',
                  },
                  examples: {
                    search_failed: {
                      summary: 'Search operation failed',
                      value: {
                        errorCode: 50001,
                        message: 'The search operation failed due to an internal error.\\nSearch failed: [specific error details]',
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
      '/open/{filename}': {
        post: {
          tags: [
            'Open',
          ],
          summary: 'Open the specified document in the Obsidian user interface.\n',
          description: 'Note: Obsidian will create a new document at the path you have\nspecified if such a document did not already exist.\n',
          parameters: [
            {
              name: 'filename',
              'in': 'path',
              description: 'Path to the file to return (relative to your vault root).\n',
              required: true,
              schema: {
                type: 'string',
                format: 'path',
              },
            },
            {
              name: 'newLeaf',
              'in': 'query',
              description: 'Open this as a new leaf?',
              required: false,
              schema: {
                type: 'boolean',
              },
            },
          ],
          responses: {
            '200': {
              description: 'Success',
            },
          },
        },
      },
      '/': {
        get: {
          tags: [
            'System',
          ],
          summary: 'Returns basic details about the server.\n',
          description: 'Returns basic details about the server as well as your authentication status.\n\nThis is the only API request that does *not* require authentication.\n',
          responses: {
            '200': {
              description: 'Success',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      ok: {
                        type: 'string',
                        description: "'OK'",
                      },
                      versions: {
                        type: 'object',
                        properties: {
                          obsidian: {
                            type: 'string',
                            description: 'Obsidian plugin API version',
                          },
                          'self': {
                            type: 'string',
                            description: 'Plugin version.',
                          },
                        },
                      },
                      service: {
                        type: 'string',
                        description: "'Obsidian Local REST API'",
                      },
                      authenticated: {
                        type: 'boolean',
                        description: 'Is your current request authenticated?',
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
      '/openapi.yaml': {
        get: {
          tags: [
            'System',
          ],
          summary: 'Returns OpenAPI YAML document describing the capabilities of this API.\n',
          responses: {
            '200': {
              description: 'Success',
            },
          },
        },
      },
      '/obsidian-local-rest-api.crt': {
        get: {
          tags: [
            'System',
          ],
          summary: 'Returns the certificate in use by this API.\n',
          responses: {
            '200': {
              description: 'Success',
            },
          },
        },
      },
    },
  },
  quote_keys=false,
  indent_array_in_object=true,
)
