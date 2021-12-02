Class {
	#name : #SBPyPltSetLim,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltSetLim class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(module
	(expression_statement
    	(call
        	function: (attribute
            	object: (identifier) @ax
                (#eq @ax "ax")
                attribute: (identifier) @setLim
            )
        	arguments: (argument_list
			(integer) @paramFrom
			(integer) @paramTo
		)
        )
    ) @expression  
)' sample: 'ax.set_ylim(from, to)'>
	
	| functionName axis |
	functionName := (aDictionary at: 'setLim') contents.
	
	((functionName = 'set_xlim') or: (functionName = 'set_ylim')) ifFalse: [^ nil].
	
	axis := functionName = 'set_xlim' ifTrue: 'x' ifFalse: 'y'.
	
	^ aBlock
		value: (aDictionary at: 'expression')
		value: (self new factory: (aDictionary at: 'expression') factory;
			createReplacementFrom: (aDictionary at: 'paramFrom') contents 
			to: (aDictionary at: 'paramTo') contents 
			ofAxis: axis)
]

{ #category : #'initialize-release' }
SBPyPltSetLim >> createReplacementFrom: minNumber to: maxNumber  ofAxis: anAxis [

	self
		listDirection: #topToBottom;
		addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: 'Limit ');
			addMorphBack: (SBTextBubble new contents: anAxis);
			addMorphBack: (SBStringMorph new contents: ' axis')
		);
		addMorphBack: (SBRow new
			addMorphBack: (SBStNumberWithPrefix new prefix: 'From'; contents: minNumber);
			addMorphBack: (SBStNumberWithPrefix new prefix: 'To'; contents: maxNumber)
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
