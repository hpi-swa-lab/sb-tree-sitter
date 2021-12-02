Class {
	#name : #SBPyPltSetLabel,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltSetLabel class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(module
	(expression_statement
    	(call
        	function: (attribute
            	object: (identifier) @ax
                (#eq @ax "ax")
                attribute: (identifier) @setLabel
            )
        	arguments: (argument_list
			(string) @param
		)
        )
    ) @expression  
)' sample: 'ax.set_xlabel("example")'>
	
	| functionName axisOflabel |
	functionName := (aDictionary at: 'setLabel') contents.
	
	((functionName = 'set_xlabel') or: (functionName = 'set_ylabel')) ifFalse: [^ nil].
	
	axisOflabel := functionName = 'set_xlabel' ifTrue: 'x' ifFalse: 'y'.
	
	^ aBlock
		value: (aDictionary at: 'expression')
		value: (self new factory: (aDictionary at: 'expression') factory;
			createReplacement: (aDictionary at: 'param') contents
			ofAxis: axisOflabel
			)
]

{ #category : #'initialize-release' }
SBPyPltSetLabel >> createReplacement: aLabel ofAxis: anAxis [

	self
		addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: 'Label at ');
			addMorphBack: (SBTextBubble new contents: anAxis);
			addMorphBack: (SBStringMorph new contents: '-axis: ');
			addMorphBack: (SBTextBubble new contents: aLabel)
		)
]

{ #category : #'as yet unclassified' }
SBPyPltSetLabel >> writeSourceOn: aStream [
"called when blocks are copied. It transforms the block back to source code"

	| xy label |
	xy := self submorphs first submorphs second contents.
	label := (self submorphs first submorphs at: 4) contents.
	
	aStream nextPutAll: 'ax.set_',xy,'label("',label,'")'.
]
