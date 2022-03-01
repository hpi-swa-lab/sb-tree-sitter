"
Replacement for ax.scatter
"
Class {
	#name : #SBPyPltScatter,
	#superclass : #SBPyPltPlots,
	#category : #'Sandblocks-Python'
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
SBPyPltScatter >> createReplacementOfArgs: aSBTSFieldAccessor [
		
	self addMorphBack: (SBRow new
		addMorphBack: (AlignmentMorph newColumn 
			color: Color transparent; 
			hResizing: #shrinkWrap;
			addMorphBack: (AlignmentMorph newSpacer: Color transparent);
			addMorphBack: (SBStringMorph new contents: 'scatter:');
			addMorphBack: (SBPyPltImage scatterPlot);
			addMorphBack: (AlignmentMorph newSpacer: Color transparent)
		);
		addMorphBack: aSBTSFieldAccessor;
		cellGap: 4
	)
]

{ #category : #'initialize-release' }
SBPyPltScatter >> palettes [

	^ {SBPyPltPaletteScatter}, super palettes
]

{ #category : #copying }
SBPyPltScatter >> writeSourceOn: aStream [

	aStream nextPutAll: 'ax.scatter'.
	(self firstSubmorph submorphs second) writeSourceOn: aStream.
]
