"
I am the class representing the matplotlib scatter
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
			createReplacementOfArgs: (aDictionary at: 'call') access arguments)
]

{ #category : #'initialize-release' }
SBPyPltScatter >> createReplacementOfArgs: aSBTSFieldAccessor [

	self addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: 'scatter:');
			addMorphBack: aSBTSFieldAccessor;
			addMorphBack: (SBPyPltImage scatterPlot);
			cellGap: 4
		).
]

{ #category : #'initialize-release' }
SBPyPltScatter >> palettes [

	^ super palettes,{SBPyPltPaletteScatter}
]

{ #category : #'as yet unclassified' }
SBPyPltScatter >> writeSourceOn: aStream [

	aStream nextPutAll: 'ax.scatter'.
	(self firstSubmorph submorphs asOrderedCollection at: 2) writeSourceOn: aStream.
]
