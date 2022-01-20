Class {
	#name : #SBTSNodeLabel,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'label'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeLabel >> copy [

	^ super copy label: self label
]

{ #category : #'as yet unclassified' }
SBTSNodeLabel >> label [

	^ label
]

{ #category : #'as yet unclassified' }
SBTSNodeLabel >> label: aString [

	label := aString
]

{ #category : #'as yet unclassified' }
SBTSNodeLabel >> printOn: aStream [

	aStream nextPut: $".
	aStream nextPutAll: self label.
	aStream nextPut: $"
]

{ #category : #'as yet unclassified' }
SBTSNodeLabel >> resultsFor: aParser [

	| labelStream oldPosition |
	labelStream := self label readStream.
	oldPosition := aParser position.
	[aParser atEnd or: [labelStream atEnd]] whileFalse: [
		labelStream next = aParser next ifFalse: [
			aParser position: oldPosition.
			^ #noMatch]].
	^ {self copy parser: aParser copy}
]
