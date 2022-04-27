Class {
	#name : #SBTSMemoEntry,
	#superclass : #Object,
	#instVars : [
		'answer'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSMemoEntry >> initialize [

	super initialize.
	
	answer := false
]

{ #category : #'as yet unclassified' }
SBTSMemoEntry >> isLeftRecursion [

	^ answer isBoolean
]

{ #category : #'as yet unclassified' }
SBTSMemoEntry >> leftRecursionDetected [

	self assert: self isLeftRecursion.
	^ answer
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
SBTSMemoEntry >> setLeftRecursionDetected [

	self assert: self isLeftRecursion.
	answer := true
]
