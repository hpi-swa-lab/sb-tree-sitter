Class {
	#name : #SBPyPltColor,
	#superclass : #SBPyPltParamSimpleReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltColor class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: (identifier) ="color"
    value: (string) @value
) @argument' sample: 'color="r"'>
	
	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory;
			createReplacement: (aDictionary at: 'value') contents
			)
]

{ #category : #'initialize-release' }
SBPyPltColor >> createReplacement: aString [

	self addMorphBack: (SBTextBubble new prefix: 'color='; contents: aString)
]
