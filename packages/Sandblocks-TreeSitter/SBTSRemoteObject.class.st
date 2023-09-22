Class {
	#name : #SBTSRemoteObject,
	#superclass : #Dictionary,
	#instVars : [
		'type',
		'value'
	],
	#category : #'Sandblocks-TreeSitter-LanguageClient'
}

{ #category : #'as yet unclassified' }
SBTSRemoteObject >> printOn: aStream [

	aStream nextPutAll: self type.
	
	self type = self value ifFalse: [
		aStream nextPut: $ .
		aStream nextPutAll: self value]
]

{ #category : #'as yet unclassified' }
SBTSRemoteObject >> type [

	^ type
]

{ #category : #'as yet unclassified' }
SBTSRemoteObject >> type: aString [

	type := aString
]

{ #category : #'as yet unclassified' }
SBTSRemoteObject >> value [

	^ value
]

{ #category : #'as yet unclassified' }
SBTSRemoteObject >> value: aString [

	value := aString
]
