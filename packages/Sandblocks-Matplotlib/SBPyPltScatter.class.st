"
Replacement for ax.scatter
"
Class {
	#name : #SBPyPltScatter,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Matplotlib'
}

{ #category : #'initialize-release' }
SBPyPltScatter >> build [
	<lang: #python match: '(call
        	function: (attribute
            	object: (identifier) ="ax"
                attribute: (identifier) ="scatter"
            )
        	arguments: (argument_list) @args
        )' sample: 'ax.scatter(X, Y)'>

	self addMorphBack: (SBRow new
		addMorphBack: (SBColumn new
			hResizing: #shrinkWrap;
			cellPositioning: #center;
			layoutInset: 2;
			addMorphBack: (SBStringMorph new contents: 'scatter:');
			addMorphBack: SBPyPltImage scatterPlot);
		addMorphBack: (self createBindingBlock: 'args');
		cellGap: 4)
]

{ #category : #'initialize-release' }
SBPyPltScatter >> palettes [

	^ {SBPyPltPaletteScatter. SBPyPltPaletteOverview}, super palettes
]
