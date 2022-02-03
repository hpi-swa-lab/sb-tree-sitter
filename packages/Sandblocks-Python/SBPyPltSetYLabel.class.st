Class {
	#name : #SBPyPltSetYLabel,
	#superclass : #SBPyPltAxis,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltSetYLabel class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(call
        	function: (attribute
            	object: (identifier) @ax ="ax"
                attribute: (identifier) @setLabel ="set_ylabel"
            )
        	arguments: (argument_list
			(string) @param
		)
        ) @call' sample: 'ax.set_ylabel("example")'>
	
	^ aBlock
		value: (aDictionary at: 'call')
		value: (self new factory: (aDictionary at: 'call') factory;
			createReplacement: (aDictionary at: 'param') contents)
]

{ #category : #'initialize-release' }
SBPyPltSetYLabel >> createReplacement: aString [

	self
		addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: 'y axis label:');
			addMorphBack: (SBTextBubble new contents: aString);
			cellGap: 4
		)
]

{ #category : #'as yet unclassified' }
SBPyPltSetYLabel >> writeSourceOn: aStream [

	| label |
	label := (self firstSubmorph submorphs at: 2) contents.
	aStream nextPutAll: ('ax.set_ylabel("',label,'")').
]
