"
Entry palette for matplotlib.
"
Class {
	#name : #SBPyPltPaletteEntry,
	#superclass : #SBPyPalette,
	#category : #'Sandblocks-Matplotlib'
}

{ #category : #'as yet unclassified' }
SBPyPltPaletteEntry class >> buildOn: aBuilder [

	aBuilder addHeader: 'Matplotlib'.
	aBuilder addSectionHeader: 'Matplotlib Init'.
	aBuilder
		addBlock: 'Enter matplotlib context'
		as: (SBPython parseExpression: 'fig, ax = plt.subplots()') applyReplacement.
	aBuilder addBlock: 'Show figure' as: (SBPython parseExpression: 'plt.show()') applyReplacement
]

{ #category : #'as yet unclassified' }
SBPyPltPaletteEntry class >> language [
"skipped for now because SBPyPltPaletteOverview is shown instead and includes self buildOn:. This is done so the matplotlib overview is visible between two matplotlib calls, too."
	"^ #python"
]
