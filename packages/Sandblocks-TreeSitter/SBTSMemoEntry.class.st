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
SBTSMemoEntry >> lr [

	self assert: self isLeftRecursion.
	^ answer
]

{ #category : #'as yet unclassified' }
SBTSMemoEntry >> lr: aRecursion [

	self assert: aRecursion class = SBTSRecursion.
	answer := aRecursion
]

{ #category : #'as yet unclassified' }
SBTSMemoEntry >> parsers [

	self assert: self isLeftRecursion not.
	^ answer
]

{ #category : #'as yet unclassified' }
SBTSMemoEntry >> parsers: aCollection [

	self assert: (aCollection allSatisfy: [:p | p class = SBTSInputParser]).
	answer := aCollection collect: [:parser | parser copy]
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

	| stack |
	self assert: self isLeftRecursion.
	stack := aCollection reversed copyUpTo: aSymbol type.
	answer head
		ifNotNil: [answer head second addAll: stack]
		ifNil: [answer head: {aSymbol type. stack asSet. {}}]
]
