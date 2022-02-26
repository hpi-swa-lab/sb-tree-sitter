"
Palette for SBPyPltPlot's, i.e. ax.plot(), arguments.
"
Class {
	#name : #SBPyPltPalettePlot,
	#superclass : #SBPyPalette,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltPalettePlot class >> buildOn: aBuilder [
	aBuilder addSectionHeader: 'Plot Parameter'.
	self buildOnLine2d: aBuilder.
]
