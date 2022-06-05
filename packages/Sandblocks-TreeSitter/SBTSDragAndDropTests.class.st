Class {
	#name : #SBTSDragAndDropTests,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Tests'
}

{ #category : #'as yet unclassified' }
SBTSDragAndDropTests >> testDragInsertPyArgument [

	| module editor |
	module := SBPython parseToplevel: 'call()'.
	editor := self editorFor: module.
	
	self class
		dropAt: module childSandblocks last childSandblocks last positionInWorld + (1 @ 1)
		with: (SBPython parseExpression: 'a')
		in: editor.
	self assert: 'call(a)' equals: module sourceString
]

{ #category : #'as yet unclassified' }
SBTSDragAndDropTests >> testDragInsertPyExprAsStmt [

	| module editor |
	module := SBPython parseToplevel: 'a
b'.
	editor := self editorFor: module.
	
	self class
		dropAt: module childSandblocks last positionInWorld - (0 @ 1)
		with: (SBPython parseExpression: 'c')
		in: editor.
	self assert: 'a
c
b' equals: module sourceString
]

{ #category : #'as yet unclassified' }
SBTSDragAndDropTests >> testDragInsertPyStatement [

	| module editor |
	module := SBPython parseToplevel: 'a
b'.
	editor := self editorFor: module.
	
	self class
		dropAt: module childSandblocks last positionInWorld - (0 @ 1)
		with: (SBPython parseExpression: 'c = 4')
		in: editor.
	self assert: 'a
c=4
b' equals: module sourceString
]

{ #category : #'as yet unclassified' }
SBTSDragAndDropTests >> testDragInsertPyStatementToArgument [

	| module editor |
	module := SBPython parseToplevel: 'call()'.
	editor := self editorFor: module.
	
	self class
		dropAt: module childSandblocks last childSandblocks last positionInWorld + (1 @ 1)
		with: (SBPython parseToplevel: 'a') childSandblocks first
		in: editor.
	self assert: 'call(a)' equals: module sourceString
]

{ #category : #'as yet unclassified' }
SBTSDragAndDropTests >> testRegexInsertInPattern [

	| module editor |
	module := SBRegex parseToplevel: 'ab'.
	editor := self editorFor: module.
	
	module width: 2000.
	module fullBounds.
	
	module := module childSandblocks first.
	
	self class
		dropAt: module childSandblocks first positionInWorld + (module childSandblocks first width @ 1)
		with: (SBRegex parseExpression: 'x') childSandblocks first
		in: editor.
	self assert: 'axb' equals: module sourceString
]

{ #category : #'as yet unclassified' }
SBTSDragAndDropTests >> testRegexQuantifierCanInsert [

	| module editor |
	module := SBRegex parseToplevel: 'ab'.
	editor := self editorFor: module.
	
	module width: 2000.
	module fullBounds.
	
	module := module childSandblocks first.
	
	self class
		dropAt: module childSandblocks first positionInWorld + (module childSandblocks first width @ 0)
		with: (SBRegex parseExpression: 'x+') childSandblocks last
		in: editor.
	self assert: 'a+b' equals: module sourceString
]

{ #category : #'as yet unclassified' }
SBTSDragAndDropTests >> testRegexQuantifierCanInsertLater [

	| module editor |
	module := SBRegex parseToplevel: 'a+b'.
	editor := self editorFor: module.
	
	module width: 2000.
	module fullBounds.
	
	module := module childSandblocks first.
	
	"used to be childSandblocks first --> we were allowing to not choose the closest insert position"
	self class
		dropAt: module childSandblocks last positionInWorld + (module childSandblocks first width + 1 @ 0)
		with: (SBRegex parseExpression: 'x+') childSandblocks last
		in: editor.
	self assert: 'a+b+' equals: module sourceString
]

{ #category : #'as yet unclassified' }
SBTSDragAndDropTests >> testRegexQuantifierCantReplace [

	| module editor |
	module := SBRegex parseToplevel: 'ab'.
	editor := self editorFor: module.
	
	self class
		dropAt: module childSandblocks last positionInWorld + (1 @ 1)
		with: (SBRegex parseExpression: 'x+')
		in: editor.
	self assert: 'ab' equals: module sourceString
]
