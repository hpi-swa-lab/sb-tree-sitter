"
Base class for all python palettes. Palettes are referenced by the static 'palettes' selector.
"
Class {
	#name : #SBPyPalette,
	#superclass : #SBTSPalette,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPalette class >> asSubSectionText: aString [
	^ SBMultilineOwnTextMorph new
			contents: (aString asText addAttribute: (TextFontChange fontNumber: 1));
			maxWidth: 150;
			yourself
]

{ #category : #'as yet unclassified' }
SBPyPalette class >> buildOn: aBuilder [

	aBuilder addSectionHeader: 'Python'.
	aBuilder addBlock: 'Open' as: (SBPython parse: 'open("")').
	aBuilder addBlock: 'Path' as: (SBPyFilePath new
		factory: SBPython new;
		path: '')
]

{ #category : #'as yet unclassified' }
SBPyPalette class >> collapse: aBlock withSignature: aString [

	| collapsed |
	collapsed := aBlock collapseBlock.
	collapsed firstSubmorph contents: 'def'.
	collapsed lastSubmorph contents: aString.
	^ collapsed
]

{ #category : #'as yet unclassified' }
SBPyPalette class >> divider [
	^ (SBColumn new 
	layoutInset: (SBEdgeInsets left: 0 right: 0 top: 8 bottom: 8); 
	addMorphBack: (SBDivider new width: 200))
]
