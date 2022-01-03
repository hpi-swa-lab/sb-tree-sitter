Class {
	#name : #SBPyPltPalettePlot,
	#superclass : #SBPalette,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltPalettePlot class >> buildOn: aBuilder [
	self halt.
	aBuilder addSectionHeader: 'Plot Parameter'.
	aBuilder addBlock: 'Set title of x or y label' as: 
		(SBPyPltSetLabel new 
			factory: SBPython instance;
			createReplacement: 'Your X-Axis' ofAxis: 'x').
]

{ #category : #'as yet unclassified' }
SBPyPltPalettePlot class >> context [

	^ {#isPyPltPlotParam understood. #isPyPltPlotParam}
]
