Class {
	#name : #SBTSParseInputTest,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Parser'
}

{ #category : #helper }
SBTSParseInputTest >> concreteNodeForRule: aString [

	| lang symbol |
	lang := SBTSSmalltalk new.
	symbol := SBTSNodeSymbol new type: aString factory: lang.
	^ symbol makeConcrete addChild: symbol bodyTemplate makeConcrete
]

{ #category : #failures }
SBTSParseInputTest >> expectedFailures [

	^ #(#testAssignmentPattern #testCreateMemberExpression #testDirectRecursion #testIndirectRecursion #testCreateBinaryMessage)
]

{ #category : #helper }
SBTSParseInputTest >> nodeForRule: aString [

	| lang |
	lang := SBTSSmalltalk new.
	^ SBTSNodeSymbol new type: aString factory: lang
]

{ #category : #helper }
SBTSParseInputTest >> statement: aTypeString with: aContentsString [

	| stmt expr primary leaf |
	stmt := (self concreteNodeForRule: 'statement').
	expr := (self concreteNodeForRule: 'expression').
	primary := (self concreteNodeForRule: 'primary').
	leaf := (self concreteNodeForRule: aTypeString).
	
	leaf child contents: aContentsString.
	stmt child addChild: expr.
	expr child addChild: primary.
	primary child addChild: leaf.
	
	^ stmt
]

{ #category : #'tests - wrap' }
SBTSParseInputTest >> testAssignmentPattern [

	| pattern results |
	pattern := (SBTSFileParser new
		parse: 'function(a) {}'
		language: SBJavascript instance) childSandblocks first childSandblocks first.
	results := SBTSInputParser new
		optionsFor: pattern
		given: '='
		before: {pattern}
		after: {}.
	self assert: 1 equals: results size
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateAmbiguousIdentifier [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'primary')
		given: 't'.
	
	self assert: 3 equals: results size.
	self
		assert: #('identifier' 'true' 'thisContext') asSet
		equals: (results collect: [:choice | choice first type] as: Set)
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateArray [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'primary')
		given: '{'.
	self assert: 1 equals: results size.
	self assert: 'dynamic_array' equals: results first first type
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateArrayAndIdentifier [

	| results |
	"assignment gets reported as well"
	self flag: #todo.
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'dynamic_array')
		given: '{a'.
	self assert: 2 equals: results size.
	
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'dynamic_array')
		given: '{a'.
	self assert: 2 equals: results size
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateArraySimple [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'dynamic_array')
		given: '{'.
	self assert: 1 equals: results size.
	
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'primary')
		given: '{'.
	self assert: 1 equals: results size
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateAssignment [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'statement')
		given: 'abc:'.
	self assert: 1 equals: results size.
	self assert: 'assignment' equals: results first first type.
	self assert: 3 equals: results first first submorphs size
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateBashCommand [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (SBTSNodeSymbol new type: '_statement' factory: SBBash instance)
		given: 'l'.
	self assert: (results anySatisfy: [:blocks | blocks first type = 'command'])
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateBinaryMessage [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'expression')
		given: '2+'.
	self assert: 1 equals: results size
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateByteArrayAndNumber [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'byte_array')
		given: '#[1'.
	self assert: 1 equals: results size
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateCharacter [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'primary')
		given: '$'.
	
	self assert: 1 equals: results size.
	self assert: #(#character) asSet equals: (results collect: [:r | r first type] as: Set)
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateFunction [

	| results |
	results := (SBTSInputParser new
		optionsForTemplate: (SBTSNodeSymbol new type: 'statement' factory: SBJavascript instance)
		given: 'func')
		collect: [:b | b first type]
		as: Set.
	self
		assert: #(#identifier #function #'generator_function' #'function_declaration' #'generator_function_declaration') asSet
		equals: results
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateHashBangLine [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (SBTSNodeSymbol new type: 'hash_bang_line' factory: SBJavascript instance)
		given: '#'.
	self assert: 1 equals: results size.
	self assert: 'hash_bang_line' equals: results first first type.
	self assert: '#!' equals: results first first contents
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateIdentifier [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'expression')
		given: 'test'.
	
	self assert: 1 equals: results size.
	self assert: #('identifier') asSet equals: (results collect: [:choice | choice first type] as: Set)
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateIdentifierFromStatement [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'statement')
		given: 'abc'.
	self assert: 1 equals: results size.
	self assert: 'identifier' equals: results first first type
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateJavascriptIdentifier [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (SBTSNodeSymbol new type: 'expression' factory: SBJavascript instance)
		given: 'test'.
	
	self assert: 1 equals: results size.
	self assert: #('identifier') asSet equals: (results collect: [:choice | choice first type] as: Set)
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateKeyword [

	| options |
	options := SBTSInputParser new
		optionsForTemplate: (SBTSNodeSymbol new type: 'statement' factory: SBJavascript instance)
		given: 'const '.
	self assert: 1 equals: options size
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateMemberExpression [

	| results |
	self flag: #todo.
	"will recurse on expression and thus get blocked"
	results := SBTSInputParser new
		optionsForTemplate: (SBTSNodeSymbol new type: 'statement' factory: SBJavascript instance)
		given: 'a.b'.
	self assert: 1 equals: results size.
	self assert: 'member_expression' equals: results first first type
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateNumber [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'primary')
		given: '1'.
	self assert: 1 equals: results size.
	self assert: 'number' equals: results first first type
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateNumberFromStatement [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'statement')
		given: '1'.
	self assert: 1 equals: results size.
	self assert: 'number' equals: results first first type
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateTrue [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'primary')
		given: 'true '.
	
	self assert: 1 equals: results size.
	self assert: #('true') asSet equals: (results collect: [:r | r first type] as: Set)
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testDenyNumber [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'primary')
		given: '1a'.
	self assert: 0 equals: results size
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testDirectRecursion [

	| factory results |
	factory := SBTSTestLanguage new.
	factory add: 'expr' rule: (SBTSNodeChoice new alternatives: {
		SBTSNodeSeq new elements: {
			SBTSNodeSymbol new type: 'expr' factory: factory.
			(SBTSNodeLabel new label: '+') factory: factory.
			SBTSNodeSymbol new type: 'number' factory: factory}.
		SBTSNodeSymbol new type: 'number' factory: factory}).
	factory add: 'number' rule: (SBTSNodeText new regexString: '[0-9]+').
	
	results := SBTSInputParser new
		optionsForTemplate: (SBTSNodeSymbol new type: 'expr' factory: factory)
		given: '1+2'.
	self assert: 1 equals: results size.
	self assert: {'1'. '+'. '2'} equals: (results first collect: #sourceString as: Array)
]

{ #category : #'tests - wrap' }
SBTSParseInputTest >> testIdentifierToAssignment [

	| stmt results |
	stmt := (SBTSFileParser new parse: 'method abc' language: SBTSSmalltalk instance) childSandblocks second.
	results := SBTSInputParser new optionsFor: stmt given: ':' before: {stmt} after: {}.
	self assert: 1 equals: results size.
	self assert: #assignment equals: results first first type
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testIndirectRecursion [

	| factory results |
	factory := SBTSTestLanguage new supertypes: #('expr').
	factory
		add: 'expr'
		rule: (SBTSNodeChoice new alternatives: {SBTSNodeSymbol new type: 'plus' factory: factory. SBTSNodeSymbol new type: 'number' factory: factory}).
	factory add: 'number' rule: (SBTSNodeText new regexString: '[0-9]+').
	factory add: 'plus' rule: (SBTSNodeSeq new elements: {
		SBTSNodeSymbol new type: 'expr' factory: factory.
		(SBTSNodeLabel new label: '+') factory: factory.
		SBTSNodeSymbol new type: 'expr' factory: factory}).
	
	results := SBTSInputParser new
		optionsForTemplate: (SBTSNodeSymbol new type: 'expr' factory: factory)
		given: '1+2'.
	self assert: 1 equals: results size.
	self assert: '1+2' equals: results first first sourceString
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testIndirectRecursionDoublyNested [

	| factory results |
	factory := SBTSTestLanguage new supertypes: #('expr' 'primary').
	factory add: 'expr' rule: (SBTSNodeChoice new alternatives: {
		SBTSNodeSymbol new type: 'primary' factory: factory.
		SBTSNodeSymbol new type: 'binary_expression' factory: factory}).
	factory add: 'primary' rule: (SBTSNodeChoice new alternatives: {
		SBTSNodeSymbol new type: 'call_expr' factory: factory.
		SBTSNodeSymbol new type: 'number' factory: factory}).
	factory add: 'number' rule: (SBTSNodeText new regexString: '[0-9]+').
	factory add: 'binary_expression' rule: (SBTSNodeSeq new elements: {
		SBTSNodeSymbol new type: 'expr' factory: factory.
		(SBTSNodeLabel new label: '+') factory: factory.
		SBTSNodeSymbol new type: 'expr' factory: factory}).
	factory add: 'call_expr' rule: (SBTSNodeChoice new alternatives: {
		SBTSNodeSeq new elements: {SBTSNodeSymbol new type: 'primary' factory: factory. (SBTSNodeLabel new label: '?.') factory: factory}.
		SBTSNodeSeq new elements: {SBTSNodeSymbol new type: 'expr' factory: factory. (SBTSNodeLabel new label: '()') factory: factory}}).
	
	results := SBTSInputParser new
		optionsForTemplate: (SBTSNodeSymbol new type: 'expr' factory: factory)
		given: '1+2'.
	self assert: 1 equals: results size.
	self assert: '1+2' equals: results first first sourceString
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testIndirectRecursionMultipleRules [

	| factory results |
	factory := SBTSTestLanguage new supertypes: #('expr').
	factory add: 'expr' rule: (SBTSNodeChoice new alternatives: {
		SBTSNodeSymbol new type: 'plus' factory: factory.
		SBTSNodeSymbol new type: 'minus' factory: factory.
		SBTSNodeSymbol new type: 'number' factory: factory}).
	factory add: 'number' rule: (SBTSNodeText new regexString: '[0-9]+').
	factory add: 'plus' rule: (SBTSNodeSeq new elements: {
		SBTSNodeSymbol new type: 'expr' factory: factory.
		(SBTSNodeLabel new label: '+') factory: factory.
		SBTSNodeSymbol new type: 'expr' factory: factory}).
	factory add: 'minus' rule: (SBTSNodeSeq new elements: {
		SBTSNodeSymbol new type: 'expr' factory: factory.
		(SBTSNodeLabel new label: '-') factory: factory.
		SBTSNodeSymbol new type: 'expr' factory: factory}).
	
	results := SBTSInputParser new
		optionsForTemplate: (SBTSNodeSymbol new type: 'expr' factory: factory)
		given: '1+2'.
	self assert: 1 equals: results size.
	self assert: '1+2' equals: results first first sourceString
]

{ #category : #'tests - wrap' }
SBTSParseInputTest >> testReinterpretAssignment [

	| stmt results |
	stmt := (SBTSFileParser new parse: 'let a = 5' language: SBJavascript instance) childSandblocks first.
	self assert: stmt submorphs first contents = 'let'.
	results := SBTSInputParser new
		optionsFor: stmt
		given: 'c'
		before: {}
		after: {stmt childSandblocks last}.
	self assert: 'const' equals: results first first submorphs first contents
]

{ #category : #'tests - wrap' }
SBTSParseInputTest >> testReinterpretBinaryOp [

	| stmt results |
	stmt := (SBTSFileParser new parse: 'a + b' language: SBJavascript instance) childSandblocks first.
	self assert: stmt submorphs second contents = '+'.
	results := SBTSInputParser new
		optionsFor: stmt
		given: '-'
		before: {stmt childSandblocks first}
		after: {stmt childSandblocks last}.
	self assert: #('binary_expression' 'augmented_assignment_expression') asSet equals: (results collect: [:r | r first type] as: Set).
	self assert: #('-=' '-') asSet equals: (results collect: [:r | r first submorphs second contents] as: Set)
]

{ #category : #'tests - wrap' }
SBTSParseInputTest >> testReinterpretBinaryOpNumbers [

	| stmt results |
	stmt := (SBTSFileParser new parse: '1 + 3' language: SBJavascript instance) childSandblocks first.
	self assert: stmt submorphs second contents = '+'.
	results := SBTSInputParser new
		optionsFor: stmt
		given: '-'
		before: {stmt childSandblocks first}
		after: {stmt childSandblocks last}.
	self assert: #('binary_expression') asSet equals: (results collect: [:r | r first type] as: Set).
	self assert: '-' equals: results first first submorphs second contents.
	self
		assert: '-'
		equals: results first first childSandblocks first slot nodes third parent elements second label
]

{ #category : #'tests - wrap' }
SBTSParseInputTest >> testReinterpretUnaryToKeyword [

	| message results |
	message := (SBTSFileParser new parse: 'method b msg' language: SBTSSmalltalk instance) childSandblocks second.
	results := SBTSInputParser new
		optionsFor: message
		given: 'msg:'
		before: {message childSandblocks first}
		after: {}.
	self assert: 'keyword_message' equals: results first first type
]

{ #category : #'tests - wrap' }
SBTSParseInputTest >> testWrapArray [

	| stmt results |
	stmt := (SBTSFileParser new parse: 'method 123' language: SBTSSmalltalk instance) childSandblocks second.
	results := SBTSInputParser new optionsFor: stmt given: '{' before: {} after: {stmt}.
	self assert: 1 equals: results size.
	self assert: 'dynamic_array' equals: results first first type.
	self assert: 3 equals: results first first submorphCount
]

{ #category : #'tests - wrap' }
SBTSParseInputTest >> testWrapBinaryExpression [

	| stmt results |
	stmt := (SBTSFileParser new parse: 'method 123' language: SBTSSmalltalk instance) childSandblocks second.
	results := SBTSInputParser new optionsFor: stmt given: '+' before: {stmt} after: {}.
	self assert: 1 equals: results size.
	self assert: 3 equals: results first first childSandblocks size.
	self
		assert: (SBTSSmalltalk instance bodyNodeForRule: 'binary_message')
		equals: results first first childSandblocks first slot lastNode parent parent.
	self assert: #statement equals: results first first slot lastNode type
]

{ #category : #'tests - wrap' }
SBTSParseInputTest >> testWrapBlock [

	| stmt results |
	stmt := (SBTSFileParser new parse: 'method 123' language: SBTSSmalltalk instance) childSandblocks second.
	results := SBTSInputParser new optionsFor: stmt given: '[' before: {} after: {stmt}.
	self assert: 1 equals: results size
]

{ #category : #'tests - wrap' }
SBTSParseInputTest >> testWrapByteArray [

	| stmt results |
	stmt := (SBTSFileParser new parse: 'method 123' language: SBTSSmalltalk instance) childSandblocks second.
	results := SBTSInputParser new optionsFor: stmt given: '#[' before: {} after: {stmt}.
	self assert: 'byte_array' equals: results first first type
]

{ #category : #'tests - wrap' }
SBTSParseInputTest >> testWrapJsBinaryOp [

	| program results |
	program := SBTSFileParser new parse: '1' language: SBJavascript instance.
	results := SBTSInputParser new
		optionsFor: program childSandblocks first
		given: '+2'
		before: {program childSandblocks first}
		after: {}.
	self
		assert: results first first childSandblocks second slot nodes size
		equals: results first first childSandblocks first slot nodes size
]

{ #category : #'tests - wrap' }
SBTSParseInputTest >> testWrapKeywordMessageWithGaps [

	| stmt results |
	stmt := (SBTSFileParser new parse: 'method 123' language: SBTSSmalltalk instance) childSandblocks second.
	results := SBTSInputParser new
		optionsFor: stmt
		given: (String streamContents: [:stream |
			3 timesRepeat: [
				stream
					nextPutAll: 'with:';
					nextPut: (Character value: 1)]])
		before: {stmt}
		after: {}.
	self assert: 1 equals: results size.
	self assert: 7 equals: results first first childSandblocks size.
	self assert: 3 equals: (results first first childSandblocks select: #isUnknown) size
]
