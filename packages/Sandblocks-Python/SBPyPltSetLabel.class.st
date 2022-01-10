Class {
	#name : #SBPyPltSetLabel,
	#superclass : #SBPyPltAxis,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltSetLabel class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(call
        	function: (attribute
            	object: (identifier) @ax
                (#eq @ax "ax")
                attribute: (identifier) @setLabel
            )
        	arguments: (argument_list
			(string) @param
		)
        ) @call' sample: 'ax.set_xlabel("example")'>
	
	| functionName axisOflabel |
	functionName := (aDictionary at: 'setLabel') contents.
	
	((functionName = 'set_xlabel') or: (functionName = 'set_ylabel')) ifFalse: [^ nil].
	
	axisOflabel := functionName = 'set_xlabel' ifTrue: 'x' ifFalse: 'y'.
	
	^ aBlock
		value: (aDictionary at: 'call')
		value: (self new factory: (aDictionary at: 'call') factory;
			createReplacement: (aDictionary at: 'param') contents
			ofAxis: axisOflabel
			)
]

{ #category : #'initialize-release' }
SBPyPltSetLabel >> createReplacement: aLabel ofAxis: anAxis [

	self
		addMorphBack: (SBRow new
			addMorphBack: (SBTextBubble new contents: anAxis);
			addMorphBack: (SBStringMorph new contents: 'axis');
			addMorphBack: (SBStringMorph new contents: 'label:');
			addMorphBack: (SBTextBubble new contents: aLabel);
			cellGap: 4
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
