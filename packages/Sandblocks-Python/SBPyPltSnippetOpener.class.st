"
Replaces all python booleans with checkboxes.
"
Class {
	#name : #SBPyPltSnippetOpener,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'initialize-release' }
SBPyPltSnippetOpener >> palettes [
	^ {SBPyPltPaletteSnippets}
]

{ #category : #'initialize-release' }
SBPyPltSnippetOpener >> replace [ 
	self addMorphBack: (SBStringMorph new contents: 'Show Snippets')
]

{ #category : #'initialize-release' }
SBPyPltSnippetOpener >> type [
	^ 'call'
]

{ #category : #'initialize-release' }
SBPyPltSnippetOpener >> writeSourceOn: aStream [
]
