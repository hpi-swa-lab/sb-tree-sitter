"
I am the class representing the matplotlib plot function
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
			createReplacementOfArgs: (aDictionary at: 'call') access arguments)
			
		
]

{ #category : #'initialize-release' }
SBPyPltPlot >> createReplacementOfArgs: aTSBlock [
"creates plot replacement, nesting the replacements of aTSBlock inside."

	self addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: 'line plot:');
			addMorphBack: (SBPyPltPlotArgs new factory: (SBPython instance); wrapInReplacement: (aTSBlock buildCopy));
			addMorphBack: (SBPyPltImage linePlot);
			cellGap: 4
		).
]

{ #category : #'initialize-release' }
SBPyPltPlot >> isAxes [
	"indicates whether this replacement is to be shown in the Axes Palette"

	^ true
]

{ #category : #'initialize-release' }
SBPyPltPlot >> palettes [

	^ super palettes,{SBPyPltPalettePlot}
]

{ #category : #'as yet unclassified' }
SBPyPltPlot >> writeSourceOn: aStream [

	aStream nextPutAll: 'ax.plot'.
	(self firstSubmorph submorphs asOrderedCollection at: 2) writeSourceOn: aStream.
]
