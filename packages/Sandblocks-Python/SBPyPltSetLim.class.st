"
Replacement for ax.set_xlim and ax.set_ylim
"
Class {
	#name : #SBPyPltSetLim,
	#superclass : #SBPyPltAxis,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltSetLim class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(call
        	function: (attribute
            	object: (identifier) @ax ="ax"
                attribute: (identifier) @setLim
            )
        	arguments: (argument_list
			(integer) @paramFrom
			(integer) @paramTo
		)
        ) @call' sample: 'ax.set_xlim(0, 5)'>

	| functionName axis |
	functionName := (aDictionary at: 'setLim') contents.
	
	((functionName = 'set_xlim') or: (functionName = 'set_ylim')) ifFalse: [^ nil].
	
	axis := functionName = 'set_xlim' ifTrue: 'x' ifFalse: 'y'.
	
	^ aBlock
		value: (aDictionary at: 'call')
		value: (self new factory: (aDictionary at: 'call') factory;
			createReplacementRangeFrom: (aDictionary at: 'paramFrom') contents 
			to: (aDictionary at: 'paramTo') contents 
			forAxis: axis)
]

{ #category : #'initialize-release' }
SBPyPltSetLim >> createReplacementRangeFrom: minString to: maxString forAxis: aString [ 
	self
		addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: (aString, ' axis limit: ['));
			addMorphBack: (SBStNumberWithPrefix new contents: minString);
			addMorphBack: (SBStringMorph new contents: ',');
			addMorphBack: (SBStNumberWithPrefix new contents: maxString);
			addMorphBack: (SBStringMorph new contents: ']');
			cellGap: 4
		).
]

{ #category : #'as yet unclassified' }
SBPyPltSetLim >> writeSourceOn: aStream [

	| xy minArg maxArg |
	xy := self firstSubmorph firstSubmorph contents first asString.
	minArg := (self firstSubmorph submorphs at: 2) contents.
	maxArg := (self firstSubmorph submorphs at: 4) contents.
	
	aStream nextPutAll: ('ax.set_',xy,'lim(',minArg,', ',maxArg,')').
]
