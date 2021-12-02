Class {
	#name : #SBPyPltPalette,
	#superclass : #SBTSPalette,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltPalette class >> buildOn: aBuilder [

	aBuilder addSectionHeader: 'Matplotlib'.
	aBuilder addBlock: 'Create Figure' as: 
		(SBPyPltSubplots new 
			factory: SBPython new;
			createFigureButtonFrom: (self newNullBlock: 'Axes type')).
	aBuilder addBlock: 'Add plot' as:
		(SBPyPltPlot new 
			factory: SBPython instance;
			createReplacementWithX: 'X' Y: 'Y').
	aBuilder addBlock: 'Set title of x or y label' as: 
		(SBPyPltSetLabel new 
			factory: SBPython instance;
			createReplacement: 'Your X-Axis' ofAxis: 'x').
	aBuilder addBlock: 'Set limits of x or y label' as:
		(SBPyPltSetLim new
			factory: SBPython instance;
			createReplacementFrom: '0' to: '30' ofAxis: 'y').
]

{ #category : #'as yet unclassified' }
SBPyPltPalette class >> language [

	^ #python
]
