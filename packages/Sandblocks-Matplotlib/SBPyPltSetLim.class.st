"
Replacement for ax.set_xlim and ax.set_ylim
"
Class {
	#name : #SBPyPltSetLim,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Matplotlib'
}

{ #category : #'initialize-release' }
SBPyPltSetLim >> build [
	<lang: #python match: '(call
        	function: (attribute
            	object: (identifier) @ax ="ax"
                attribute: [(identifier) ="set_xlim" (identifier) ="set_ylim"] @setLim
            )
        	arguments: (argument_list
			(integer) @paramFrom
			(integer) @paramTo
		)
        ) @call' sample: 'ax.set_xlim(0, 5)'>

	self addMorphBack: (SBRow new
		addMorphBack: (self
			createBinding: [:c |
				SBStringMorph new contents: ((c at: 'setLim') contents = 'set_xlim'
					ifTrue: ['x']
					ifFalse: ['y']), ' axis limit: [']
			update: [:c :m | ]);
		addMorphBack: (self createBinding: [SBStNumberWithPrefix new] contents: 'paramFrom');
		addMorphBack: (SBStringMorph new contents: ',');
		addMorphBack: (self createBinding: [SBStNumberWithPrefix new] contents: 'paramTo');
		addMorphBack: (SBStringMorph new contents: ']');
		cellGap: 4)
]

{ #category : #'initialize-release' }
SBPyPltSetLim >> palettes [

	^ {SBPyPltPaletteOverview}
]
