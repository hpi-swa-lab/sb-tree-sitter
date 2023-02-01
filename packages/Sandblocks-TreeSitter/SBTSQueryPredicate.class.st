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
SBTSQueryPredicate >> verify: aCollection [

	| element argument predicate |
	predicate := (self elements first isKindOf: SBTSQueryCapture)
		ifTrue: [self elements first element contents]
		ifFalse: [self elements first contents].
	
	(#('#match?' '#eq?') includes: predicate) ifTrue: [ | matches key contents |
		key := self elements first contents allButFirst.
		element := (aCollection isDictionary ifTrue: [aCollection associations] ifFalse: [aCollection]) detect: [:pair | pair key = key] ifFound: #value ifNone: [^ true].
		contents := element contents ifNil: [''].
		argument := self elements second contents allButFirst allButLast.
		
		matches := predicate caseOf: {
			['#match?'] -> [contents matchesRegex: argument].
			['#eq?'] -> [contents = argument]}.
		matches ifFalse: [aCollection isDictionary ifTrue: [aCollection removeKey: key] ifFalse: [aCollection removeAllSuchThat: [:pair | pair key = key]]].
		^ matches].
	
	" unknown predicate, just pass "
	^ true
]
