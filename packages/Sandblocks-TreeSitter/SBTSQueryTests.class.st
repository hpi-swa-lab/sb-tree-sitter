Class {
	#name : #SBTSQueryTests,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Tests'
}

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testCaptureOptional [

	| factory |
	factory := SBMetaBlockFactory new.
	self assert: (SBTSQuery new
		execute: '((comment) (identifier (test))? @id)'
		against: (SBInlineBlockSequence new addAllMorphsBack: {
			SBInlineBlockSymbol new type: 'comment' factory: factory.
			SBInlineBlockSymbol new type: 'identifier' factory: factory})
		capturesDo: [:c | self assert: (c includesKey: 'id') not]).
	self assert: (SBTSQuery new
		execute: '((comment) (identifier)? @id)'
		against: (SBInlineBlockSequence new addAllMorphsBack: {
			SBInlineBlockSymbol new type: 'comment' factory: factory.
			SBInlineBlockSymbol new type: 'test' factory: factory.
			SBInlineBlockSymbol new type: 'identifier' factory: factory})
		capturesDo: [:c | self assert: 'identifier' equals: (c at: 'id') type])
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testIgnoresComments [

	| structure |
	structure := SBInlineBlockSymbol new type: 'identifier' factory: nil.
	self assert: (SBTSQuery new
		execute: '(identifier) @id
; comment
(number) @num'
		against: structure
		capturesDo: [:c |
			self assert: (c includesKey: 'id').
			self assert: structure equals: (c at: 'id').
			self deny: (c includesKey: 'num')])
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testMatchAlternativeAnonymousNodesWithCaptures [

	| structure |
	structure := SBInlineBlockLabel new label: 'a'.
	self assert: (SBTSQuery new execute: '["a" "b" "c"] @keyword' against: structure capturesDo: [:c |
		self assert: (c includesKey: 'keyword').
		self assert: structure equals: (c at: 'keyword')])
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testMatchAlternativeSymbols [

	self assert: (SBTSQuery new
		execute: '[(identifier) (number)]'
		against: (SBInlineBlockSymbol new type: 'number' factory: nil)
		capturesDo: [:c | ]).
	self assert: (SBTSQuery new
		execute: '[(identifier) (number)]'
		against: (SBInlineBlockSymbol new type: 'identifier' factory: nil)
		capturesDo: [:c | ]).
	self deny: (SBTSQuery new
		execute: '[(identifier) (number)]'
		against: (SBInlineBlockSymbol new type: 'string' factory: nil)
		capturesDo: [:c | ])
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testMatchAnonymousNode [

	self assert: (SBTSQuery new execute: '"a"' against: (SBInlineBlockLabel new label: 'a') capturesDo: [:c | ])
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testMatchAnyChild [

	| factory |
	factory := SBMetaBlockFactory new.
	self assert: (SBTSQuery new
		execute: '(array (identifier))'
		against: ((SBInlineBlockSymbol new type: 'array' factory: factory)
			addMorphBack: (SBInlineBlockSymbol new type: 'number' factory: factory);
			addMorphBack: (SBInlineBlockSymbol new type: 'identifier' factory: factory))
		capturesDo: [:c | ])
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testMatchFieldName [

	| factory |
	factory := SBMetaBlockFactory new.
	self assert: (SBTSQuery new
		execute: '(call function: (identifier))'
		against: ((SBInlineBlockSymbol new type: 'call' factory: factory) addMorphBack: (SBInlineBlockSymbol new
			type: 'identifier' factory: factory;
			field: 'function'))
		capturesDo: [:c | ])
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testMatchMultiple [

	| structure |
	structure := SBInlineBlockSymbol new type: 'identifier' factory: nil.
	self assert: (SBTSQuery new execute: '(identifier) @id (number) @num' against: structure capturesDo: [:c |
		self assert: (c includesKey: 'id').
		self assert: structure equals: (c at: 'id').
		self deny: (c includesKey: 'num')])
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testMatchNestedSymbols [

	| factory |
	factory := SBMetaBlockFactory new.
	self assert: (SBTSQuery new
		execute: '(array (identifier))'
		against: ((SBInlineBlockSymbol new type: 'array' factory: factory) addMorphBack: (SBInlineBlockRepeat new addMorphBack: (SBInlineBlockSymbol new type: 'identifier' factory: factory)))
		capturesDo: [:c | ]).
	self deny: (SBTSQuery new
		execute: '(array (identifier))'
		against: ((SBInlineBlockSymbol new type: 'array' factory: factory) addMorphBack: (SBInlineBlockRepeat new addMorphBack: (SBInlineBlockSymbol new type: 'number' factory: factory)))
		capturesDo: [:c | ])
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testMatchNestedSymbolsWithCaptures [

	| factory structure |
	factory := SBMetaBlockFactory new.
	structure := (SBInlineBlockSymbol new type: 'array' factory: factory) addMorphBack: (SBInlineBlockRepeat new addMorphBack: (SBInlineBlockSymbol new type: 'identifier' factory: factory)).
	self assert: (SBTSQuery new execute: '(array (identifier) @i) @a' against: structure capturesDo: [:c |
		self assert: structure equals: (c at: 'a').
		self assert: structure firstSubmorph firstSubmorph equals: (c at: 'i')])
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testMatchOptional [

	| factory |
	factory := SBMetaBlockFactory new.
	self assert: (SBTSQuery new
		execute: '(identifier)?'
		against: (SBInlineBlockSymbol new
			type: 'abc' factory: factory;
			yourself)
		capturesDo: [:c | ]).
	self assert: (SBTSQuery new
		execute: '(identifier)?'
		against: (SBInlineBlockSymbol new
			type: 'identifier' factory: factory;
			yourself)
		capturesDo: [:c | ])
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testMatchPredicate [

	| factory |
	factory := SBMetaBlockFactory new.
	self assert: (SBTSQuery new
		execute: '(identifier) @a (#match? @a "a")'
		against: (SBInlineBlockSymbol new
			type: 'identifier' factory: factory block: (SBInlineBlockText new contents: 'a');
			yourself)
		capturesDo: [:c | ]).
	self deny: (SBTSQuery new
		execute: '(identifier) @a (#match? @a "a")'
		against: (SBInlineBlockSymbol new
			type: 'identifier' factory: factory block: (SBInlineBlockText new contents: 'b');
			yourself)
		capturesDo: [:c | ])
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testMatchRequiresField [

	| factory |
	factory := SBMetaBlockFactory new.
	self deny: (SBTSQuery new
		execute: '(call function: (identifier))'
		against: ((SBInlineBlockSymbol new type: 'call' factory: factory) addMorphBack: (SBInlineBlockSymbol new type: 'identifier' factory: factory))
		capturesDo: [:c | ])
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testMatchSequence [

	| factory |
	factory := SBMetaBlockFactory new.
	self assert: (SBTSQuery new
		execute: '((comment) (identifier))'
		against: (SBInlineBlockSequence new addAllMorphsBack: {
			SBInlineBlockSymbol new type: 'comment' factory: factory.
			SBInlineBlockSymbol new type: 'identifier' factory: factory})
		capturesDo: [:c | ])
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testMatchSequenceWithCaptures [

	| structure factory |
	factory := SBMetaBlockFactory new.
	structure := SBInlineBlockSequence new addAllMorphsBack: {
		SBInlineBlockSymbol new type: 'comment' factory: factory.
		SBInlineBlockSymbol new type: 'identifier' factory: factory}.
	self assert: (SBTSQuery new execute: '((comment) @c (identifier) @i)' against: structure capturesDo: [:c |
		self assert: (c includesKey: 'c').
		self assert: structure firstSubmorph equals: (c at: 'c').
		self assert: (c includesKey: 'i')])
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testMatchSkipCaptures [

	self assert: (SBTSQuery new
		execute: '[(identifier) (number)] (identifier) @tag'
		against: (SBInlineBlockSymbol new type: 'number' factory: nil)
		capturesDo: [:c | self assert: c isEmpty])
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testMatchSymbol [

	self assert: (SBTSQuery new
		execute: '(identifier)'
		against: (SBInlineBlockSymbol new type: 'identifier' factory: nil)
		capturesDo: [:c | ]).
	self deny: (SBTSQuery new
		execute: '(identifier1)'
		against: (SBInlineBlockSymbol new type: 'identifier' factory: nil)
		capturesDo: [:c | ]).
	self deny: (SBTSQuery new
		execute: '(identifier1)'
		against: (SBInlineBlockLabel new label: 'label')
		capturesDo: [:c | ])
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testMatchSymbolWithCapture [

	| structure |
	structure := SBInlineBlockSymbol new type: 'identifier' factory: nil.
	self assert: (SBTSQuery new execute: '(identifier) @id' against: structure capturesDo: [:c |
		self assert: (c includesKey: 'id').
		self assert: structure equals: (c at: 'id')])
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testMatchWildcard [

	| factory structure |
	factory := SBMetaBlockFactory new.
	structure := (SBInlineBlockSymbol new type: 'pair' factory: factory) addMorphBack: (SBInlineBlockSymbol new
		type: 'identifier' factory: factory;
		field: 'key').
	self assert: (SBTSQuery new
		execute: '(pair
  key: (_) @keyword)'
		against: structure
		capturesDo: [:c | self assert: structure firstSubmorph equals: (c at: 'keyword')])
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testMatchWithAlias [

	| factory |
	factory := SBMetaBlockFactory new.
	self assert: (SBTSQuery new
		execute: '(property_identifier)'
		against: (SBInlineBlockSymbol new
			type: 'identifier' factory: factory;
			alias: 'property_identifier';
			yourself)
		capturesDo: [:c | ])
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testMatchWithStringCompare [

	self assert: (SBTSQuery new
		execute: '(identifier) ="id"'
		against: ((SBInlineBlockSymbol new type: 'identifier' factory: nil) addMorphBack: (SBInlineBlockText new contents: 'id'))
		capturesDo: [:c | ]).
	self deny: (SBTSQuery new
		execute: '(identifier) ="id"'
		against: ((SBInlineBlockSymbol new type: 'identifier' factory: nil) addMorphBack: (SBInlineBlockText new contents: 'ida'))
		capturesDo: [:c | ])
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testParse [

	| expr |
	expr := (SBTSQuery new prepare: '(class (identifier) ="abc" @c ((a) (b)))?') expressions first.
	
	self assert: expr structure: {#class -> SBTSQueryRepeat. #type -> $?}.
	self assert: expr element structure: {#class -> SBTSQueryNesting}.
	self
		assert: expr element elements first
		structure: {#class -> SBTSQueryElement. #contents -> 'class'}.
	self
		assert: expr element elements second
		structure: {#class -> SBTSQueryCapture. #contents -> '@c'}.
	self
		assert: expr element elements second element
		structure: {#class -> SBTSQueryStringMatch. #contents -> '="abc"'}.
	self assert: expr element elements second element element structure: {#class -> SBTSQueryNesting}.
	self
		assert: expr element elements second element element elements first
		structure: {#class -> SBTSQueryElement. #contents -> 'identifier'}.
	self assert: expr element elements third structure: {#class -> SBTSQuerySequence}
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testParseFields [

	| element |
	element := (SBTSQuery new prepare: '(array field: (identifier) @i)') expressions first.
	self assert: element structure: {#class -> SBTSQueryNesting}.
	self assert: element elements second structure: {#class -> SBTSQueryCapture}.
	self assert: element elements second element structure: {#class -> SBTSQueryField}.
	self assert: element elements second element element structure: {#class -> SBTSQueryNesting}
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testParsePredicate [

	| element |
	element := (SBTSQuery new prepare: '(abc) @a (#match? @a "a")') expressions second.
	self assert: element structure: {#class -> SBTSQueryPredicate}.
	
	element := (SBTSQuery new prepare: '(#is-not? local)') expressions first.
	self assert: element structure: {#class -> SBTSQueryPredicate}
]

{ #category : #'as yet unclassified' }
SBTSQueryTests >> testParseTopLevelCaptures [

	| element |
	element := (SBTSQuery new prepare: '(array (identifier) @i) @a') expressions first.
	self assert: element structure: {#class -> SBTSQueryCapture}
]
