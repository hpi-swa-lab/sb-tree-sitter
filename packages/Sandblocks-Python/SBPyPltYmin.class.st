Class {
	#name : #SBPyPltYmin,
	#superclass : #SBPyPltParamSimpleReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltYmin class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: (identifier) ="ymin"
      value: [(float) (integer)] @value
) @argument' sample: 'ymin=0.5'>

	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory;
			createReplacement: (aDictionary at: 'value') contents)
]

{ #category : #'as yet unclassified' }
SBPyPltYmin >> createReplacement: aNumber [

	self addMorphBack: (SBPyNumberWithPrefix new prefix: 'ymin='; rangeFrom: 0.0 to: 1.0; floatSteps; contents: aNumber)
]
