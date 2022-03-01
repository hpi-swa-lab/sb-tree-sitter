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
	aBuilder addBlock: 'Path' as: (SBPyFilepath new
		factory: SBPython new;
		path: '').
]

{ #category : #'as yet unclassified' }
SBPyPalette class >> collapse: aSBInlineBlock withSignature: aString [
"collapses the first statement of aSBInlineBlock and returns aSBInlineBlock"
	aSBInlineBlock access children first collapseBlock.
	aSBInlineBlock access children first submorphs first contents: 'def'.
	aSBInlineBlock access children first submorphs second contents: aString.
	^ aSBInlineBlock

]

{ #category : #'as yet unclassified' }
SBPyPalette class >> divider [
	^ (SBColumn new 
	layoutInset: (SBEdgeInsets left: 0 right: 0 top: 8 bottom: 8); 
	addMorphBack: (SBDivider new width: 200))
]
