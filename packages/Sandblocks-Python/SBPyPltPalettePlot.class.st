"
This is the palette for the arguments of SBPyPltPlot.
"
Class {
	#name : #SBPyPltPalettePlot,
	#superclass : #SBPyPalette,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltPalettePlot class >> buildOn: aBuilder [
	aBuilder addSectionHeader: 'Plot Parameter'.
	aBuilder addBlock: 'Set the alpha value used for blending - not supported on all backends.' as: 
		(SBPyPltAlpha new factory: SBPython instance; createReplacement: '0.5').
	aBuilder addBlock: 'Set the color of the line.' as:
		(SBPyPltColor new factory: SBPython instance; createReplacement: 'blue').
]

{ #category : #'as yet unclassified' }
SBPyPltPalettePlot class >> context [

	^ super context,{[:aBlock | aBlock relatedClass canUnderstand: #isPyPltPlotParam]. #isPyPltPlotParam}
]
