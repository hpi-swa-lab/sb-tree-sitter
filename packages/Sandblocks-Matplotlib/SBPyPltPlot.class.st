"
Replacement for ax.plot
"
Class {
	#name : #SBPyPltPlot,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Matplotlib'
}

{ #category : #'initialize-release' }
SBPyPltPlot >> build [
	<lang: #python match: '(call
        	function: (attribute
            	object: (identifier) ="ax"
                attribute: (identifier) ="plot"
            )
        	arguments: (argument_list) @args
        )' sample: 'ax.plot(Y)'>

	
	self addMorphBack: (SBRow new
		addMorphBack: (SBColumn new
			hResizing: #shrinkWrap;
			cellPositioning: #center;
			layoutInset: 2;
			addMorphBack: (SBStringMorph new contents: 'line plot:');
			addMorphBack: SBPyPltImage linePlot);
		addMorphBack: (self createBindingBlock: 'args');
		cellGap: 4)
]

{ #category : #'initialize-release' }
SBPyPltPlot >> palettes [

	^ {SBPyPltPalettePlot. SBPyPltPaletteOverview}, super palettes
]
