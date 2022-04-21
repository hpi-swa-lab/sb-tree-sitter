Class {
	#name : #SBTSNodeContextSensitiveText,
	#superclass : #SBTSNodeText,
	#instVars : [
		'validCheck'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeContextSensitiveText >> characterValid: aCharacter in: aParser [

	^ validCheck value: aParser value: aCharacter
]

{ #category : #'as yet unclassified' }
SBTSNodeContextSensitiveText >> validCheck: aClosure [

	validCheck := aClosure
]
