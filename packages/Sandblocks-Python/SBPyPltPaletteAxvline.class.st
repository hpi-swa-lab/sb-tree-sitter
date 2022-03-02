"
Palette for SBPyPltAxvline 's, i.e. ax.axvline(), arguments.
"
Class {
	#name : #SBPyPltPaletteAxvline,
	#superclass : #SBPyPltPaletteLine2d,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltPaletteAxvline class >> buildOn: aBuilder [
	aBuilder addSectionHeader: 'Axvline Parameter'.
	super buildOn: aBuilder.
]
