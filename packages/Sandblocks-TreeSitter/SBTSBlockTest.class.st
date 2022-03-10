Class {
	#name : #SBTSBlockTest,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'tests - cursor position' }
SBTSBlockTest >> testTypingArray [

	| module editor |
	module := SBTSFileParser new parse: '{}' language: SBJavascript instance.
	editor := self editorAndWorldFor: module.
	module childSandblocks first startInputAtEnd.
	editor handle: (SBTest keyboardEvent: $[).
	self tick.
	self tick.
	editor handle: (SBTest keyboardEvent: Character cr).
	
	self
		assert: 'array'
		equals: module childSandblocks first childSandblocks first type.
	self
		assert: module childSandblocks first childSandblocks last
		equals: editor selection.
	self assert: #insert equals: editor cursor mode
]

{ #category : #'tests - cursor position' }
SBTSBlockTest >> testTypingBinary [

	| module editor |
	module := SBTSFileParser new parse: '2' language: SBJavascript instance.
	editor := self editorFor: module.
	module childSandblocks first startInputAtEnd.
	editor handle: (SBTest keyboardEvent: $+).
	editor handle: (SBTest keyboardEvent: $1).
	
	self assert: 'binary_expression' equals: module childSandblocks first type.
	self
		assert: module childSandblocks first childSandblocks last
		equals: editor selection.
	self assert: 2 equals: editor selection currentTextMorph cursor
]

{ #category : #'tests - cursor position' }
SBTSBlockTest >> testTypingClosure [

	| module editor |
	module := SBTSFileParser new parse: '{}' language: SBJavascript instance.
	editor := self editorAndWorldFor: module.
	module childSandblocks first startInputAtEnd.
	editor handle: (SBTest keyboardEvent: $().
	self tick.
	self tick.
	editor handle: (SBTest keyboardEvent: Character arrowDown).
	editor handle: (SBTest keyboardEvent: Character cr).
	
	self assert: 'arrow_function' equals: module childSandblocks first childSandblocks first type.
	self assert: 'pattern' equals: editor cursor cursorPosition command element alternatives first type.
	self assert: #insert equals: editor cursor mode
]
