Class {
	#name : #SBRePalette,
	#superclass : #SBTSPalette,
	#category : #'Sandblocks-Regex'
}

{ #category : #private }
SBRePalette class >> addAllRules: aCollection to: aBuilder [

	aCollection do: [:rule | self addRule: rule to: aBuilder]
]

{ #category : #private }
SBRePalette class >> addRule: aString to: aBuilder [

	aBuilder addBlock: aString as: (self factory build: aString)
]

{ #category : #'as yet unclassified' }
SBRePalette class >> buildOn: aBuilder [

	| grammar |
	
	grammar := Json readFrom: self factory grammarJson readStream.
	self addAllRules: grammar rules keys sorted to: aBuilder
]

{ #category : #'as yet unclassified' }
SBRePalette class >> factory [

	^ SBRegex
]

{ #category : #'as yet unclassified' }
SBRePalette class >> language [

	^ self factory language
]
