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

	self
		layoutPolicy: SBAlgebraLayout new;
		addMorphBack: (SBColumn new
			hResizing: #shrinkWrap;
			cellPositioning: #center;
			layoutInset: 2;
			addMorphBack: (SBStringMorph new contents: 'scatter:');
			addMorphBack: SBPyPltImage scatterPlot);
		addMorphBack: (self createBindingBlock: 'args')
]

{ #category : #'initialize-release' }
SBPyPltScatter >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: (self submorphs collect: #layoutCommands separatedBy: [SBAlgebraCommand softLineOrGap])
]

{ #category : #'initialize-release' }
SBPyPltScatter >> palettes [

	^ {SBPyPltPaletteScatter. SBPyPltPaletteOverview}, super palettes
]
