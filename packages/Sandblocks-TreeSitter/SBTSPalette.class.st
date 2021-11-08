Class {
	#name : #SBTSPalette,
	#superclass : #SBPalette,
	#category : #'Sandblocks-TreeSitter'
}

{ #category : #'as yet unclassified' }
SBTSPalette class >> context [

	^ {#isInlineBlock. [:block | block language = self language]}
]

{ #category : #'as yet unclassified' }
SBTSPalette class >> grammarHandler [

	^ SBMetaGrammarHandler new
]

{ #category : #'as yet unclassified' }
SBTSPalette class >> language [

	^ nil
]
