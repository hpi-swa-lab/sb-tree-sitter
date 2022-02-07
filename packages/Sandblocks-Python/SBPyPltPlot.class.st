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
SBPyPltPlot >> createReplacementOfArgs: aSBTSFieldAccessor [

	self addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: 'line plot:');
			addMorphBack: aSBTSFieldAccessor;
			addMorphBack: (SBPyPltImage linePlot);
			cellGap: 4
		).
]

{ #category : #'initialize-release' }
SBPyPltPlot >> palettes [

	^ super palettes,{SBPyPltPalettePlot}
]

{ #category : #'as yet unclassified' }
SBPyPltPlot >> suggestAlways [
    "show suggestions even when just clicked, not just when I start typing"
    ^true
]

{ #category : #'initialize-release' }
SBPyPltPlot >> suggestions [
	| action |
	action := [:block :item |
        "insert just after the PyPltPlot block"
		self sandblockEditor do: (SBInsertCommand new
			container: (self ownerThatIsA: SBInlineBlockRepeat);
			morph: item preview;
			index: self submorphIndex + 1)].
	^ {
		(SBSuggestionItem selector: 'axes' label: 'attribute')
			preview: (SBPyPltDashes new
					factory: SBPython instance;
					createReplacementFromSequence: {'3'. '1'})
				previewOnly: false;
			completionAction: action.
		(SBSuggestionItem selector: 'array' label: 'attribute')
			preview: (SBPyPltData new
					factory: SBPython instance;
					createReplacement: 'X')
				previewOnly: false;
			completionAction: action}
]

{ #category : #'as yet unclassified' }
SBPyPltPlot >> writeSourceOn: aStream [

	aStream nextPutAll: 'ax.plot'.
	(self firstSubmorph submorphs asOrderedCollection at: 2) writeSourceOn: aStream.
]
