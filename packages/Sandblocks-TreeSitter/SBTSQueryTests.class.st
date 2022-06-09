Class {
	#name : #SBTSQueryTests,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Tests'
}

{ #category : #tests }
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

{ #category : #tests }
SBTSQueryTests >> testDoesNotCaptureMismatches [

	| factory |
	factory := SBMetaBlockFactory new.
	SBTSQuery new
		execute: '(array (identifier) @a)'
		against: ((SBInlineBlockSymbol new type: 'not_array' factory: factory) addMorphBack: (SBInlineBlockRepeat new addMorphBack: (SBInlineBlockSymbol new type: 'identifier' factory: factory)))
		capturesDo: [:c | self assert: c isEmpty]
]

{ #category : #tests }
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

{ #category : #'tests - languages' }
SBTSQueryTests >> testJsClass [

	| block |
	block := SBJavascript parseToplevel: 'class A {
example
}'.
	self assert: (block matchesQuery: '(program (class_declaration (class_body
	member: (field_definition
		property: (property_identifier)))))').
	
	block := SBJavascript parseToplevel: 'class A {
example = {}
render() {}
}'.
	self assert: (block matchesQuery: '(program (class_declaration
name: (identifier)
(class_body
	member: (field_definition
		property: (property_identifier)
		value: (object))
	member: (method_definition
		name: (property_identifier)))))')
]

{ #category : #'tests - languages' }
SBTSQueryTests >> testJsPairMatchString [

	| block |
	block := SBJavascript parseToplevel: '{headers: "abc"}'.
	self assert: (block matchesQuery: '(program (object (pair key: [(identifier) (string)] ="headers")))')
]

{ #category : #tests }
SBTSQueryTests >> testMatchAlternativeAnonymousNodesWithCaptures [

	| structure |
	structure := SBInlineBlockLabel new label: 'a'.
	self assert: (SBTSQuery new execute: '["a" "b" "c"] @keyword' against: structure capturesDo: [:c |
		self assert: (c includesKey: 'keyword').
		self assert: structure equals: (c at: 'keyword')])
]

{ #category : #tests }
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

{ #category : #tests }
SBTSQueryTests >> testMatchAnonymousNode [

	self assert: (SBTSQuery new execute: '"a"' against: (SBInlineBlockLabel new label: 'a') capturesDo: [:c | ])
]

{ #category : #tests }
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

{ #category : #tests }
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

{ #category : #tests }
SBTSQueryTests >> testMatchMultiple [

	| structure |
	structure := SBInlineBlockSymbol new type: 'identifier' factory: nil.
	self assert: (SBTSQuery new execute: '(identifier) @id (number) @num' against: structure capturesDo: [:c |
		self assert: (c includesKey: 'id').
		self assert: structure equals: (c at: 'id').
		self deny: (c includesKey: 'num')])
]

{ #category : #tests }
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

{ #category : #tests }
SBTSQueryTests >> testMatchNestedSymbolsWithCaptures [

	| factory structure |
	factory := SBMetaBlockFactory new.
	structure := (SBInlineBlockSymbol new type: 'array' factory: factory) addMorphBack: (SBInlineBlockRepeat new addMorphBack: (SBInlineBlockSymbol new type: 'identifier' factory: factory)).
	self assert: (SBTSQuery new execute: '(array (identifier) @i) @a' against: structure capturesDo: [:c |
		self assert: structure equals: (c at: 'a').
		self assert: structure firstSubmorph firstSubmorph equals: (c at: 'i')])
]

{ #category : #tests }
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

{ #category : #tests }
SBTSQueryTests >> testMatchPredicate [

	| factory |
	factory := SBMetaBlockFactory new.
	self assert: (SBTSQuery new
		execute: '(identifier) @a (#match? @a "a")'
		against: (SBInlineBlockSymbol new
			type: 'identifier' factory: factory block: (SBInlineBlockText new regexString: 'a'; contents: 'a');
			yourself)
		capturesDo: [:c | ]).
	self deny: (SBTSQuery new
		execute: '(identifier) @a (#match? @a "a")'
		against: (SBInlineBlockSymbol new
			type: 'identifier' factory: factory block: (SBInlineBlockText new regexString: 'b'; contents: 'b');
			yourself)
		capturesDo: [:c | ])
]

{ #category : #tests }
SBTSQueryTests >> testMatchRequiresField [

	| factory |
	factory := SBMetaBlockFactory new.
	self deny: (SBTSQuery new
		execute: '(call function: (identifier))'
		against: ((SBInlineBlockSymbol new type: 'call' factory: factory) addMorphBack: (SBInlineBlockSymbol new type: 'identifier' factory: factory))
		capturesDo: [:c | ])
]

{ #category : #tests }
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

{ #category : #tests }
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

{ #category : #tests }
SBTSQueryTests >> testMatchSkipCaptures [

	self assert: (SBTSQuery new
		execute: '[(identifier) (number)] (identifier) @tag'
		against: (SBInlineBlockSymbol new type: 'number' factory: nil)
		capturesDo: [:c | self assert: c isEmpty])
]

{ #category : #tests }
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

{ #category : #tests }
SBTSQueryTests >> testMatchSymbolWithCapture [

	| structure |
	structure := SBInlineBlockSymbol new type: 'identifier' factory: nil.
	self assert: (SBTSQuery new execute: '(identifier) @id' against: structure capturesDo: [:c |
		self assert: (c includesKey: 'id').
		self assert: structure equals: (c at: 'id')])
]

{ #category : #tests }
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

{ #category : #tests }
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

{ #category : #tests }
SBTSQueryTests >> testMatchWithStringCompare [

	self assert: (SBTSQuery new
		execute: '(identifier) ="id" @a'
		against: ((SBInlineBlockSymbol new type: 'identifier' factory: nil) addMorphBack: (SBInlineBlockText new regexString: 'id'; contents: 'id'))
		capturesDo: [:c | self assert: 'id' equals: (c at: 'a') contents]).
	self deny: (SBTSQuery new
		execute: '(identifier) ="id" @a'
		against: ((SBInlineBlockSymbol new type: 'identifier' factory: nil) addMorphBack: (SBInlineBlockText new regexString: 'ida'; contents: 'ida'))
		capturesDo: [:c | self assert: c isEmpty])
]

{ #category : #tests }
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

{ #category : #tests }
SBTSQueryTests >> testParseFields [

	| element |
	element := (SBTSQuery new prepare: '(array field: (identifier) @i)') expressions first.
	self assert: element structure: {#class -> SBTSQueryNesting}.
	self assert: element elements second structure: {#class -> SBTSQueryCapture}.
	self assert: element elements second element structure: {#class -> SBTSQueryField}.
	self assert: element elements second element element structure: {#class -> SBTSQueryNesting}
]

{ #category : #tests }
SBTSQueryTests >> testParsePredicate [

	| element |
	element := (SBTSQuery new prepare: '(abc) @a (#match? @a "a")') expressions second.
	self assert: element structure: {#class -> SBTSQueryPredicate}.
	
	element := (SBTSQuery new prepare: '(#is-not? local)') expressions first.
	self assert: element structure: {#class -> SBTSQueryPredicate}
]

{ #category : #tests }
SBTSQueryTests >> testParseTopLevelCaptures [

	| element |
	element := (SBTSQuery new prepare: '(array (identifier) @i) @a') expressions first.
	self assert: element structure: {#class -> SBTSQueryCapture}
]
