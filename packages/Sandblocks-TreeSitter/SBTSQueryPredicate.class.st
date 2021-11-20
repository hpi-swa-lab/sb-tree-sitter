Class {
	#name : #SBTSQueryPredicate,
	#superclass : #SBTSQueryNode,
	#instVars : [
		'elements'
	],
	#category : #'Sandblocks-TreeSitter-Query'
}

{ #category : #'as yet unclassified' }
SBTSQueryPredicate >> elements [

	^ elements
]

{ #category : #'as yet unclassified' }
SBTSQueryPredicate >> elements: aCollection [

	elements := aCollection
]

{ #category : #'as yet unclassified' }
SBTSQueryPredicate >> evaluateAgainst: aBlock captures: aDictionary [
	" ignored as optional, verified after evaluating using verify: "

	^ nil
]

{ #category : #'as yet unclassified' }
SBTSQueryPredicate >> isOptional [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSQueryPredicate >> predicatesOn: stream [

	stream nextPut: self
]

{ #category : #'as yet unclassified' }
SBTSQueryPredicate >> verify: aDictionary [

	| element argument predicate |
	predicate := (self elements first isKindOf: SBTSQueryCapture) ifTrue: [self elements first element contents] ifFalse: [self elements first contents].
	
	(#('#match?' '#eq?') includes: predicate) ifTrue: [
		element := aDictionary at: self elements first contents allButFirst ifAbsent: [^ true].
		argument := self elements second contents allButFirst allButLast.
	
		^ predicate caseOf: {
			['#match?'] -> [element contents matchesRegex: argument].
			['#eq?'] -> [element contents = argument]}].
	
	" unknown predicate, just pass "
	^ true
]
