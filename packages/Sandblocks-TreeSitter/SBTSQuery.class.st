Class {
	#name : #SBTSQuery,
	#superclass : #Object,
	#instVars : [
		'stream',
		'captures',
		'expressions',
		'predicates'
	],
	#category : #'Sandblocks-TreeSitter-Query'
}

{ #category : #'as yet unclassified' }
SBTSQuery >> execute: aString against: aBlock capturesDo: aClosure [

	self prepare: aString.
	^ self executeAgainst: aBlock capturesDo: aClosure
]

{ #category : #'as yet unclassified' }
SBTSQuery >> executeAgainst: aBlock capturesDo: aClosure [

	| ret target |
	target := aBlock.
	captures := Dictionary new.
	
	ret := false.
	expressions do: [:expression | | newCaptures |
		newCaptures := Dictionary new.
		(expression evaluateAgainst: aBlock captures: newCaptures)
			ifNotNil: [
				ret := true.
				captures addAll: newCaptures associations]
			ifNil: [expression isOptional ifTrue: [ret := true]]].
	
	predicates do: [:predicate | (predicate verify: captures) ifFalse: [ret := false]].
	
	aClosure cull: captures cull: ret.
	
	^ ret
]

{ #category : #'as yet unclassified' }
SBTSQuery >> executeCaptureAgainst: aBlock [

	| ret target |
	target := aBlock.
	captures := OrderedCollection new.
	
	ret := false.
	expressions do: [:expression | | newCaptures |
		newCaptures := OrderedCollection new.
		(expression evaluateAgainst: aBlock captures: newCaptures)
			ifNotNil: [
				ret := true.
				captures addAll: newCaptures]
			ifNil: [expression isOptional ifTrue: [ret := true]]].
	
	predicates do: [:predicate | (predicate verify: captures) ifFalse: [ret := false]].
	
	^ ret ifTrue: [captures] ifFalse: [{}]
]

{ #category : #'as yet unclassified' }
SBTSQuery >> expressions [

	^ expressions
]

{ #category : #'as yet unclassified' }
SBTSQuery >> parseExpression [

	| c expr |
	c := stream peek.
	c = $. ifTrue: [
		stream next.
		^ SBTSQueryPositionConstraint new constraint: #first].
	expr := (c = $( or: [c = $[])
		ifTrue: [self parseSExpression]
		ifFalse: [self parseLiteral].
	
	^ (#($+ $* $?) includes: stream peek)
		ifTrue: [
			SBTSQueryRepeat new
				type: stream next;
				element: expr]
		ifFalse: [expr]
]

{ #category : #'as yet unclassified' }
SBTSQuery >> parseLiteral [

	| contents endCheck hasClosingDelimiter |
	hasClosingDelimiter := #($" $=) includes: stream peek.
	contents := String streamContents: [:str |
		endCheck := stream peek
			caseOf: {
				[$"] -> [[:c | c = $"]].
				[$=] -> [[:c | c = $"]]}
			otherwise: [[:c | c isSeparator or: [c = $) or: [c = $( or: [c = $[ or: [c = $]]]]]]].
		stream peek = $= ifTrue: [str nextPut: stream next].
		[str nextPut: stream next] doWhileTrue: [stream peek notNil and: [(endCheck value: stream peek) not]]].
	
	hasClosingDelimiter ifTrue: [contents := contents, stream next].
	
	contents last = $: ifTrue: [^ SBTSQueryField new contents: contents].
	
	^ contents first
		caseOf: {
			[$@] -> [SBTSQueryCapture new contents: contents].
			[$=] -> [SBTSQueryStringMatch new contents: contents].
			[$"] -> [SBTSQueryLiteral new contents: contents]}
		otherwise: [SBTSQueryElement new contents: contents]
]

{ #category : #'as yet unclassified' }
SBTSQuery >> parseSExpression [

	| elements end start |
	start := SBToggledCode comment: '( or [' active: 1 do: {[stream next]}.
	end := start caseOf: {
		[$(] -> [$)].
		[$[] -> [$]]}.
	
	self skipWhitespaces.
	elements := OrderedCollection new.
	[stream peek ~= end] whileTrue: [ | next |
		self skipWhitespaces.
		next := self parseExpression.
		self skipWhitespaces.
		
		next class = SBTSQueryPositionConstraint ifTrue: [next constraint: (elements size = 1 ifTrue: [#first] ifFalse: [#last])].
		
		(elements notEmpty and: [elements last wrapsNext and: [elements last element isNil]])
			ifTrue: [elements last element: next]
			ifFalse: [
				next wrapsPrevious ifTrue: [next element: elements removeLast].
				elements add: next]].
	SBToggledCode comment: ') or ]' active: 1 do: {[stream next]}.
	
	(((elements first isKindOf: SBTSQueryCapture) and: [(elements first element isKindOf: SBTSQueryElement) and: [elements first element contents first = $#]]) or: [(elements first isKindOf: SBTSQueryElement) and: [elements first contents first = $#]]) ifTrue: [^ SBTSQueryPredicate new elements: elements].
	(elements first isKindOf: SBTSQueryElement) ifTrue: [^ SBTSQueryNesting new elements: elements].
	start = $( ifTrue: [^ SBTSQuerySequence new elements: elements].
	start = $[ ifTrue: [^ SBTSQueryChoice new elements: elements].
	self assert: false
]

{ #category : #'as yet unclassified' }
SBTSQuery >> prepare: aString [

	stream := aString readStream.
	expressions := OrderedCollection new.
	self skipWhitespaces.
	[stream atEnd] whileFalse: [ | expr |
		expr := self parseExpression.
		expr wrapsPrevious ifTrue: [expr element: expressions removeLast].
		expressions add: expr.
		self skipWhitespaces].
	predicates := Array streamContents: [:stream | expressions do: [:expr | expr predicatesOn: stream]]
]

{ #category : #'as yet unclassified' }
SBTSQuery >> skipWhitespaces [

	[stream atEnd not and: [stream peek isSeparator or: [stream peek = $;]]] whileTrue: [
		stream peek = $; ifTrue: [ | text |
			stream next.
			text := String streamContents: [:s | [({Character cr. Character lf} includes: stream peek) not and: [stream atEnd not]] whileTrue: [s nextPut: stream next]]].
		stream next]
]
