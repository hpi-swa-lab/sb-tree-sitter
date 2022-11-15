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

	self bindings: Dictionary new block: aBlock.
	self addMorphBack: (self
		createBinding: [:c | aLanguageClass parse: aString]
		update: [:c :m | (c at: 'root') contents: m sourceString])
]
