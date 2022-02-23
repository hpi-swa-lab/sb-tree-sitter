Class {
	#name : #SBPyPltYmax,
	#superclass : #SBPyPltParamSimpleReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltYmax class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: (identifier) ="ymax"
      value: [(float) (integer)] @value
) @argument' sample: 'ymax=0.5'>

	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory;
			createReplacement: (aDictionary at: 'value') contents)
]

{ #category : #'as yet unclassified' }
SBPyPltYmax >> createReplacement: aNumber [

	self addMorphBack: (SBPyNumberWithPrefix new prefix: 'ymax='; rangeFrom: 0.0 to: 1.0; floatSteps; contents: aNumber)
]
