"
Replacement for ax.set_xlabel and ax.set_ylabel
"
Class {
	#name : #SBPyPltSetLabel,
	#superclass : #SBPyPltAxis,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltSetLabel class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(call
        	function: (attribute
            	object: (identifier) @ax ="ax"
                attribute: (identifier) @setLabel
            )
        	arguments: (argument_list
			(string) @param
		)
        ) @call' sample: 'ax.set_xlabel("example")'>
	
	| functionName axis |
	functionName := (aDictionary at: 'setLabel') contents.
	
	((functionName = 'set_xlabel') or: [functionName = 'set_ylabel']) ifFalse: [^ nil].
	
	axis := functionName = 'set_xlabel' ifTrue: ['x'] ifFalse: ['y'].
	
	^ aBlock
		value: (aDictionary at: 'call')
		value: (self new factory: (aDictionary at: 'call') factory;
			createReplacementWithLabel: (aDictionary at: 'param') contents axis: axis)
]

{ #category : #'initialize-release' }
SBPyPltSetLabel >> createReplacementWithLabel: aString axis: anotherString [
	
	self
		addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: (anotherString, ' axis label:'));
			addMorphBack: (SBTextBubble new contents: aString);
			cellGap: 4
		)
]

{ #category : #copying }
SBPyPltSetLabel >> writeSourceOn: aStream [

	| xy label |
	xy := self firstSubmorph firstSubmorph contents first asString.
	label := (self firstSubmorph submorphs second) contents.
	
	aStream nextPutAll: ('ax.set_',xy,'label("',label,'")').
]
