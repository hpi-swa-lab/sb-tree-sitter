Class {
	#name : #SBPyPltSetXLabel,
	#superclass : #SBPyPltAxis,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltSetXLabel class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(call
        	function: (attribute
            	object: (identifier) @ax ="ax"
                attribute: (identifier) @setLabel ="set_xlabel"
            )
        	arguments: (argument_list
			(string) @param
		)
        ) @call' sample: 'ax.set_xlabel("example")'>
	
	^ aBlock
		value: (aDictionary at: 'call')
		value: (self new factory: (aDictionary at: 'call') factory;
			createReplacement: (aDictionary at: 'param') contents)
]

{ #category : #'initialize-release' }
SBPyPltSetXLabel >> createReplacement: aString [

	self
		addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: 'x axis label:');
			addMorphBack: (SBTextBubble new contents: aString);
			cellGap: 4
		)
]

{ #category : #'as yet unclassified' }
SBPyPltSetXLabel >> writeSourceOn: aStream [

	| label |
	label := (self firstSubmorph submorphs at: 2) contents.
	aStream nextPutAll: ('ax.set_xlabel("',label,'")').
]
