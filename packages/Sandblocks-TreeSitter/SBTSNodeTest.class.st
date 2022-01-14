Class {
	#name : #SBTSNodeTest,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #helper }
SBTSNodeTest >> bodyForRule: aString [

	^ SBTSSmalltalk instance bodyNodeForRule: aString
]

{ #category : #helper }
SBTSNodeTest >> nodeForRule: aString [

	^ SBTSNodeSymbol new
		type: aString factory: SBTSSmalltalk instance;
		addChild: (SBTSSmalltalk instance bodyNodeForRule: aString)
]

{ #category : #helper }
SBTSNodeTest >> statement: aTypeString with: aContentsString [

	| stmt expr primary leaf |
	stmt := (self nodeForRule: 'statement') copy.
	stmt addChild: stmt body copy.
	
	expr := (self nodeForRule: 'expression') copy.
	expr addChild: expr body copy.
	
	primary := (self nodeForRule: 'primary') copy.
	primary addChild: primary body copy.
	
	leaf := (self nodeForRule: aTypeString) copy.
	leaf addChild: leaf body copy.
	leaf child contents: aContentsString.
	
	stmt child addChild: expr.
	expr child addChild: primary.
	primary child addChild: leaf.
	
	^ stmt
]

{ #category : #'tests - create' }
SBTSNodeTest >> testCreateAmbiguousIdentifier [

	| results |
	results := SBTSParser new optionsForTemplate: (self bodyForRule: 'primary') given: 't'.
	
	self assert: 3 equals: results size.
	self
		assert: #('identifier' 'true' 'thisContext') asSet
		equals: (results collect: [:choice | choice child type] as: Set)
]

{ #category : #'tests - create' }
SBTSNodeTest >> testCreateArray [

	| results |
	results := SBTSParser new optionsForTemplate: (self bodyForRule: 'primary') given: '{'.
	self assert: 1 equals: results size.
	self assert: 'dynamic_array' equals: results first child type
]

{ #category : #'tests - create' }
SBTSNodeTest >> testCreateArrayAndIdentifier [

	| results |
	results := SBTSParser new
		optionsForTemplate: (self bodyForRule: 'dynamic_array')
		given: '{a'.
	self assert: 1 equals: results size.
	
	results := SBTSParser new
		optionsForTemplate: (self bodyForRule: 'dynamic_array')
		given: '{a'.
	self assert: 1 equals: results size
]

{ #category : #'tests - create' }
SBTSNodeTest >> testCreateArraySimple [

	| results |
	results := SBTSParser new
		optionsForTemplate: (self bodyForRule: 'dynamic_array')
		given: '{'.
	self assert: 1 equals: results size.
	
	results := SBTSParser new optionsForTemplate: (self bodyForRule: 'primary') given: '{'.
	self assert: 1 equals: results size
]

{ #category : #'tests - create' }
SBTSNodeTest >> testCreateByteArrayAndNumber [

	| results |
	results := SBTSParser new optionsForTemplate: (self bodyForRule: 'byte_array') given: '#[1'.
	self assert: 1 equals: results size
]

{ #category : #'tests - create' }
SBTSNodeTest >> testCreateNumber [

	| results |
	results := SBTSParser new optionsForTemplate: (self bodyForRule: 'primary') given: '1'.
	self assert: 1 equals: results size.
	self assert: 'number' equals: results first child type
]

{ #category : #'tests - create' }
SBTSNodeTest >> testCreateTrue [

	| results |
	results := SBTSParser new optionsForTemplate: (self bodyForRule: 'primary') given: 'true'.
	
	self assert: 2 equals: results size.
	self
		assert: #('identifier' 'true') asSet
		equals: (results collect: [:choice | choice child type] as: Set)
]

{ #category : #'tests - create' }
SBTSNodeTest >> testDenyNumber [

	| results |
	results := SBTSParser new optionsForTemplate: (self bodyForRule: 'primary') given: '1a'.
	self assert: 0 equals: results size
]

{ #category : #'tests - wrap' }
SBTSNodeTest >> testWrapArray [

	| stmt results |
	stmt := self statement: 'number' with: '123'.
	results := SBTSParser new optionsFor: stmt given: '{' before: true.
	self assert: 1 equals: results size.
	self assert: 'dynamic_array' equals: results first child child child child child child type
]

{ #category : #'tests - wrap' }
SBTSNodeTest >> testWrapBinaryExpression [

	| expr number primary |
	expr := SBTSNodeSymbol new type: 'expression' factory: SBTSSmalltalk instance.
	primary := SBTSNodeSymbol new type: 'primary' factory: SBTSSmalltalk instance.
	number := SBTSNodeSymbol new type: 'number' factory: SBTSSmalltalk instance.
	self assert: nil equals: (self input: '+' in: primary withNested: number inputBefore: false).
	self
		assert: 'expression'
		equals: (self input: '+' in: expr withNested: number inputBefore: false) type
]

{ #category : #'tests - wrap' }
SBTSNodeTest >> testWrapBlock [

	| expr number primary |
	expr := SBTSNodeSymbol new type: 'expression' factory: SBTSSmalltalk instance.
	primary := SBTSNodeSymbol new type: 'primary' factory: SBTSSmalltalk instance.
	number := SBTSNodeSymbol new type: 'number' factory: SBTSSmalltalk instance.
	self assert: nil equals: (self input: '[' in: primary withNested: number inputBefore: true).
	self
		assert: 'expression'
		equals: (self input: '[' in: expr withNested: number inputBefore: false) type
]
