"
Base class for alll calls on axes grouped under ""Axis labels, title, and legend"", https://matplotlib.org/stable/api/axes_api.html#axis-labels-title-and-legend. The axes must have been initialized with SBPyPltInitPlots before.
"
Class {
	#name : #SBPyPltAxis,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Matplotlib'
}

{ #category : #classification }
SBPyPltAxis >> palettes [

	^ {SBPyPltPaletteOverview}
]

{ #category : #classification }
SBPyPltAxis >> type [
	^ 'call'
]