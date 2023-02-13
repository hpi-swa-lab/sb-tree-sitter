Class {
	#name : #SBTSPalette,
	#superclass : #SBPalette,
	#category : #'Sandblocks-TreeSitter-UI'
}

{ #category : #'as yet unclassified' }
SBTSPalette class >> context [

	^ {#language understood. [:block | block language = self language]}
]

{ #category : #'as yet unclassified' }
SBTSPalette class >> language [

	^ #neverMatch
]
