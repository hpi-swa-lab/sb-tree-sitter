Extension { #name : #SBPaletteBuilder }

{ #category : #'*Sandblocks-Regex' }
SBPaletteBuilder >> addText: aString [

	self content addMorphBack: (SBMultilineOwnTextMorph new
		contents: aString;
		maxWidth: 250)
]
