Class {
	#name : #SBTSLanguageRuntime,
	#superclass : #Object,
	#category : #'Sandblocks-TreeSitter'
}

{ #category : #'as yet unclassified' }
SBTSLanguageRuntime >> evaluate: aString [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBTSLanguageRuntime >> prettyPrint: aString [

	^ self subclassResponsibility
]
