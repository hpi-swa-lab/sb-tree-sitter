Class {
	#name : #SBForeignLanguage,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-TreeSitter-Replacements'
}

{ #category : #'as yet unclassified' }
SBForeignLanguage >> layoutCommands [

	^ SBAlgebraCommand container
		data: (self submorphs collect: #layoutCommands);
		morph: self
]

{ #category : #'as yet unclassified' }
SBForeignLanguage >> string: aString language: aLanguageClass for: aBlock [

	self addMorphBack: (aLanguageClass parse: aString).
	self bindings: Dictionary new block: aBlock
]
