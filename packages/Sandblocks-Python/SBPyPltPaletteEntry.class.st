"
Entry palette for matplotlib.
"
Class {
	#name : #SBPyPltPaletteEntry,
	#superclass : #SBPyPalette,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltPaletteEntry class >> buildOn: aBuilder [
	
	aBuilder addHeader: 'Matplotlib'.
	aBuilder addSectionHeader: 'Matplotlib Init'.	
	aBuilder addBlock: 'Enter matplotlib context' as: (SBPyPltInitPlots new factory: (SBPython instance); createReplacement).
	aBuilder addBlock: 'Show figure' as: (SBPyPltShowPlots new factory: (SBPython instance); createReplacement).
]

{ #category : #'as yet unclassified' }
SBPyPltPaletteEntry class >> language [
"show in all contexts.

NOTE: this is turned off for now because we want SBPyPltPaletteOverview visible in all python contexts, not just the this palette.
"

	"^ #python"
]
