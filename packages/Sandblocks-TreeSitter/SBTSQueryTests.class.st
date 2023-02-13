Class {
	#name : #SBTSQueryTests,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Tests'
}

{ #category : #tests }
SBTSQueryTests >> testCaptureOptional [

	self assert: (SBTSQuery new
		execute: '((number) (identifier (test))? @id)'
		against: (SBJavascript parseToplevel: '2; a')
		capturesDo: [:c | self assert: (c includesKey: 'id') not]).
	self assert: (SBTSQuery new
		execute: '((number) (identifier)? @id)'
		against: (SBJavascript parseToplevel: '2; ''a''; a')
		capturesDo: [:c | self assert: 'identifier' equals: (c at: 'id') type])
]

{ #category : #tests }
SBTSQueryTests >> testDoesNotCaptureMismatches [

	SBTSQuery new
		execute: '(not_array (identifier) @a)'
		against: (SBJavascript parseToplevel: '[a]') childSandblocks first
		capturesDo: [:c | self assert: c isEmpty]
]

{ #category : #tests }
SBTSQueryTests >> testIgnoresComments [

	| structure |
	structure := SBJavascript parseExpression: 'a'.
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
	self assert: (block childSandblocks first childSandblocks second matchesQuery: '(class_body member: (field_definition) member: (method_definition))').
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
	self assert: (block matchesQuery: '(program (object (pair key: [(property_identifier) (string)] ="headers")))')
]

{ #category : #tests }
SBTSQueryTests >> testMatchAll [

	| q array |
	array := SBJavascript parseExpression: '[a, a, a]'.
	
	q := SBTSQuery new.
	q prepare: '(array (identifier) @i)'.
	self
		assert: (array childSandblocks collect: [:i | #i -> i] as: OrderedCollection)
		equals: (q executeCaptureAgainst: array)
]

{ #category : #tests }
SBTSQueryTests >> testMatchAlternativeAnonymousNodesWithCaptures [

	| structure |
	structure := SBTSTextMorph new
		contents: 'a';
		slot: (SBTSSlot with: (SBTSNodeLabel new label: 'a')).
	self assert: (SBTSQuery new execute: '["a" "b" "c"] @keyword' against: structure capturesDo: [:c |
		self assert: (c includesKey: 'keyword').
		self assert: structure equals: (c at: 'keyword')])
]

{ #category : #tests }
SBTSQueryTests >> testMatchAlternativeSymbols [

	self assert: (SBTSQuery new
		execute: '[(identifier) (number)]'
		against: (SBJavascript parseExpression: '1')
		capturesDo: [:c | ]).
	self assert: (SBTSQuery new
		execute: '[(identifier) (number)]'
		against: (SBJavascript parseExpression: 'a')
		capturesDo: [:c | ]).
	self deny: (SBTSQuery new
		execute: '[(identifier) (number)]'
		against: (SBJavascript parseExpression: '''a''')
		capturesDo: [:c | ])
]

{ #category : #tests }
SBTSQueryTests >> testMatchAnonymousNode [

	self assert: (SBTSQuery new
		execute: '"a"'
		against: (SBTSTextMorph new
			contents: 'a';
			slot: (SBTSSlot with: (SBTSNodeLabel new label: 'a')))
		capturesDo: [:c | ])
]

{ #category : #tests }
SBTSQueryTests >> testMatchAnyChild [

	self assert: (SBTSQuery new
		execute: '(array (identifier))'
		against: (SBJavascript parseExpression: '[2, a]')
		capturesDo: [:c | ])
]

{ #category : #tests }
SBTSQueryTests >> testMatchConsecutive [

	self assert: ((SBJavascript parseExpression: '[1, 2]') matchesQuery: '(array (number) (number))')
]

{ #category : #tests }
SBTSQueryTests >> testMatchFieldName [

	self assert: (SBTSQuery new
		execute: '(call_expression function: (identifier))'
		against: (SBJavascript parseExpression: 'a()')
		capturesDo: [:c | ])
]

{ #category : #tests }
SBTSQueryTests >> testMatchMultiple [

	| structure |
	structure := SBJavascript parseExpression: 'a'.
	self assert: (SBTSQuery new execute: '(identifier) @id (number) @num' against: structure capturesDo: [:c |
		self assert: (c includesKey: 'id').
		self assert: structure equals: (c at: 'id').
		self deny: (c includesKey: 'num')])
]

{ #category : #tests }
SBTSQueryTests >> testMatchNestedSymbols [

	self assert: (SBTSQuery new
		execute: '(array (identifier))'
		against: (SBJavascript parseToplevel: '[a]') childSandblocks first
		capturesDo: [:c | ]).
	self deny: (SBTSQuery new
		execute: '(array (identifier))'
		against: (SBJavascript parseToplevel: '[1]') childSandblocks first
		capturesDo: [:c | ])
]

{ #category : #tests }
SBTSQueryTests >> testMatchNestedSymbolsWithCaptures [

	| structure |
	structure := (SBJavascript parseToplevel: '[a]') childSandblocks first.
	self assert: (SBTSQuery new execute: '(array (identifier) @i) @a' against: structure capturesDo: [:c |
		self assert: structure equals: (c at: 'a').
		self assert: structure childSandblocks first equals: (c at: 'i')])
]

{ #category : #tests }
SBTSQueryTests >> testMatchOptional [

	self assert: (SBTSQuery new
		execute: '(identifier)?'
		against: (SBJavascript parseExpression: '''a''')
		capturesDo: [:c | ]).
	self assert: (SBTSQuery new
		execute: '(identifier)?'
		against: (SBJavascript parseExpression: 'a')
		capturesDo: [:c | ])
]

{ #category : #tests }
SBTSQueryTests >> testMatchPositioned [

	self assert: ((SBJavascript parseExpression: '["a", 2]') matchesQuery: '(array (number) (string))').
	self deny: ((SBJavascript parseExpression: '["a", 2]') matchesQuery: '(array . (number) (string))').
	self assert: ((SBJavascript parseExpression: '[2, "a"]') matchesQuery: '(array . (number) (string))').
	
	self deny: ((SBJavascript parseExpression: '["a", 2]') matchesQuery: '(array (number) (string) .)').
	self assert: ((SBJavascript parseExpression: '[2, "a"]') matchesQuery: '(array (number) (string) .)')
]

{ #category : #tests }
SBTSQueryTests >> testMatchPredicate [

	self assert: (SBTSQuery new
		execute: '(identifier) @a (#match? @a "a")'
		against: (SBJavascript parseExpression: 'a')
		capturesDo: [:c | ]).
	self deny: (SBTSQuery new
		execute: '(identifier) @a (#match? @a "a")'
		against: (SBJavascript parseExpression: 'b')
		capturesDo: [:c | ])
]

{ #category : #tests }
SBTSQueryTests >> testMatchRequiresField [

	self deny: (SBTSQuery new
		execute: '(call_expression functionXX: (identifier))'
		against: (SBJavascript parseExpression: 'a()')
		capturesDo: [:c | ])
]

{ #category : #tests }
SBTSQueryTests >> testMatchSequence [

	self assert: (SBTSQuery new
		execute: '((identifier) (number))'
		against: (SBJavascript parseToplevel: 'a; 2')
		capturesDo: [:c | ])
]

{ #category : #tests }
SBTSQueryTests >> testMatchSequenceWithCaptures [

	| structure |
	structure := SBJavascript parseToplevel: 'a; 2'.
	self assert: (SBTSQuery new execute: '((identifier) @c (number) @i)' against: structure capturesDo: [:c |
		self assert: (c includesKey: 'c').
		self assert: structure firstSubmorph equals: (c at: 'c').
		self assert: (c includesKey: 'i')])
]

{ #category : #tests }
SBTSQueryTests >> testMatchSkipCaptures [

	self assert: (SBTSQuery new
		execute: '[(identifier) (number)] (identifier) @tag'
		against: (SBJavascript parseExpression: '12')
		capturesDo: [:c | self assert: c isEmpty])
]

{ #category : #tests }
SBTSQueryTests >> testMatchSymbol [

	self assert: (SBTSQuery new
		execute: '(identifier)'
		against: (SBJavascript parseExpression: 'a')
		capturesDo: [:c | ]).
	self deny: (SBTSQuery new
		execute: '(identifier1)'
		against: (SBJavascript parseExpression: 'a')
		capturesDo: [:c | ]).
	self deny: (SBTSQuery new
		execute: '(identifier1)'
		against: (SBTSTextMorph new
			contents: 'a';
			slot: (SBTSSlot with: (SBTSNodeLabel new label: 'a')))
		capturesDo: [:c | ])
]

{ #category : #tests }
SBTSQueryTests >> testMatchSymbolWithCapture [

	| structure |
	structure := SBJavascript parseExpression: 'a'.
	self assert: (SBTSQuery new execute: '(identifier) @id' against: structure capturesDo: [:c |
		self assert: (c includesKey: 'id').
		self assert: structure equals: (c at: 'id')])
]

{ #category : #tests }
SBTSQueryTests >> testMatchWildcard [

	| structure |
	structure := (SBJavascript parseExpression: '{a: 1}') childSandblocks first.
	self assert: (SBTSQuery new
		execute: '(pair
  key: (_) @keyword)'
		against: structure
		capturesDo: [:c | self assert: structure firstSubmorph equals: (c at: 'keyword')])
]

{ #category : #tests }
SBTSQueryTests >> testMatchWithAlias [

	self assert: (SBTSQuery new
		execute: '(property_identifier)'
		against: (SBJavascript parseToplevel: '{a: 1}') firstDeepChild
		capturesDo: [:c | ])
]

{ #category : #tests }
SBTSQueryTests >> testMatchWithStringCompare [

	self assert: (SBTSQuery new
		execute: '(identifier) ="id" @a'
		against: (SBJavascript parseExpression: 'id')
		capturesDo: [:c | self assert: 'id' equals: (c at: 'a') contents]).
	self deny: (SBTSQuery new
		execute: '(identifier) ="id" @a'
		against: (SBJavascript parseExpression: 'ida')
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
SBTSQueryTests >> testParsePositionConstraints [

	| element |
	element := (SBTSQuery new prepare: '(array . (a))') expressions first.
	self assert: element structure: {#class -> SBTSQueryNesting}.
	self
		assert: element elements second
		structure: {#class -> SBTSQueryPositionConstraint. #constraint -> #first}.
	self assert: element elements second element structure: {#class -> SBTSQueryNesting}.
	
	element := (SBTSQuery new prepare: '(array (a) .)') expressions first.
	self
		assert: element elements second
		structure: {#class -> SBTSQueryPositionConstraint. #constraint -> #last}
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
