Class {
	#name : #SBPyPltGid,
	#superclass : #SBPyPltParamSimpleReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltGid class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: (identifier) ="gid"
    value: (string) @value
) @argument' sample: 'gid="unique-graph-id"'>
	
	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory;
			createReplacement: (aDictionary at: 'value') contents;
			source: (aDictionary at: 'argument') sourceString
			)
]

{ #category : #'initialize-release' }
SBPyPltGid >> createReplacement: aString [

	self addMorphBack: (SBTextBubble new prefix: 'gid='; contents: aString)
]

{ #category : #classification }
SBPyPltGid >> palettes [

	^ {SBPyPltPalettePlot}
]
