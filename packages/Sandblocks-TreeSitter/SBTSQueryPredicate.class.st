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
	predicate := (self elements first isKindOf: SBTSQueryCapture)
		ifTrue: [self elements first element contents]
		ifFalse: [self elements first contents].
	
	(#('#match?' '#eq?') includes: predicate) ifTrue: [ | matches key |
		key := self elements first contents allButFirst.
		element := aDictionary at: key ifAbsent: [^ true].
		argument := self elements second contents allButFirst allButLast.
		
		matches := predicate caseOf: {
			['#match?'] -> [element contents matchesRegex: argument].
			['#eq?'] -> [element contents = argument]}.
		matches ifFalse: [aDictionary removeKey: key].
		^ matches].
	
	" unknown predicate, just pass "
	^ true
]
