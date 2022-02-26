"
Replacement for ax.plot
"
Class {
	#name : #SBPyPltPlot,
	#superclass : #SBPyPltPlots,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltPlot class >> match: aDictionary do: aBlock [
	<lang: #python match: '(call
        	function: (attribute
            	object: (identifier) ="ax" @ax
                attribute: (identifier) ="plot" @plot
            )
        	arguments: (argument_list)
        ) @call' sample: 'ax.plot(Y)'>
	
	^ aBlock
		value: (aDictionary at: 'call')
		value: (self new factory: (aDictionary at: 'call') factory;
			createReplacementOfArgs: (aDictionary at: 'call') access arguments buildCopy)
			
		
]

{ #category : #'initialize-release' }
SBPyPltPlot >> createReplacementOfArgs: aSBTSFieldAccessor [
		
	self addMorphBack: (SBRow new
		addMorphBack: (AlignmentMorph newColumn 
			color: Color transparent; 
			hResizing: #shrinkWrap; 
			addMorphBack: (AlignmentMorph newSpacer: Color transparent);
			addMorphBack: (SBStringMorph new contents: 'line plot:');
			addMorphBack: (SBPyPltImage linePlot);
			addMorphBack: (AlignmentMorph newSpacer: Color transparent)
		 );
		addMorphBack: aSBTSFieldAccessor;
		cellGap: 4
	)
]

{ #category : #'initialize-release' }
SBPyPltPlot >> palettes [

	^ {SBPyPltPalettePlot}, super palettes
]

{ #category : #'as yet unclassified' }
SBPyPltPlot >> writeSourceOn: aStream [

	aStream nextPutAll: 'ax.plot'.
	(self firstSubmorph submorphs second) writeSourceOn: aStream.
]
