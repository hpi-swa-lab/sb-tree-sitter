"
Parent of all classes that are responsible for showing data points in matplotlib, e.g. plots, scatterplots, histograms.
"
Class {
	#name : #SBPyPltPlots,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltPlots >> isAxes [
	
	^ true
]

{ #category : #'as yet unclassified' }
SBPyPltPlots >> palettes [
	^ {SBPyPltPaletteOverview}
]

{ #category : #'as yet unclassified' }
SBPyPltPlots >> type [

	^ 'call'
]
