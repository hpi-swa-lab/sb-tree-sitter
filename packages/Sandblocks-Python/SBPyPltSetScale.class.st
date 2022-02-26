"
Replacement for ax.set_xscale and ax.set_yscale
"
Class {
	#name : #SBPyPltSetScale,
	#superclass : #SBPyPltAxis,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltSetScale class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(call
        	function: (attribute
            	object: (identifier) @ax ="ax"
                attribute: (identifier) @setScale
            )
        	arguments: (argument_list
			(string) @param
		)
        ) @call' sample: 'ax.set_xscale("log")'>

		
	| functionName axis |
	functionName := (aDictionary at: 'setScale') contents.
	
	((functionName = 'set_xscale') or: [(functionName = 'set_yscale')]) ifFalse: [^ nil].
	
	axis := functionName = 'set_xscale' ifTrue: ['x'] ifFalse: ['y'].
	
	^ aBlock
		value: (aDictionary at: 'call')
		value: (self new factory: (aDictionary at: 'call') factory;
			createReplacementWithLabel: (aDictionary at: 'param') contents axis: axis)
]

{ #category : #'initialize-release' }
SBPyPltSetScale >> createReplacementWithLabel: aString axis: anotherString [
	| itemMorphs selectedItem tooltips |
	itemMorphs := SBPyPltComboBox itemDefinitionsToMorphs: self itemDefinitions.
	selectedItem := SBPyPltComboBox find: aString inItemDefinitions: itemMorphs fallback: #first.
	tooltips := self itemDefinitions collect: #third. 

	self addMorphBack:  (SBPyPltComboBox new values: itemMorphs; prefix: (anotherString, ' axis scale:'); 
			object: selectedItem; tooltips: tooltips)
]

{ #category : #'initialize-release' }
SBPyPltSetScale >> itemDefinitions [
"These items are shown in a SBComboBox"

	^ {{'linear'. SBPyPltImage linearScale. 'The default linear scale.'}.
		{'log'. SBPyPltImage logScale. 'A standard logarithmic scale. Care is taken to only plot positive values.'}.
		{'symlog'. SBPyPltImage symlogScale. 'The symmetrical logarithmic scale is logarithmic in both the positive and negative directions from the origin.

Since the values close to zero tend toward infinity, there is a need to have a range around zero that is linear. The parameter linthresh allows the user to specify the size of this range (-linthresh, linthresh).'}}
]

{ #category : #'as yet unclassified' }
SBPyPltSetScale >> writeSourceOn: aStream [

	| xy label |
	xy := self firstSubmorph submorphs first contents first asString.
	label := (self firstSubmorph submorphs second) contents.
	aStream nextPutAll: ('ax.set_',xy,'scale("',label,'")').
]
