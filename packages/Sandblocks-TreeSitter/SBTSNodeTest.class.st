Class {
	#name : #SBTSNodeTest,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #helper }
SBTSNodeTest >> concreteNodeForRule: aString [

	| lang symbol |
	lang := SBTSSmalltalk new.
	symbol := SBTSNodeSymbol new type: aString factory: lang.
	^ symbol makeConcrete addChild: symbol bodyTemplate makeConcrete
]

{ #category : #failures }
SBTSNodeTest >> expectedFailures [

	^ SBToggledCode comment: '' active: 1 do: {
		[#()].
		[#(#testWrapBlock #testWrapBinaryExpression #testWrapArray #testDenyNumber #testCreateTrue #testCreateNumber #testCreateByteArrayAndNumber #testCreateArraySimple #testCreateArrayAndIdentifier #testCreateArray #testCreateAmbiguousIdentifier)]}
]

{ #category : #helper }
SBTSNodeTest >> nodeForRule: aString [

	| lang |
	lang := SBTSSmalltalk new.
	^ SBTSNodeSymbol new type: aString factory: lang
]

{ #category : #helper }
SBTSNodeTest >> statement: aTypeString with: aContentsString [

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
SBTSNodeTest >> testCreateAmbiguousIdentifier [

	| results |
	results := SBTSParser new optionsForTemplate: (self nodeForRule: 'primary') given: 't'.
	
	self assert: 3 equals: results size.
	self
		assert: #('identifier' 'true' 'thisContext') asSet
		equals: (results collect: [:choice | choice child child type] as: Set)
]

{ #category : #'tests - create' }
SBTSNodeTest >> testCreateArray [

	| results |
	results := SBTSParser new optionsForTemplate: (self nodeForRule: 'primary') given: '{'.
	self assert: 1 equals: results size.
	self assert: 'dynamic_array' equals: results first child child type
]

{ #category : #'tests - create' }
SBTSNodeTest >> testCreateArrayAndIdentifier [

	| results |
	"assignment gets reported as well"
	self flag: #todo.
	results := SBTSParser new
		optionsForTemplate: (self nodeForRule: 'dynamic_array')
		given: '{a'.
	self assert: 2 equals: results size.
	
	results := SBTSParser new
		optionsForTemplate: (self nodeForRule: 'dynamic_array')
		given: '{a'.
	self assert: 2 equals: results size
]

{ #category : #'tests - create' }
SBTSNodeTest >> testCreateArraySimple [

	| results |
	results := SBTSParser new
		optionsForTemplate: (self nodeForRule: 'dynamic_array')
		given: '{'.
	self assert: 1 equals: results size.
	
	results := SBTSParser new optionsForTemplate: (self nodeForRule: 'primary') given: '{'.
	self assert: 1 equals: results size
]

{ #category : #'tests - create' }
SBTSNodeTest >> testCreateByteArrayAndNumber [

	| results |
	results := SBTSParser new optionsForTemplate: (self nodeForRule: 'byte_array') given: '#[1'.
	self assert: 1 equals: results size
]

{ #category : #'tests - create' }
SBTSNodeTest >> testCreateNumber [

	| results |
	results := SBTSParser new optionsForTemplate: (self nodeForRule: 'primary') given: '1'.
	self assert: 1 equals: results size.
	self assert: 'number' equals: results first child child type
]

{ #category : #'tests - create' }
SBTSNodeTest >> testCreateTrue [

	| results |
	results := SBTSParser new optionsForTemplate: (self nodeForRule: 'primary') given: 'true'.
	
	self assert: 2 equals: results size.
	self
		assert: #('identifier' 'true') asSet
		equals: (results collect: [:choice | choice child child type] as: Set)
]

{ #category : #'tests - create' }
SBTSNodeTest >> testDenyNumber [

	| results |
	results := SBTSParser new optionsForTemplate: (self nodeForRule: 'primary') given: '1a'.
	self assert: 0 equals: results size
]

{ #category : #'tests - wrap' }
SBTSNodeTest >> testWrapArray [

	| stmt results |
	stmt := self statement: 'number' with: '123'.
	results := SBTSParser new
		optionsFor: stmt child child child child child child
		given: '{'
		before: true.
	self assert: 1 equals: results size.
	self assert: 'dynamic_array' equals: results first child child child child child child type
]

{ #category : #'tests - wrap' }
SBTSNodeTest >> testWrapBinaryExpression [

	| stmt results |
	stmt := self statement: 'number' with: '123'.
	results := SBTSParser new
		optionsFor: stmt child child child child child child
		given: '+'
		before: false.
	self assert: 1 equals: results size
]

{ #category : #'tests - wrap' }
SBTSNodeTest >> testWrapBlock [

	| stmt results |
	stmt := self statement: 'number' with: '123'.
	results := SBTSParser new
		optionsFor: stmt child child child child child child
		given: '['
		before: true.
	self assert: 1 equals: results size
]

{ #category : #'tests - wrap' }
SBTSNodeTest >> testWrapByteArray [

	| stmt results |
	stmt := self statement: 'identifier' with: 'abc'.
	results := SBTSParser new
		optionsFor: stmt child child child child child child
		given: '#['
		before: true.
	self assert: #() equals: results
]
