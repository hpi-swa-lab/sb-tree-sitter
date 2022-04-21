"
Replacement for ax.scatter
"
Class {
	#name : #SBPyPltScatter,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Matplotlib'
}

{ #category : #'as yet unclassified' }
SBPyPltScatter class >> match: aDictionary do: aBlock [
	<lang: #python match: '(call
        	function: (attribute
            	object: (identifier) ="ax" @ax
                attribute: (identifier) ="scatter" @plot
            )
        	arguments: (argument_list)
        ) @call' sample: 'ax.scatter(X, Y)'>
	
	^ aBlock
		value: (aDictionary at: 'call')
		value: (self new factory: (aDictionary at: 'call') factory;
			createReplacementOfArgs: (aDictionary at: 'call') access arguments buildCopy)
]

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
