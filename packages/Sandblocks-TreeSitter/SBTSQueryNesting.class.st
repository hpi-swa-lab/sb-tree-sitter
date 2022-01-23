Class {
	#name : #SBTSQueryNesting,
	#superclass : #SBTSQueryNode,
	#instVars : [
		'elements'
	],
	#category : #'Sandblocks-TreeSitter-Query'
}

{ #category : #'as yet unclassified' }
SBTSQueryNesting >> elements [

	^ elements
]

{ #category : #'as yet unclassified' }
SBTSQueryNesting >> elements: aCollection [

	elements := aCollection
]

{ #category : #'as yet unclassified' }
SBTSQueryNesting >> evaluateAgainst: aBlock captures: aDictionary [

	| block |
	block := ((aBlock isKindOf: SBInlineBlockSymbol) and: [self type = '_' or: [(aBlock typeCompatibleWith: self type) or: [aBlock alias = self type]]])
		ifTrue: [aBlock]
		ifFalse: [nil].
	
	elements size > 1 ifTrue: [
		((SBTSQuerySequence new elements: elements allButFirst)
			evaluateAgainst: aBlock
			captures: aDictionary) ifNil: [^ nil]].
	
	^ block
]

{ #category : #'as yet unclassified' }
SBTSQueryNesting >> predicatesOn: stream [

	self elements do: [:el | el predicatesOn: stream]
]

{ #category : #'as yet unclassified' }
SBTSQueryNesting >> type [

	^ self elements first contents
]
