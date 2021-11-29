Class {
	#name : #SBPyPltPlot,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltPlot class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(module
	(expression_statement
    	(call
        	function: (attribute
            	object: (identifier) @ax
                (#eq @ax "ax")
                attribute: (identifier) @plot
            )
        	arguments: (argument_list
			(identifier) @paramX
            (identifier) @paramY
		)
        )
    ) @expression  
)' sample: 'ax.plot(X, Y)'>
	
	^ aBlock
		value: (aDictionary at: 'expression')
		value: (self new factory: (aDictionary at: 'expression') factory;
			createReplacementWithX: (aDictionary at: 'paramX') contents
			Y:  (aDictionary at: 'paramY') contents)
]

{ #category : #'initialize-release' }
SBPyPltPlot >> createReplacementWithX: xString Y: yString [ 

	self addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: 'line plot of (');
			addMorphBack: (SBTextBubble new contents: xString);
			addMorphBack: (SBStringMorph new contents: ', ');
			addMorphBack: (SBTextBubble new contents: yString);
			addMorphBack: (SBStringMorph new contents: ')')
		)
]

{ #category : #'as yet unclassified' }
SBPyPltPlot >> writeSourceOn: aStream [
"called when blocks are copied. It transforms the block back to source code"

	| xArg yArg |
	xArg := self submorphs first submorphs second contents.
	yArg := (self submorphs first submorphs at: 4) contents.
	
	aStream nextPutAll: 'ax.plot('.
	aStream nextPutAll: xArg.
	aStream nextPutAll: ', '.
	aStream nextPutAll: yArg.
	aStream nextPutAll: ')'.
]
