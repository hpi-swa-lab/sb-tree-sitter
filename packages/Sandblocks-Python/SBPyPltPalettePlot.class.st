"
Palette for SBPyPltPlot's, i.e. ax.plot(), arguments.
"
Class {
	#name : #SBPyPltPalettePlot,
	#superclass : #SBPyPltPaletteLine2d,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltPalettePlot class >> buildOn: aBuilder [
	aBuilder addSectionHeader: 'Plot Parameter'.
	super buildOn: aBuilder.
]
