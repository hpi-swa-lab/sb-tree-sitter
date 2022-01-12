Class {
	#name : #SBTSNodeLabel,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'label'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

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
