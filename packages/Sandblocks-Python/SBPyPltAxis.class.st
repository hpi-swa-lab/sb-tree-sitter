"
Base class for all customizations of matplotlib axes. The axis must have been initialized with SBPyPltInitPlots before.
"
Class {
	#name : #SBPyPltAxis,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltAxis >> palettes [

	^ {SBPyPltPaletteEntry. SBPyPltPaletteOverview}
]

{ #category : #'as yet unclassified' }
SBPyPltAxis >> type [
	^ 'call'
]
