"
This is a wrapper around the argument list of SBPyPltPlot which provides context for the SBPyPltPlotPalette
"
Class {
	#name : #SBPyPltPlotArgs,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltPlotArgs >> isPyPltPlotParam [
	"indicates that this is a parameter of matplotlib's ax.plot() method"
	^ true
]

{ #category : #'as yet unclassified' }
SBPyPltPlotArgs >> type [

	^ 'argument_list'
]

{ #category : #'as yet unclassified' }
SBPyPltPlotArgs >> wrapInReplacement: aSBInlineBlockSymbol [
	| arguments |
	arguments := (aSBInlineBlockSymbol firstSubmorph submorphs at: 2) submorphs.
	arguments do: [:arg | self addMorphBack: arg].
]
