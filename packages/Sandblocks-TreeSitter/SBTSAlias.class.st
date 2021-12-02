Class {
	#name : #SBTSAlias,
	#superclass : #Object,
	#instVars : [
		'name',
		'object',
		'parentType'
	],
	#category : #'Sandblocks-TreeSitter'
}

{ #category : #'as yet unclassified' }
SBTSAlias >> name [

	^ name
]

{ #category : #'as yet unclassified' }
SBTSAlias >> name: aString [

	name := aString
]

{ #category : #'as yet unclassified' }
SBTSAlias >> object [

	^ object
]

{ #category : #'as yet unclassified' }
SBTSAlias >> object: anObject [

	object := anObject
]

{ #category : #'as yet unclassified' }
SBTSAlias >> parentType [

	^ parentType
]

{ #category : #'as yet unclassified' }
SBTSAlias >> parentType: aString [

	parentType := aString
]

{ #category : #'as yet unclassified' }
SBTSAlias >> printOn: aStream [

	aStream nextPutAll: self className.
	aStream nextPut: $(.
	aStream nextPutAll: self name.
	aStream nextPut: $)
]
