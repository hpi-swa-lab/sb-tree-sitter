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

{ #category : #failures }
SBTSParseInputTest >> expectedFailures [

	^ SBToggledCode comment: '' active: 1 do: {
		[#()].
		[#(#testWrapBlock #testWrapBinaryExpression #testWrapArray #testDenyNumber #testCreateTrue #testCreateNumber #testCreateByteArrayAndNumber #testCreateArraySimple #testCreateArrayAndIdentifier #testCreateArray #testCreateAmbiguousIdentifier)]}
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
	results := SBTSInputParser new optionsForTemplate: (self nodeForRule: 'primary') given: 't'.
	
	self assert: 3 equals: results size.
	self
		assert: #('identifier' 'true' 'thisContext') asSet
		equals: (results collect: [:choice | choice child child type] as: Set)
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateArray [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (self nodeForRule: 'primary')
		given: '{'.
	self assert: 1 equals: results size.
	self assert: 'dynamic_array' equals: results first child child type
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
	
	results := SBTSInputParser new optionsForTemplate: (self nodeForRule: 'primary') given: '{'.
	self assert: 1 equals: results size
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateByteArrayAndNumber [

	| results |
	results := SBTSInputParser new optionsForTemplate: (self nodeForRule: 'byte_array') given: '#[1'.
	self assert: 1 equals: results size
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateNumber [

	| results |
	results := SBTSInputParser new optionsForTemplate: (self nodeForRule: 'primary') given: '1'.
	self assert: 1 equals: results size.
	self assert: 'number' equals: results first child child type
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testCreateTrue [

	| results |
	results := SBTSInputParser new optionsForTemplate: (self nodeForRule: 'primary') given: 'true'.
	
	self assert: 2 equals: results size.
	self
		assert: #('identifier' 'true') asSet
		equals: (results collect: [:choice | choice child child type] as: Set)
]

{ #category : #'tests - create' }
SBTSParseInputTest >> testDenyNumber [

	| results |
	results := SBTSInputParser new optionsForTemplate: (self nodeForRule: 'primary') given: '1a'.
	self assert: 0 equals: results size
]

{ #category : #'tests - wrap' }
SBTSParseInputTest >> testWrapArray [

	| stmt results |
	stmt := self statement: 'number' with: '123'.
	results := SBTSInputParser new
		optionsFor: stmt child child child child child child
		given: '{'
		before: true.
	self assert: 1 equals: results size.
	self assert: 'dynamic_array' equals: results first child child child child child child type
]

{ #category : #'tests - wrap' }
SBTSParseInputTest >> testWrapBinaryExpression [

	| stmt results |
	stmt := self statement: 'number' with: '123'.
	results := SBTSInputParser new
		optionsFor: stmt child child child child child child
		given: '+'
		before: false.
	self assert: 1 equals: results size
]

{ #category : #'tests - wrap' }
SBTSParseInputTest >> testWrapBlock [

	| stmt results |
	stmt := self statement: 'number' with: '123'.
	results := SBTSInputParser new
		optionsFor: stmt child child child child child child
		given: '['
		before: true.
	self assert: 1 equals: results size
]

{ #category : #'tests - wrap' }
SBTSParseInputTest >> testWrapByteArray [

	| stmt results |
	stmt := self statement: 'identifier' with: 'abc'.
	results := SBTSInputParser new
		optionsFor: stmt child child child child child child
		given: '#['
		before: true.
	self assert: #() equals: results
]
