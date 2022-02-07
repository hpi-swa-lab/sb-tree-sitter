Class {
	#name : #SBPyPltLinewidth,
	#superclass : #SBPyPltParamSimpleReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltLinewidth class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: (identifier) ="linewidth"
      value: (float) @value
) @argument' sample: 'linewidth=0.5'>
	
	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory;
			createReplacement: (aDictionary at: 'value') contents;
			source: (aDictionary at: 'argument') sourceString
			)
]

{ #category : #'as yet unclassified' }
SBPyPltLinewidth class >> matchPythonShortened: aDictionary do: aBlock [
"Same as mathPython: do: but matches linewidth's shortform lw"
	<lang: #python match: '(keyword_argument
	name: (identifier) ="lw"
      value: (float) @value
) @argument' sample: 'lw=0.5'>
	
	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory;
			createReplacement: (aDictionary at: 'value') contents
			)
]

{ #category : #'initialize-release' }
SBPyPltLinewidth >> createReplacement: aNumber [

	self addMorphBack: (SBPyNumberWithPrefix new prefix: 'linewidth='; contents: aNumber)
]
