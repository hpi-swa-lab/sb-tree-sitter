Class {
	#name : #SBTSDragAndDropTests,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Tests'
}

{ #category : #'as yet unclassified' }
SBTSDragAndDropTests >> testDragInsertPyArgument [

	| module editor |
	module := SBPython parse: 'call()'.
	editor := self editorFor: module.
	
	self class
		dropAt: module childSandblocks last childSandblocks last positionInWorld + (1 @ 1)
		with: (SBPython parseElement: 'a')
		in: editor.
	self assert: 'call(a)' equals: module sourceString
]

{ #category : #'as yet unclassified' }
SBTSDragAndDropTests >> testDragInsertPyExprAsStmt [

	| module editor |
	module := SBPython parse: 'a
b'.
	editor := self editorFor: module.
	
	self class
		dropAt: module childSandblocks last positionInWorld - (0 @ 1)
		with: (SBPython parseElement: 'c')
		in: editor.
	self assert: 'a
c
b' equals: module sourceString
]

{ #category : #'as yet unclassified' }
SBTSDragAndDropTests >> testDragInsertPyStatement [

	| module editor |
	module := SBPython parse: 'a
b'.
	editor := self editorFor: module.
	
	self class
		dropAt: module childSandblocks last positionInWorld - (0 @ 1)
		with: (SBPython parseElement: 'c = 4')
		in: editor.
	self assert: 'a
c=4
b' equals: module sourceString
]

{ #category : #'as yet unclassified' }
SBTSDragAndDropTests >> testRegexInsertInPattern [

	| module editor |
	module := SBRegex parse: 'ab'.
	editor := self editorFor: module.
	
	module := module childSandblocks first.
	
	self class
		dropAt: module childSandblocks first positionInWorld + (0 @ module childSandblocks last height)
		with: (SBRegex parse: 'x') childSandblocks last childSandblocks last
		in: editor.
	self assert: 3 equals: module firstSubmorph submorphCount.
	self assert: 'axb' equals: module sourceString
]

{ #category : #'as yet unclassified' }
SBTSDragAndDropTests >> testRegexQuantifierCanInsert [

	| module editor |
	module := SBRegex parse: 'ab'.
	editor := self editorFor: module.
	
	module := module childSandblocks first.
	
	self class
		dropAt: module childSandblocks first positionInWorld + (0 @ module childSandblocks first height)
		with: (SBRegex parse: 'x+') childSandblocks last childSandblocks last
		in: editor.
	self assert: 'a+b' equals: module sourceString
]

{ #category : #'as yet unclassified' }
SBTSDragAndDropTests >> testRegexQuantifierCanInsertLater [

	| module editor |
	module := SBRegex parse: 'a+b'.
	editor := self editorFor: module.
	
	module := module childSandblocks first.
	
	self class
		dropAt: module childSandblocks first positionInWorld + (0 @ module childSandblocks first height)
		with: (SBRegex parse: 'x+') childSandblocks last childSandblocks last
		in: editor.
	self assert: 'a+b+' equals: module sourceString
]

{ #category : #'as yet unclassified' }
SBTSDragAndDropTests >> testRegexQuantifierCantReplace [

	| module editor |
	module := SBRegex parse: 'ab'.
	editor := self editorFor: module.
	
	self class
		dropAt: module childSandblocks last positionInWorld + (1 @ 1)
		with: (SBRegex parse: 'x+') childSandblocks last
		in: editor.
	self assert: 'ab' equals: module sourceString
]

{ #category : #'as yet unclassified' }
SBTSDragAndDropTests >> testRegexReplaceUnknown [

	| module editor unknown |
	module := SBRegex parse: '1'.
	editor := self editorFor: module.
	
	module lastDeepChild parentSandblock addBlock: SBReComment new.
	unknown := module nextBlockThat: #isUnknown.
	unknown ensureLayouted.
	
	self class dropAt: unknown positionInWorld + (1 @ 1) with: (SBRegex parseElement: '2') in: editor.
	self assert: (module sourceString includes: $2)
]
