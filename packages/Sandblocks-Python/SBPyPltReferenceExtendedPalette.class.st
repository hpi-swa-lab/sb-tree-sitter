"
This replacement opens SBPyPltPalettePlotExtended. Its only for test purposes to compare it with SBPyPltPalettePlot.
"
Class {
	#name : #SBPyPltReferenceExtendedPalette,
	#superclass : #SBInlineBlockReplace,
	#instVars : [
		'image'
	],
	#category : #'Sandblocks-Python'
}

{ #category : #'initialize-release' }
SBPyPltReferenceExtendedPalette >> createReplacement [

	self addMorphBack: (SBButton new icon: SBIcon iconPlay label: 'alternative' do: [nil]).
]

{ #category : #'as yet unclassified' }
SBPyPltReferenceExtendedPalette >> palettes [

	^ {SBPyPltPalettePlotExtended}
]

{ #category : #'as yet unclassified' }
SBPyPltReferenceExtendedPalette >> type [

	^ 'call'
]

{ #category : #'initialize-release' }
SBPyPltReferenceExtendedPalette >> writeSourceOn: aStream [
]
