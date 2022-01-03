Class {
	#name : #SBPyPalette,
	#superclass : #SBTSPalette,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPalette class >> buildOn: aBuilder [

	aBuilder addSectionHeader: 'Python'.
	aBuilder addBlock: 'Open' as: (SBPython parse: 'open("")').
	aBuilder addBlock: 'Path' as: (SBPyFilepath new
		factory: SBPython new;
		path: '').
	aBuilder addBlock: 'Create Figure' as: 
		(SBPyPltSubplots new 
			factory: SBPython new;
			createFigureButtonFrom: (self newNullBlock: 'Axes type')).
]

{ #category : #'as yet unclassified' }
SBPyPalette class >> language [

	^ #python
]
