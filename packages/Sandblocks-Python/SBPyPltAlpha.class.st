Class {
	#name : #SBPyPltAlpha,
	#superclass : #SBPyPltParamReplacement,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltAlpha class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: (identifier) ="alpha"
      value: (float) @value
) @argument' sample: 'alpha=0.5'>

	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory;
			createReplacement: (aDictionary at: 'value') contents;
			source: (aDictionary at: 'argument') sourceString
			)
]

{ #category : #'initialize-release' }
SBPyPltAlpha >> createReplacement: aNumber [
"aNumber must be in the range [0-1]"

	self addMorphBack: (SBPyNumberWithPrefix new prefix: 'alpha='; contents: aNumber)
]
