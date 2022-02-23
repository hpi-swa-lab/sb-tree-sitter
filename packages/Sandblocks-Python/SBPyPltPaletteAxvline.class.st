Class {
	#name : #SBPyPltPaletteAxvline,
	#superclass : #SBPyPalette,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltPaletteAxvline class >> buildOn: aBuilder [
	aBuilder addSectionHeader: 'Axvline Parameter'.
	
	self buildOnLine2d: aBuilder.
]
