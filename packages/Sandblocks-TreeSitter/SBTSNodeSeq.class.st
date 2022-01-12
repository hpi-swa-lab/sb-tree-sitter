Class {
	#name : #SBTSNodeSeq,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'elements'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeSeq >> elements [

	^ elements
]

{ #category : #'as yet unclassified' }
SBTSNodeSeq >> elements: aCollection [

	elements := aCollection
]

{ #category : #'as yet unclassified' }
SBTSNodeSeq >> printOn: aStream [

	aStream nextPut: $(.
	self elements do: [:alt | aStream print: alt] separatedBy: [aStream nextPutAll: ' '].
	aStream nextPut: $)
]
