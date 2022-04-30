Class {
	#name : #SBTSMemoEntry,
	#superclass : #Object,
	#instVars : [
		'answer'
	],
	#category : #'Sandblocks-TreeSitter-Parser'
}

{ #category : #'as yet unclassified' }
SBTSMemoEntry >> isLeftRecursion [

	^ answer class = SBTSRecursion
]

{ #category : #'as yet unclassified' }
SBTSMemoEntry >> leftRecursionDetected [

	self assert: self isLeftRecursion.
	^ answer head notNil
]

{ #category : #'as yet unclassified' }
SBTSMemoEntry >> parsers [

	self assert: self isLeftRecursion not.
	^ answer
]

{ #category : #'as yet unclassified' }
SBTSMemoEntry >> parsers: aCollection [

	answer := aCollection
]

{ #category : #'as yet unclassified' }
SBTSMemoEntry >> printOn: aStream [

	aStream nextPutAll: self className.
	self isLeftRecursion
		ifTrue: [
			aStream nextPutAll: (self leftRecursionDetected
				ifTrue: ['(recurDetected)']
				ifFalse: ['(recurMarker)'])]
		ifFalse: [
			aStream
				nextPut: $(;
				print: self parsers;
				nextPut: $)]
]

{ #category : #'as yet unclassified' }
SBTSMemoEntry >> setLeftRecursionDetectedFrom: aSymbol stack: aCollection [

	self assert: self isLeftRecursion.
	answer head: {aSymbol type. (aCollection reversed copyUpTo: aSymbol type) reversed. {}}
]
