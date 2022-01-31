"
This is the entry palette for matplotlib.
"
Class {
	#name : #SBPyPltPaletteEntry,
	#superclass : #SBPyPalette,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltPaletteEntry class >> buildOn: aBuilder [
	
	aBuilder addHeader: 'Matplotlib'.
	aBuilder addBlock: 'Enter matplotlib context' as: (SBPyPltInitPlots new factory: (SBPython instance); createReplacement).
	aBuilder addBlock: 'Show figure' as: (SBPyPltShowPlots new factory: (SBPython instance); createReplacement).

	
	aBuilder addBlock: 'alt' as: (SBPyPltOtherPaletteEntry new factory: (SBPython instance); createReplacement).
]

{ #category : #'as yet unclassified' }
SBPyPltPaletteEntry class >> language [
"show in all contexts"

	^ #python
]
