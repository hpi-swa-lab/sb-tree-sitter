"
This is the parent class for all palettes for matplotlib. The palettes are referenced by the 'palettes' selector of the replacements. They are shown when the user clicks on a block which itself or whose parent blocks reference the palette. See the sandblocks documentation for more details. 
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

{ #category : #'as yet unclassified' }
SBPyPalette class >> languageOld [

	^ #python
]
