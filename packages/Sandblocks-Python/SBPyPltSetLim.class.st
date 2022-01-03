Class {
	#name : #SBPyPltSetLim,
	#superclass : #SBPyPltAxis,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltSetLim class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(call
        	function: (attribute
            	object: (identifier) @ax
                (#eq @ax "ax")
                attribute: (identifier) @setLim
            )
        	arguments: (argument_list
			(integer) @paramFrom
			(integer) @paramTo
		)
        ) @call' sample: 'ax.set_ylim(from, to)'>
	
	| functionName axis |
	functionName := (aDictionary at: 'setLim') contents.
	
	((functionName = 'set_xlim') or: (functionName = 'set_ylim')) ifFalse: [^ nil].
	
	axis := functionName = 'set_xlim' ifTrue: 'x' ifFalse: 'y'.
	
	^ aBlock
		value: (aDictionary at: 'call')
		value: (self new factory: (aDictionary at: 'call') factory;
			createReplacementFrom: (aDictionary at: 'paramFrom') contents 
			to: (aDictionary at: 'paramTo') contents 
			ofAxis: axis)
]

{ #category : #'initialize-release' }
SBPyPltSetLim >> createReplacementFrom: minNumber to: maxNumber  ofAxis: anAxis [

	self
		addMorphBack: (SBRow new
			addMorphBack: (SBTextBubble new contents: anAxis);
			addMorphBack: (SBStringMorph new contents: 'axis');
			addMorphBack: (SBStringMorph new contents: 'imit:');
			addMorphBack: (SBStringMorph new contents: '[');
			addMorphBack: (SBStNumberWithPrefix new contents: minNumber);
			addMorphBack: (SBStringMorph new contents: ',');
			addMorphBack: (SBStNumberWithPrefix new contents: maxNumber);
			addMorphBack: (SBStringMorph new contents: ']');
			cellGap: 4
		).
]

{ #category : #'as yet unclassified' }
SBPyPltSetLim >> writeSourceOn: aStream [
"called when blocks are copied. It transforms the block back to source code"

	| xy minArg maxArg |
	xy := self submorphs first submorphs second contents.
	minArg := (self submorphs second submorphs at: 1) contents.
	maxArg := (self submorphs second submorphs at: 2) contents.
	
	aStream nextPutAll: 'ax.set_'.
	aStream nextPutAll: xy.
	aStream nextPutAll: 'lim('.
	aStream nextPutAll: minArg.
	aStream nextPutAll: ', '.
	aStream nextPutAll: maxArg.
	aStream nextPutAll: ')'.
]