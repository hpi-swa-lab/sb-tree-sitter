Class {
	#name : #SBTSBlockTest,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsCall [

	| module editor |
	module := SBTSFileParser new parse: 'a.b' language: SBJavascript instance.
	editor := self editorAndWorldFor: module.
	
	module childSandblocks first select.
	editor handle: (self keyboardEvent: $ ).
	editor handle: (self keyboardEvent: $().
	self assert: 'call_expression' equals: module childSandblocks first type.
	self assert: #arguments equals: editor selection type
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsMethodCall [

	| module editor |
	module := SBTSFileParser new parse: '' language: SBJavascript instance.
	editor := self editorAndWorldFor: module.
	module startInputAtEnd.
	editor handle: (self keyboardEvent: Character arrowRight).
	
	self type: 'console.log("Hello' in: editor.
	self assert: 'console.log("Hello")' equals: module sourceString
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsPatternToAssignmentPattern [

	| module editor |
	module := SBTSFileParser new parse: 'function(b) {}' language: SBJavascript instance.
	editor := self editorAndWorldFor: module.
	module childSandblocks first childSandblocks first startInputAtEnd.
	editor handle: (self keyboardEvent: $=).
	self tick.
	self tick.
	editor handle: (self keyboardEvent: Character arrowDown).
	editor handle: (self keyboardEvent: Character arrowDown).
	editor handle: (self keyboardEvent: Character arrowDown).
	editor handle: (self keyboardEvent: Character cr).
	
	self assert: 'assignment_pattern' equals: module childSandblocks first childSandblocks first type
]

{ #category : #'tests - cursor position' }
SBTSBlockTest >> testSkipsRepeatsInUntakenChoices [

	| module |
	module := SBTSFileParser new parse: 'a => 123' language: SBJavascript instance.
	module childSandblocks first cursorPositionsDo: [:pos | self assert: (pos isInsert not or: [pos command element isTSLabel and: [pos command element label = 'async']])]
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testSmalltalkBinaryOp [

	| method editor |
	method := SBTSFileParser new parse: 'abc 12' language: SBTSSmalltalk instance.
	editor := self editorAndWorldFor: method.
	
	method childSandblocks second startInputAtEnd.
	editor handle: (self keyboardEvent: $+).
	self assert: #'binary_message' equals: method childSandblocks second type.
	
	editor handle: (self keyboardEvent: $1).
	self assert: #number equals: method childSandblocks second childSandblocks last type
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testSmalltalkContinueInArray [

	| method editor |
	method := SBTSFileParser new parse: 'abc {}' language: SBTSSmalltalk instance.
	editor := self editorAndWorldFor: method.
	
	method childSandblocks second startInputAtEnd.
	editor handle: (self keyboardEvent: $$).
	self assert: #character equals: method childSandblocks second childSandblocks first type.
	editor handle: (self keyboardEvent: $a).
	self assert: '$a' equals: method childSandblocks second childSandblocks first contents
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testSmalltalkContinueInArrayAmbiguous [

	| method editor |
	method := SBTSFileParser new parse: 'abc {123}' language: SBTSSmalltalk instance.
	editor := self editorAndWorldFor: method.
	
	method childSandblocks second childSandblocks first startInputAtEnd.
	editor handle: (self keyboardEvent: $#).
	editor handle: (self keyboardEvent: $a).
	self assert: #symbol equals: method childSandblocks second childSandblocks second type
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testSmalltalkInsertKeywordPart [

	| module editor |
	module := SBTSFileParser new
		parse: 'method a test: 123 abc: 234'
		language: SBTSSmalltalk instance.
	editor := self editorAndWorldFor: module.
	module childSandblocks second startInputAtEnd.
	editor handle: (self keyboardEvent: Character arrowRight).
	editor handle: (self keyboardEvent: $a).
	self assert: 7 equals: module childSandblocks second childSandblocks size
]

{ #category : #'tests - cursor position' }
SBTSBlockTest >> testSmalltalkKeywordMessage [

	| module insertCount |
	module := SBTSFileParser new
		parse: 'method a test: 123 abc: 234'
		language: SBTSSmalltalk instance.
	
	insertCount := 0.
	module childSandblocks second cursorPositionsDo: [:pos | pos isInsert ifTrue: [insertCount := insertCount + 1]].
	self assert: 3 equals: insertCount
]

{ #category : #'tests - cursor position' }
SBTSBlockTest >> testSmalltalkTemporariesPositions [

	| module |
	module := SBTSFileParser new parse: 'abc | a b c |' language: SBTSSmalltalk instance.
	self
		assert: #(2 3 4 5)
		equals: (Array streamContents: [:stream | module childSandblocks second cursorPositionsDo: [:pos | pos isInsert ifTrue: [stream nextPut: pos command index]]]).
	
	module := SBTSFileParser new parse: 'abc ||' language: SBTSSmalltalk instance.
	self
		assert: #(2)
		equals: (Array streamContents: [:stream | module childSandblocks second cursorPositionsDo: [:pos | pos isInsert ifTrue: [stream nextPut: pos command index]]])
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testSmalltalkUnaryToKeyword [

	| method editor |
	method := SBTSFileParser new parse: 'abc a unary' language: SBTSSmalltalk instance.
	editor := self editorAndWorldFor: method.
	
	method childSandblocks second childSandblocks second startInputAtEnd.
	editor handle: (self keyboardEvent: $:).
	self assert: #'keyword_message' equals: method childSandblocks second type.
	self assert: #keyword equals: editor selection type.
	editor handle: (self keyboardEvent: $4).
	self assert: #number equals: editor selection type
]

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
