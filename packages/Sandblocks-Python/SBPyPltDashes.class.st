"
How to draw the end caps if the line is is_dashed.
"
Class {
	#name : #SBPyPltDashes,
	#superclass : #SBPyPltParamReplacement,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltDashes class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: (identifier) ="dashes"
      value: (tuple) @value
) @argument' sample: 'dashes=(3,2,1,1)'>
	
	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory;
			createReplacement: (aDictionary at: 'value') contents;
			source: (aDictionary at: 'argument') sourceString
			)
]

{ #category : #'initialize-release' }
SBPyPltDashes >> createReplacement: aLabel [
	self
		addMorphBack:  (SBPyPltComboBox new)
]
