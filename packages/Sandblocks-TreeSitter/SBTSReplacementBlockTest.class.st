Class {
	#name : #SBTSReplacementBlockTest,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Tests'
}

{ #category : #'as yet unclassified' }
SBTSReplacementBlockTest >> testBuildMatplotlibPalette [

	SBPyPltPalettePlot buildOn: SBPaletteBuilder new.
	SBPyPltPaletteOverview buildOn: SBPaletteBuilder new
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlockTest >> testJavascriptWatch [

	| module editor |
	module := SBJavascript parseToplevel: 'a.b'.
	editor := self editorAndWorldFor: module.
	
	editor selectNoInput: module childSandblocks first.
	editor performForSelection: #wrapWithWatch.
	
	self assert: SBWatch2 equals: module childSandblocks first class.
	self assert: #statement equals: module childSandblocks first slot lastNode type.
	self
		assert: #expression
		equals: module childSandblocks first childSandblocks first slot lastNode type.
	module sourceString.
	
	"now edit the embedded expression in such a way that the root gets replaced"
	module lastDeepChild startInputAtEnd.
	self type: '.x' in: editor.
	self assert: (module sourceString includesSubstring: '.x')
]
