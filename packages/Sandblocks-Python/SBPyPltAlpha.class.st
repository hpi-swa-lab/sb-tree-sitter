Class {
	#name : #SBPyPltAlpha,
	#superclass : #SBPyPltParamSimpleReplace,
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
			createReplacement: (aDictionary at: 'value') contents)
]

{ #category : #'initialize-release' }
SBPyPltAlpha >> createReplacement: aNumber [

	self addMorphBack: (SBPyNumberWithPrefix new prefix: 'alpha='; rangeFrom: 0.0 to: 1.0; floatSteps; contents: aNumber)
]
