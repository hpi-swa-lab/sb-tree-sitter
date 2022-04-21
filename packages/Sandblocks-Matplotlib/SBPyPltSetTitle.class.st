"
Sets the title of the axes.
"
Class {
	#name : #SBPyPltSetTitle,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Matplotlib'
}

{ #category : #'initialize-release' }
SBPyPltSetTitle >> build [
	<lang: #python match: '(call
        	function: (attribute
            	object: (identifier) @ax ="ax"
                attribute: (identifier) @setTitle ="set_title"
            )
        	arguments: (argument_list
			(string (string_content) @param)
		)
        ) @call' sample: 'ax.set_title("example")'>

	self addMorphBack: (SBRow new
		addMorphBack: (SBStringMorph new contents: 'title:');
		addMorphBack: (self createBinding: [SBTextBubble new] contents: 'param');
		cellGap: 4)
]

{ #category : #accessing }
SBPyPltSetTitle >> palettes [

	^ {SBPyPltPaletteOverview}
]
