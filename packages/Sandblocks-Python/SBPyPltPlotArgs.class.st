"
This is a wrapper around the argument list of SBPyPltPlot which provides context for the SBPyPltPlotPalette
"
Class {
	#name : #SBPyPltPlotArgs,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltPlotArgs >> palettes [
	^ {SBPyPltPalettePlot}
]

{ #category : #'as yet unclassified' }
SBPyPltPlotArgs >> type [

	^ 'argument_list'
]

{ #category : #'as yet unclassified' }
SBPyPltPlotArgs >> wrapInReplacement: aSBInlineBlockSymbol [
	self addAllMorphsBack: (aSBInlineBlockSymbol submorphs).
]

{ #category : #'as yet unclassified' }
SBPyPltPlotArgs >> writeSourceOn: aStream [

	((1 to: (self submorphCount-1)) do: [ :i |
			(self submorphs asOrderedCollection at: i) writeSourceOn: aStream.
			aStream nextPutAll: ', '.
		]).
	"write last one w/o comma"
	(self submorphs asOrderedCollection at: (self submorphCount)) writeSourceOn: aStream.
]
