"
Shows the legend. The legend entries are the labels of the individual plots, set by SBPyPltLabel.
"
Class {
	#name : #SBPyPltLegend,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Matplotlib'
}

{ #category : #'initialize-release' }
SBPyPltLegend >> build [
	<lang: #python match: '(call
        	function: (attribute
            	(identifier) ="ax"
                (identifier) ="legend"
            )
        )' sample: 'ax.legend()'>

	self addMorphBack: (SBStringMorph new contents: 'Show legend')
]

{ #category : #'initialize-release' }
SBPyPltLegend >> palettes [

	^ {SBPyPltPaletteOverview}
]
