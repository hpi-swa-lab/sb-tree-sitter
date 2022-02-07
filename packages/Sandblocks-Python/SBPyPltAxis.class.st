"
Base class for all customizations of matplotlib axes. These blocks can be applied to plots, which first must have been initialized with SBPyPltInitPlots.
"
Class {
	#name : #SBPyPltAxis,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltAxis >> palettes [

	^ {SBPyPltPaletteOverview}
]

{ #category : #'as yet unclassified' }
SBPyPltAxis >> type [
	^ 'call'
]
