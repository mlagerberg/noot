import 'package:highlight/src/mode.dart';

/// Syntax highlighter for the TO-DO file format
final todo = Mode(refs: {
  'body_text': Mode(contains: [
    Mode(
        className: 'variable',
        begin: '[0-9]{1,2}:[0-9]{2}(\\s*-\\s*[0-9]{1,2}:[0-9]{2})?'),
    // timestamps
    Mode(className: 'code', begin: '`', end: '`'),
    // inline code
    Mode(className: 'link', begin: '[^\\s]+://[^\\s]+'),
    // URLs
    Mode(className: 'strong', begin: '\\*', end: '\\*'),
    // bold
    Mode(className: 'emphasis', begin: '_', end: '_'),
    // italic
    Mode(className: 'symbol', begin: '@[a-zA-Z0-9]+'),
    // @names
    Mode(className: 'comment', begin: '#[a-zA-Z0-9]+'),
    // hashtags
  ]),
  'subtask_patterns': Mode(contains: [
    // Subtask patterns for various task types
    Mode(
      begin: '^(\\s{4}|\\t)*(-)',
      className: 'name',
      contains: [
        Mode(className: 'comment', begin: '-'),
      ],
    ),
    Mode(
      begin: '^(\\s{4}|\\t)*(x)',
      className: 'keyword',
    ),
    Mode(
      begin: '^(\\s{4}|\\t)*(v)',
      className: 'name',
    ),
    Mode(
      begin: '^(\\s{4}|\\t)*(~)',
      className: 'string',
    ),
    Mode(
      begin: '^(\\s{4}|\\t)*(\\?)',
      className: 'keyword',
    ),
    Mode(
      begin: '^(\\s{4}|\\t)*(\\!)',
      className: 'keyword',
    ),
  ]),
}, aliases: [
  "txt",
  "todo"
], contains: [
  // Section Titles (=== Title === or # Title)
  Mode(
    className: 'title',
    variants: [
      Mode(begin: '(===)\\s(.*)\\s(===)', end: "\$"),
      Mode(begin: '(#+)\\s(.*)', end: "\$"),
    ],
  ),

  // Date Heading
  Mode(className: 'literal', begin: '^%[^\\n]*?(?= -|\$)'),

  // Legacy date format support (for backwards compatibility)
  Mode(
      className: 'literal',
      begin: '^(ma|di|wo|woe|do|vr|vrij|za/zo|za|zo)[a-zA-Z0-9\\s]*'),
  Mode(
      className: 'literal',
      begin: '^(Mon|Tue|Wed|Thu|Fri|Sat|Sun)[a-zA-Z0-9\\s]*'),

  // Dividers
  Mode(className: "keyword", begin: "^-{3,}\$"),
  Mode(className: "section", begin: "^={3,}\$"),

  // Task states
  // Open tasks [ ]
  Mode(
    //className: 'meta',
    begin: '(.*)\\[\\s\\]',
    returnBegin: true,
    end: '\$',
    contains: [
      Mode(className: 'comment', begin: '\\[\\s\\]', end: '\\s'),
      // Mode(ref: 'body_text')
      // Include body text elements
      Mode(
          className: 'symbol',
          begin: '[0-9]{1,2}:[0-9]{2}(\\s*-\\s*[0-9]{1,2}:[0-9]{2})?'),
      // timestamps
      Mode(className: 'code', begin: '`', end: '`'),
      // inline code
      Mode(className: 'link', begin: '[^\\s]+://[^\\s]+'),
      // URLs
      Mode(className: 'strong', begin: '\\*', end: '\\*'),
      // bold
      Mode(className: 'emphasis', begin: '_', end: '_'),
      // italic
      Mode(className: 'symbol', begin: '@[a-zA-Z0-9]+'),
      // @names
      Mode(className: 'comment', begin: '#[a-zA-Z0-9]+'),
      // hashtags
    ],
  ),

  // Completed tasks [v]
  Mode(
    className: 'comment',
    begin: '(.*)\\[(v)\\]',
    returnBegin: true,
    end: '\$',
    contains: [
      Mode(
          className: 'title',
          begin: '\\[',
          end: '\\]\\s',
          excludeBegin: true,
          excludeEnd: true)
      // Mode(className: 'name', begin: '\\[v\\]'),
    ],
  ),

  // Canceled tasks [x]
  Mode(
    className: 'comment',
    begin: '(.*)\\[(x)\\]',
    returnBegin: true,
    end: '\$',
    contains: [
      Mode(
          className: 'keyword',
          begin: '\\[',
          end: '\\]\\s',
          excludeBegin: true,
          excludeEnd: true),
    ],
  ),

  // Partially done tasks [~]
  Mode(
    className: 'string',
    begin: '(.*)\\[(~)\\]',
    returnBegin: true,
    end: '\$',
    contains: [
      Mode(
          className: 'number',
          begin: '\\[',
          end: '\\]\\s',
          excludeBegin: true,
          excludeEnd: true),
    ],
  ),

  // Maybe done tasks [?]
  Mode(
    className: 'string',
    begin: '(.*)\\[(\\?)\\]',
    returnBegin: true,
    end: '\$',
    contains: [
      Mode(
          className: 'keyword',
          begin: '\\[',
          end: '\\]\\s',
          excludeBegin: true,
          excludeEnd: true),
    ],
  ),

  // Important tasks [!]
  Mode(
    className: 'keyword',
    begin: '(.*)\\[(\\!)\\]',
    returnBegin: true,
    end: '\$',
    contains: [
      Mode(
          className: 'string',
          begin: '\\[',
          end: '\\]\\s',
          excludeBegin: true,
          excludeEnd: true),
    ],
  ),

  // Body text elements (outside of tasks)
  // Quote
  Mode(className: 'comment', begin: '^\\s*>'),
  // Timestamps
  Mode(
      className: 'symbol',
      begin: '[0-9]{1,2}:[0-9]{2}(\\s*-\\s*[0-9]{1,2}:[0-9]{2})?'),
  // Inline code
  Mode(className: 'code', begin: '`', end: '`'),
  // URLs
  Mode(className: 'link', begin: '[^\\s]+://[^\\s]+'),
  // Bold text
  Mode(className: 'strong', begin: '\\*', end: '\\*'),
  // Italic text
  Mode(className: 'emphasis', begin: '_', end: '_'),
  // @name mentions
  Mode(className: 'name', begin: '@[a-zA-Z0-9]+'),
  // Hashtags
  Mode(className: 'symbol', begin: '#[a-zA-Z0-9]+'),
]);
