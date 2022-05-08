Class {
	#name : #SBTSRecursion,
	#superclass : #Object,
	#instVars : [
		'seed',
		'head'
	],
	#category : #'Sandblocks-TreeSitter-Parser'
}

{ #category : #'as yet unclassified' }
SBTSRecursion >> head [

	^ head
]

{ #category : #'as yet unclassified' }
SBTSRecursion >> head: anObject [

	head := anObject
]

{ #category : #'as yet unclassified' }
SBTSRecursion >> initialize [

	super initialize.
	
	seed := {}
]

{ #category : #'as yet unclassified' }
SBTSRecursion >> seed [

	^ seed
]

{ #category : #'as yet unclassified' }
SBTSRecursion >> seed: aCollection [

	seed := aCollection
]
