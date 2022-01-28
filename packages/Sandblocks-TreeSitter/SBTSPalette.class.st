Class {
	#name : #SBTSPalette,
	#superclass : #SBPalette,
	#category : #'Sandblocks-TreeSitter'
}

{ #category : #'as yet unclassified' }
SBTSPalette class >> context [

	^ {#language understood. [:block | block language = self language]}
]

{ #category : #'as yet unclassified' }
SBTSPalette class >> grammarHandler [

	^ SBMetaGrammarHandler new
]

{ #category : #'as yet unclassified' }
SBTSPalette class >> language [

	^ #neverMatch
]
