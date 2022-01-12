Class {
	#name : #SBTSNodeChoice,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'alternatives'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeChoice >> alternatives [

	^ alternatives
]

{ #category : #'as yet unclassified' }
SBTSNodeChoice >> alternatives: aCollection [

	alternatives := aCollection
]

{ #category : #'as yet unclassified' }
SBTSNodeChoice >> printOn: aStream [

	aStream nextPut: $(.
	self alternatives
		do: [:alt | aStream print: alt]
		separatedBy: [aStream nextPutAll: ' | '].
	aStream nextPut: $)
]
