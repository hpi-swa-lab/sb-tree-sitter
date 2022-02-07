"
Base class for all python palettes. Palettes are referenced by the 'palettes' selector. See the sandblocks documentation for more details. 
"
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
]
