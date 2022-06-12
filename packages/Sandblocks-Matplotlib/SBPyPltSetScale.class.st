"
Replacement for ax.set_xscale and ax.set_yscale
"
Class {
	#name : #SBPyPltSetScale,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Matplotlib'
}

{ #category : #'initialize-release' }
SBPyPltSetScale >> build [
	<lang: #python match: '(call
        	function: (attribute
            	object: (identifier) @ax ="ax"
                attribute: [(identifier) ="set_xscale" (identifier) ="set_yscale"] @setScale
            )
        	arguments: (argument_list
			(string) @param
		)
        ) @call' sample: 'ax.set_xscale("log")'>

	| label |
	label := (bindings at: 'setScale') contents = 'set_xscale'
		ifTrue: ['x']
		ifFalse: ['y'].
	self addMorphBack: (self
		createBinding: [
			SBSelect new
				entryMorphs: self itemDefinitions;
				prefix: label, ' axis scale: ']
		object: 'param')
]

{ #category : #'initialize-release' }
SBPyPltSetScale >> itemDefinitions [
"These items are shown in a SBComboBox"

	^ {{'linear'. SBPyPltImage linearScale. 'The default linear scale.'}.
		{'log'. SBPyPltImage logScale. 'A standard logarithmic scale. Care is taken to only plot positive values.'}.
		{'symlog'. SBPyPltImage symlogScale. 'The symmetrical logarithmic scale is logarithmic in both the positive and negative directions from the origin.

Since the values close to zero tend toward infinity, there is a need to have a range around zero that is linear. The parameter linthresh allows the user to specify the size of this range (-linthresh, linthresh).'}}
]

{ #category : #accessing }
SBPyPltSetScale >> palettes [

	^ {SBPyPltPaletteOverview}
]
