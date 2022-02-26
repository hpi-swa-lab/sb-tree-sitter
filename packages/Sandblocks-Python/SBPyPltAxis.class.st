"
Base class for alll calls on axes grouped under ""Axis labels, title, and legend"", https://matplotlib.org/stable/api/axes_api.html#axis-labels-title-and-legend. The axes must have been initialized with SBPyPltInitPlots before.
"
Class {
	#name : #SBPyPltAxis,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltAxis >> palettes [

	^ {SBPyPltPaletteOverview}
]

{ #category : #'as yet unclassified' }
SBPyPltAxis >> type [
	^ 'call'
]
