Class {
	#name : #SBTSNodeLabel,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'label'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #copying }
SBTSNodeLabel >> basicCopy [

	^ super basicCopy label: self label
]

{ #category : #query }
SBTSNodeLabel >> childrenForQuery [

	^ #()
]

{ #category : #query }
SBTSNodeLabel >> childrenForQueryDo: aBlock [

	aBlock value: self
]

{ #category : #accessing }
SBTSNodeLabel >> contents [

	^ self label
]

{ #category : #copying }
SBTSNodeLabel >> copy [

	self assert: self isConcrete.
	^ self basicCopy
]

{ #category : #testing }
SBTSNodeLabel >> isTSLabel [

	^ true
]

{ #category : #accessing }
SBTSNodeLabel >> label [

	^ label
]

{ #category : #accessing }
SBTSNodeLabel >> label: aString [

	label := aString
]

{ #category : #accessing }
SBTSNodeLabel >> maxChildren [

	^ 0
]

{ #category : #printing }
SBTSNodeLabel >> printOn: aStream [

	aStream nextPut: $".
	aStream nextPutAll: self label.
	aStream nextPut: $"
]

{ #category : #parsing }
SBTSNodeLabel >> resultsFor: aParser [

	| labelStream oldPosition |
	labelStream := self label readStream.
	oldPosition := aParser position.
	[aParser atEnd or: [labelStream atEnd]] whileFalse: [
		labelStream next = aParser next ifFalse: [
			aParser position: oldPosition.
			^ #noMatch]].
	^ {self makeConcrete parser: aParser copy}
]

{ #category : #parsing }
SBTSNodeLabel >> takeNodesFrom: aParser [

	^ (aParser atEnd not and: [aParser peek = self label])
		ifTrue: [
			aParser next.
			{self makeConcrete parser: aParser copy}]
		ifFalse: [#noMatch]
]

{ #category : #printing }
SBTSNodeLabel >> writeSourceOn: aStream indent: aNumber [

	aStream nextPutAll: self label
]
