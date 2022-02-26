"
Base class for all axes calls that are responsible for showing data points in matplotlib, e.g. plots, scatterplots, histograms. For the full list, see https://matplotlib.org/stable/api/axes_api.html#subplots
"
Class {
	#name : #SBPyPltPlots,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltPlots >> palettes [
	^ {SBPyPltPaletteOverview}
]

{ #category : #'as yet unclassified' }
SBPyPltPlots >> type [

	^ 'call'
]
