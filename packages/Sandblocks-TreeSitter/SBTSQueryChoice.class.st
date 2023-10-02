Class {
	#name : #SBTSQueryChoice,
	#superclass : #SBTSQueryNode,
	#instVars : [
		'elements'
	],
	#category : #'Sandblocks-TreeSitter-Query'
}

{ #category : #'as yet unclassified' }
SBTSQueryChoice >> elements [

	^ elements
]

{ #category : #'as yet unclassified' }
SBTSQueryChoice >> elements: aCollection [

	elements := aCollection
]

{ #category : #'as yet unclassified' }
SBTSQueryChoice >> evaluateAgainst: aBlock captures: aDictionary [

	self elements do: [:element | | captures |
		captures := aDictionary species new.
		(element evaluateAgainst: aBlock captures: captures) ifNotNil: [
			aDictionary addAll: (captures isDictionary ifTrue: [captures associations] ifFalse: [captures]).
			^ aBlock]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSQueryChoice >> predicatesOn: stream [

	self elements do: [:el | el predicatesOn: stream]
]
