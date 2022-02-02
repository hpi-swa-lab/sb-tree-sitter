Class {
	#name : #SBPyPltSetYLim,
	#superclass : #SBPyPltAxis,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltSetYLim class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(call
        	function: (attribute
            	object: (identifier) @ax
                (#eq @ax "ax")
                attribute: (identifier) ="set_ylim" @setLim
            )
        	arguments: (argument_list
			(integer) @paramFrom
			(integer) @paramTo
		)
        ) @call' sample: 'ax.set_ylim(0, 5)'>
	
	^ aBlock
		value: (aDictionary at: 'call')
		value: (self new factory: (aDictionary at: 'call') factory;
			createReplacementFrom: (aDictionary at: 'paramFrom') contents 
			to: (aDictionary at: 'paramTo') contents)
]

{ #category : #'initialize-release' }
SBPyPltSetYLim >> createReplacementFrom: minNumber to: maxNumber [

	self
		addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: 'y axis limit: [');
			addMorphBack: (SBPyNumberWithPrefix new contents: minNumber);
			addMorphBack: (SBStringMorph new contents: ',');
			addMorphBack: (SBPyNumberWithPrefix new contents: maxNumber);
			addMorphBack: (SBStringMorph new contents: ']');
			cellGap: 4
		).
]

{ #category : #'as yet unclassified' }
SBPyPltSetYLim >> writeSourceOn: aStream [

	| minArg maxArg |
	minArg := (self firstSubmorph submorphs at: 2) contents.
	maxArg := (self firstSubmorph submorphs at: 4) contents.
	
	aStream nextPutAll: ('ax.set_ylim(',minArg,', ',maxArg,')').
]
