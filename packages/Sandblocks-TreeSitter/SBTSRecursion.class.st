Class {
	#name : #SBTSRecursion,
	#superclass : #Object,
	#instVars : [
		'seed',
		'head',
		'involvedSymbols',
		'allowedSymbols'
	],
	#category : #'Sandblocks-TreeSitter-Parser'
}

{ #category : #'as yet unclassified' }
SBTSRecursion >> addInvolved: aCollection [

	involvedSymbols addAll: aCollection
]

{ #category : #'as yet unclassified' }
SBTSRecursion >> allowedSymbols: aSet [

	allowedSymbols := aSet
]

{ #category : #'as yet unclassified' }
SBTSRecursion >> head [

	^ head
]

{ #category : #'as yet unclassified' }
SBTSRecursion >> head: anObject [

	head := anObject
]

{ #category : #'as yet unclassified' }
SBTSRecursion >> ifRecursionDetected: aBlock [

	self head ifNotNil: [aBlock value]
]

{ #category : #'as yet unclassified' }
SBTSRecursion >> initialize [

	super initialize.
	
	seed := {}
]

{ #category : #'as yet unclassified' }
SBTSRecursion >> involvedSymbols: aSet [

	involvedSymbols := aSet
]

{ #category : #'as yet unclassified' }
SBTSRecursion >> newIteration [

	allowedSymbols := involvedSymbols copy
]

{ #category : #'as yet unclassified' }
SBTSRecursion >> printOn: aStream [

	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: self head.
	aStream nextPut: $)
]

{ #category : #'as yet unclassified' }
SBTSRecursion >> seed [

	^ seed
]

{ #category : #'as yet unclassified' }
SBTSRecursion >> seed: aCollection [

	self assert: (aCollection allSatisfy: [:c | c class = SBTSInputParser]).
	seed := aCollection collect: [:parser | parser copy]
]

{ #category : #'as yet unclassified' }
SBTSRecursion >> tryExpandSymbol: aSymbol do: aBlock otherwise: anotherBlock [

	^ (allowedSymbols includes: aSymbol type)
		ifTrue: [
			allowedSymbols remove: aSymbol type.
			aBlock value]
		ifFalse: [anotherBlock value]
]
