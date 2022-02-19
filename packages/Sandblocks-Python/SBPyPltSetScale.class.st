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
	
	((functionName = 'set_xscale') or: (functionName = 'set_yscale')) ifFalse: [^ nil].
	
	axis := functionName = 'set_xscale' ifTrue: 'x' ifFalse: 'y'.
	
	^ aBlock
		value: (aDictionary at: 'call')
		value: (self new factory: (aDictionary at: 'call') factory;
			createReplacement: (aDictionary at: 'param') contents
			forAxis: axis
			)
]

{ #category : #'initialize-release' }
SBPyPltSetScale >> createReplacement: aLabel forAxis: aString [
	| selection |
	selection := (self items select: [:i | i submorphs first contents = aLabel]) ifEmpty: [aLabel] ifNotEmpty: [:aCollection | aCollection first].
	
	self addMorphBack: (SBPyPltComboBox new 
				values: self items; tooltips: self tooltips; object: selection; prefix: (aString,' axis scale:'))
]

{ #category : #'initialize-release' }
SBPyPltSetScale >> items [
"These items are shown in a SBComboBox"

	^ {{'linear'. SBPyPltImage linearScale}.
		{'log'. SBPyPltImage logScale}.
		{'symlog'. SBPyPltImage symlogScale}} collect: [:pair |
				SBRow new
					cellGap: 8;
					addMorphBack: (SBStringMorph new contents: pair first);
					addMorphBack: pair second
				].
]

{ #category : #'initialize-release' }
SBPyPltSetScale >> tooltips [

	^ {
		'The default linear scale.'.
		'A standard logarithmic scale. Care is taken to only plot positive values.'.
		'The symmetrical logarithmic scale is logarithmic in both the positive and negative directions from the origin.

Since the values close to zero tend toward infinity, there is a need to have a range around zero that is linear. The parameter linthresh allows the user to specify the size of this range (-linthresh, linthresh).'
	}
]

{ #category : #'as yet unclassified' }
SBPyPltSetScale >> writeSourceOn: aStream [

	| xy label |
	xy := self firstSubmorph submorphs first contents first asString.
	label := (self firstSubmorph submorphs second) contents.
	aStream nextPutAll: ('ax.set_',xy,'scale("',label,'")').
]
