"
Replacement for ax.set_xlabel and ax.set_ylabel
"
Class {
	#name : #SBPyPltSetLabel,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Matplotlib'
}

{ #category : #'initialize-release' }
SBPyPltSetLabel >> build [
	<lang: #python match: '(call
        	function: (attribute
            	object: (identifier) @ax ="ax"
         		attribute: [(identifier) ="set_xlabel" (identifier) ="set_ylabel"] @setLabel
            )
        	arguments: (argument_list
			(string) @param
		)
        ) @call' sample: 'ax.set_xlabel("example")'>

	self addMorphBack: (SBRow new
		addMorphBack: (self
			createBinding: [:c |
				SBStringMorph new contents: ((c at: 'setLabel') contents = 'set_xlabel'
					ifTrue: ['x']
					ifFalse: 'y'), ' axis label:']
			update: [:c :m | ]);
		addMorphBack: (self createBinding: [SBTextBubble new] contents: 'param');
		cellGap: 4)
]

{ #category : #copying }
SBPyPltSetLabel >> palettes [

	^ {SBPyPltPaletteOverview}
]
