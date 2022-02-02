Class {
	#name : #SBPyPltSetXScale,
	#superclass : #SBPyPltAxis,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltSetXScale class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(call
        	function: (attribute
            	object: (identifier) @ax
                (#eq @ax "ax")
                attribute: (identifier) ="set_xscale" @setScale
            )
        	arguments: (argument_list
			(string) @param
		)
        ) @call' sample: 'ax.set_xscale("log")'>
	
	^ aBlock
		value: (aDictionary at: 'call')
		value: (self new factory: (aDictionary at: 'call') factory;
			createReplacement: (aDictionary at: 'param') contents
			)
]

{ #category : #'initialize-release' }
SBPyPltSetXScale >> createReplacement: aLabel [
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
			addMorphBack: (SBStringMorph new contents: 'x axis scale:');
			addMorphBack: (SBPyPltComboBox new 
				values: items; tooltips: itemsTooltips; object: aLabel);
			cellGap: 4
		)
]

{ #category : #'as yet unclassified' }
SBPyPltSetXScale >> writeSourceOn: aStream [

	| label |
	label := (self firstSubmorph submorphs second) contents.
	
	aStream nextPutAll: 'ax.set_xscale("',label,'")'.
]
