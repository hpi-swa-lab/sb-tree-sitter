"
This replacement is the starting point for all matplotlib related content.
"
Class {
	#name : #SBPyPltOtherPaletteEntry,
	#superclass : #SBInlineBlockReplace,
	#instVars : [
		'image'
	],
	#category : #'Sandblocks-Python'
}

{ #category : #'initialize-release' }
SBPyPltOtherPaletteEntry >> createReplacement [

	self addMorphBack: (SBButton new icon: SBIcon iconPlay label: 'alternative' do: [nil]).
]

{ #category : #'as yet unclassified' }
SBPyPltOtherPaletteEntry >> palettes [

	^ {SBPyPltPalettePlotExtended}
]

{ #category : #'as yet unclassified' }
SBPyPltOtherPaletteEntry >> type [

	^ 'call'
]

{ #category : #'initialize-release' }
SBPyPltOtherPaletteEntry >> writeSourceOn: aStream [
]
