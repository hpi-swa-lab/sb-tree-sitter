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
			addMorphBack: (SBStringMorph new contents: 'line plot:(');
			addMorphBack: (SBPyPltPlotArgs new factory: (SBPython instance); wrapInReplacement: (aTSBlock buildCopy));
			addMorphBack: (SBStringMorph new contents: ')');
			addMorphBack: (SBPyPltImage linePlot);
			cellGap: 4
		).
]

{ #category : #'as yet unclassified' }
SBPyPltPlot >> createReplacementOfArgsAsStrings: anArray [

	| argBlocks argsLayout |
	
	argBlocks := anArray collect: [:aString | SBPython parseElement: aString].
	argsLayout := SBRow new cellGap: 2.
	argBlocks do: [:aBlock | argsLayout addMorphBack: aBlock ].
	
	self addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: 'line plot:(');
			addMorphBack: argsLayout;
			addMorphBack: (SBStringMorph new contents: ')');
			addMorphBack: (SBPyPltImage linePlot);
			cellGap: 4
		).
]

{ #category : #'initialize-release' }
SBPyPltPlot >> createReplacementOfArgsOld: aTSBlock [
"creates plot replacement, nesting the replacements of aTSBlock inside."
	| argBlocks argsLayout |
	
	argBlocks := aTSBlock children collect: [:arg | SBBlock new addMorphBack: arg buildCopy].
	argsLayout := SBColumn new.
	argBlocks do: [:aBlock | argsLayout addMorphBack: aBlock ].
	
	self addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: 'line plot:(');
			addMorphBack: (SBPyPltPlotArgs new factory: SBPython instance; wrapInReplacement: argsLayout);
			addMorphBack: (SBStringMorph new contents: ')');
			addMorphBack: (SBPyPltImage linePlot);
			cellGap: 4
		).
]

{ #category : #'initialize-release' }
SBPyPltPlot >> createReplacementWithY: aString [

	self addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: 'line plot:(');
			addMorphBack: (SBTextBubble new contents: aString);
			addMorphBack: (SBStringMorph new contents: ')');
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
	aStream nextPutAll: ((self firstSubmorph submorphs at: 2) firstSubmorph sourceString).
	aStream nextPutAll: '\n'
]
