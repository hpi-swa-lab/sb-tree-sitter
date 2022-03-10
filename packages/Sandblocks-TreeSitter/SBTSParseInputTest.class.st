Class {
	#name : #SBTSParseInputTest,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #helper }
SBTSParseInputTest >> concreteNodeForRule: aString [

	| lang symbol |
	lang := SBTSSmalltalk new.
	symbol := SBTSNodeSymbol new type: aString factory: lang.
	^ symbol makeConcrete addChild: symbol bodyTemplate makeConcrete
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

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateAmbiguousIdentifier [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'primary')
		given: 't'.
	
	self assert: 3 equals: results size.
	self
		assert: #('identifier' 'true' 'thisContext') asSet
		equals: (results collect: [:choice | choice type] as: Set)
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateArray [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'primary')
		given: '{'.
	self assert: 1 equals: results size.
	self assert: 'dynamic_array' equals: results first type
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
	self assert: 'assignment' equals: results first childSandblocks first type.
	self assert: 3 equals: results first childSandblocks first submorphs size
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
SBTSParseInputTest >> testCreateHashBangLine [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (SBTSNodeSymbol new type: 'hash_bang_line' factory: SBJavascript instance)
		given: '#'.
	self assert: 1 equals: results size.
	self assert: 'hash_bang_line' equals: results first type.
	self assert: '#!' equals: results first contents
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateIdentifierFromStatement [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'statement')
		given: 'abc'.
	self assert: 2 equals: results size.
	self
		assert: (Set withAll: {'identifier'. 'assignment'})
		equals: (results collect: [:r | r childSandblocks first type] as: Set)
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateNumber [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'primary')
		given: '1'.
	self assert: 1 equals: results size.
	self assert: 'number' equals: results first type
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateNumberFromStatement [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'statement')
		given: '1'.
	self assert: 1 equals: results size.
	self assert: 'number' equals: results first childSandblocks first type
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateTrue [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'primary')
		given: 'true'.
	
	self assert: 2 equals: results size.
	self assert: #('identifier' 'true') asSet equals: (results collect: #type as: Set)
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testDenyNumber [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'primary')
		given: '1a'.
	self assert: 0 equals: results size
]

{ #category : #'tests - wrap' }
SBTSParseInputTest >> testWrapArray [

	| stmt results |
	stmt := (SBTSFileParser new parse: 'method 123' language: SBTSSmalltalk instance) childSandblocks second childSandblocks first.
	results := SBTSInputParser new optionsFor: stmt given: '{' before: true.
	self assert: 1 equals: results size.
	self assert: 'dynamic_array' equals: results first type.
	self assert: 3 equals: results first submorphCount
]

{ #category : #'tests - wrap' }
SBTSParseInputTest >> testWrapBinaryExpression [

	| stmt results |
	stmt := (SBTSFileParser new parse: 'method 123' language: SBTSSmalltalk instance) childSandblocks second childSandblocks first.
	results := SBTSInputParser new optionsFor: stmt given: '+' before: false.
	self assert: 1 equals: results size.
	self assert: 3 equals: results first childSandblocks size.
	self
		assert: (SBTSSmalltalk instance bodyNodeForRule: 'binary_message')
		equals: results first childSandblocks first slot lastNode parent
]

{ #category : #'tests - wrap' }
SBTSParseInputTest >> testWrapBlock [

	| stmt results |
	stmt := (SBTSFileParser new parse: 'method 123' language: SBTSSmalltalk instance) childSandblocks second childSandblocks first.
	results := SBTSInputParser new optionsFor: stmt given: '[' before: true.
	self assert: 1 equals: results size
]

{ #category : #'tests - wrap' }
SBTSParseInputTest >> testWrapByteArray [

	| stmt results |
	stmt := (SBTSFileParser new parse: 'method 123' language: SBTSSmalltalk instance) childSandblocks second childSandblocks first.
	results := SBTSInputParser new optionsFor: stmt given: '#[' before: true.
	self assert: 'byte_array' equals: results first type
]
