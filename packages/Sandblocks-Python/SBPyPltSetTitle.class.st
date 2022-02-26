"
Sets the title of the axes.
"
Class {
	#name : #SBPyPltSetTitle,
	#superclass : #SBPyPltAxis,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltSetTitle class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(call
        	function: (attribute
            	object: (identifier) @ax ="ax"
                attribute: (identifier) @setTitle ="set_title"
            )
        	arguments: (argument_list
			(string) @param
		)
        ) @call' sample: 'ax.set_title("example")'>
	
	^ aBlock
		value: (aDictionary at: 'call')
		value: (self new factory: (aDictionary at: 'call') factory;
			createReplacement: (aDictionary at: 'param') contents
			)
]

{ #category : #'initialize-release' }
SBPyPltSetTitle >> createReplacement: aLabel [
	
	self
		addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: ('title:'));
			addMorphBack: (SBTextBubble new contents: aLabel);
			cellGap: 4
		)
]

{ #category : #'as yet unclassified' }
SBPyPltSetTitle >> writeSourceOn: aStream [

	| label |
	label := (self firstSubmorph submorphs second) contents.
	
	aStream nextPutAll: ('ax.set_title("',label,'")').
]
