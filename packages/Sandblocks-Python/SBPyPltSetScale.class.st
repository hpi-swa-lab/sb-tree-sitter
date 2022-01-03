Class {
	#name : #SBPyPltSetScale,
	#superclass : #SBPyPltAxis,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltSetScale class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(call
        	function: (attribute
            	object: (identifier) @ax
                (#eq @ax "ax")
                attribute: (identifier) @setScale
            )
        	arguments: (argument_list
			(string) @param
		)
        ) @call' sample: 'ax.set_xscale("log")'>
	
	| functionName axisOflabel |
	functionName := (aDictionary at: 'setScale') contents.
	
	((functionName = 'set_xscale') or: (functionName = 'set_yscale')) ifFalse: [^ nil].
	
	axisOflabel := functionName = 'set_xscale' ifTrue: 'x' ifFalse: 'y'.
	
	^ aBlock
		value: (aDictionary at: 'call')
		value: (self new factory: (aDictionary at: 'call') factory;
			createReplacement: (aDictionary at: 'param') contents
			ofAxis: axisOflabel
			)
]

{ #category : #'initialize-release' }
SBPyPltSetScale >> createReplacement: aLabel ofAxis: anAxis [

	| items itemsTooltips selection |
	
	items := {
			{'linear'. SBPyPltImage linearScale}.
			{'log'. SBPyPltImage logScale}.
			{'symlog'. SBPyPltImage symlogScale}
			} collect: [:pair |
				SBRow new
					cellGap: 8;
					addMorphBack: (SBStringMorph new contents: pair first);
					addMorphBack: pair second
				].

	itemsTooltips := {
		'The default linear scale.'.
		'A standard logarithmic scale. Care is taken to only plot positive values.'.
		'The symmetrical logarithmic scale is logarithmic in both the positive and negative directions from the origin.

Since the values close to zero tend toward infinity, there is a need to have a range around zero that is linear. The parameter linthresh allows the user to specify the size of this range (-linthresh, linthresh).'
	}.
	
	selection := (items select: [:i | i submorphs first contents = aLabel]) ifEmpty: [aLabel] ifNotEmpty: [:aCollection | aCollection first].

	self addMorphBack: (SBRow new
			addMorphBack: (SBTextBubble new contents: anAxis);
			addMorphBack: (SBStringMorph new contents: 'axis:');
			addMorphBack: (SBComboBox new 
				values: items; prefix: 'Scale: '; tooltips: itemsTooltips);
			cellGap: 4
		)
]

{ #category : #'as yet unclassified' }
SBPyPltSetScale >> writeSourceOn: aStream [
"called when blocks are copied. It transforms the block back to source code"

	| xy label |
	xy := self submorphs first submorphs second contents.
	label := (self submorphs first submorphs at: 4) contents.
	
	aStream nextPutAll: 'ax.set_',xy,'scale("',label,'")'.
]
