Class {
	#name : #SBTSBlockTest,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #failures }
SBTSBlockTest >> expectedFailures [

	^ #(#testJsAmbiguousCall #testDeleteInRepeat)
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testBashCommand [

	| program editor |
	program := SBTSFileParser new parse: '' language: SBBash.
	editor := self editorAndWorldFor: program.
	
	program startInputAtEnd.
	self type: 'ls' in: editor
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testBinaryOpOnMemberExpression [

	| module editor |
	module := SBTSFileParser new parse: 'req.query' language: SBJavascript instance.
	editor := self editorAndWorldFor: module.
	module lastDeepChild startInputAtEnd.
	
	self type: '==2' in: editor.
	self assert: 'req.query==2' equals: module sourceString
]

{ #category : #'tests - cursor position' }
SBTSBlockTest >> testCursorPositionsAroundUnknown [

	| module |
	module := SBTSFileParser new parse: '2+x' language: SBJavascript instance.
	self editorFor: module.
	module childSandblocks first childSandblocks last changeToUnknown.
	self assert: (Array streamContents: [:stream | module childSandblocks first cursorPositionsDo: [:pos | stream nextPut: pos]]) size >= 5
]

{ #category : #'tests - deleting' }
SBTSBlockTest >> testDeleteInRepeat [

	| module editor |
	module := SBTSFileParser new parse: '[1,2]' language: SBJavascript.
	editor := self editorFor: module.
	module lastDeepChild startInputAtEnd.
	6 timesRepeat: [editor handle: (self keyboardEvent: Character backspace)].
	self assert: '' equals: module sourceString
]

{ #category : #'tests - deleting' }
SBTSBlockTest >> testDeleteStBinaryOpStatement [

	| method editor |
	method := SBTSFileParser new parse: 'method a + 9' language: SBTSSmalltalk.
	editor := self editorFor: method.
	method lastDeepChild startInputAtEnd.
	editor handle: (self keyboardEvent: Character backspace).
	editor handle: (self keyboardEvent: Character backspace).
	self assert: method sourceString equals: 'method
a+'.
	editor handle: (self keyboardEvent: Character backspace).
	editor handle: (self keyboardEvent: Character backspace).
	self assert: method sourceString equals: 'method
a'.
	editor handle: (self keyboardEvent: Character backspace).
	editor handle: (self keyboardEvent: Character backspace).
	self assert: method sourceString equals: 'method'.
	self assert: 1 equals: method childSandblocks size
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testForwardToAdjacentStatement [
	<timeout: 2>

	| module editor |
	module := SBTSFileParser new parse: '2;
() => 3' language: SBJavascript.
	editor := self editorFor: module.
	module lastDeepChild changeToUnknown.
	module childSandblocks first startInputAtEnd.
	editor handle: (self keyboardEvent: $,).
	"no change expected, but we had some issues with input forwarding causing infinite loop"
	self assert: '2
()=>' equals: module sourceString
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsAmbiguousCall [

	| module editor |
	module := SBTSFileParser new parse: '' language: SBJavascript.
	editor := self editorFor: module.
	module startInsertAtEnd.
	
	self type: 'a(' in: editor.
	self assert: 'call_expression' equals: module childSandblocks first type
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsCall [

	| module editor |
	module := SBTSFileParser new parse: 'a.b' language: SBJavascript instance.
	editor := self editorAndWorldFor: module.
	
	module childSandblocks first select.
	editor handle: (self keyboardEvent: $ ).
	editor handle: (self keyboardEvent: $().
	self assert: #call_expression equals: module childSandblocks first type.
	self assert: #call_expression equals: editor cursor cursorPosition block type.
	self assert: editor cursor cursorPosition isInsert
]

{ #category : #'tests - modify' }
SBTSBlockTest >> testJsCallToSubscript [

	| module editor |
	module := SBTSFileParser new parse: 'abc(12)' language: SBJavascript.
	editor := self editorFor: module.
	module childSandblocks first startInputAtEnd.
	editor handle: (self keyboardEvent: Character backspace).
	editor handle: (self keyboardEvent: $[).
	self assert: 'subscript_expression' equals: module childSandblocks first type
]

{ #category : #'tests - deleting' }
SBTSBlockTest >> testJsChangePlusToMinus [

	| module editor |
	module := SBTSFileParser new parse: '2+3' language: SBJavascript.
	editor := self editorAndWorldFor: module.
	module lastDeepChild startInputAtEnd.
	editor handle: (self keyboardEvent: Character backspace).
	editor handle: (self keyboardEvent: Character backspace).
	self assert: '2+' equals: module sourceString.
	editor handle: (self keyboardEvent: Character backspace).
	self assert: '2' equals: module sourceString.
	editor handle: (self keyboardEvent: $-).
	self assert: '2-', Character null equals: module sourceStringForCompare.
	editor handle: (self keyboardEvent: $4).
	self assert: '2-4' equals: module sourceStringForCompare
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsClassField [

	| module editor |
	module := SBTSFileParser new parse: 'class {}' language: SBJavascript.
	editor := self editorAndWorldFor: module.
	module lastDeepChild startInsertAtEnd.
	self type: 'prop' in: editor.
	self assert: 'prop' equals: module lastDeepChild contents
]

{ #category : #'tests - deleting' }
SBTSBlockTest >> testJsDeleteDeclaration [

	| module editor |
	module := SBTSFileParser new parse: 'const a = 5' language: SBJavascript.
	editor := self editorFor: module.
	module lastDeepChild startInputAtEnd.
	
	editor handle: (self keyboardEvent: Character backspace).
	self assert: 'const a=', Character null equals: module sourceStringForCompare.
	editor handle: (self keyboardEvent: Character backspace).
	self assert: 'const a' equals: module sourceStringForCompare.
	editor handle: (self keyboardEvent: Character backspace).
	self assert: 'const', Character null equals: module sourceStringForCompare.
	editor handle: (self keyboardEvent: Character backspace).
	self assert: '' equals: module sourceStringForCompare
]

{ #category : #'tests - deleting' }
SBTSBlockTest >> testJsDeleteFunction [

	| module editor |
	module := SBTSFileParser new parse: '1 + function a() {}' language: SBJavascript.
	editor := self editorFor: module.
	module childSandblocks first childSandblocks second childSandblocks first startInputAtEnd.
	2 timesRepeat: [editor handle: (self keyboardEvent: Character backspace)].
	self assert: '1+function()
{
}' equals: module sourceStringForCompare.
	self assert: module childSandblocks first childSandblocks second equals: editor selection.
	'function' size + 1 timesRepeat: [editor handle: (self keyboardEvent: Character backspace)].
	self assert: '1+' equals: module sourceString
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsExpandObject [

	| module editor |
	module := SBTSFileParser new parse: 'const a = {id}' language: SBJavascript instance.
	editor := self editorAndWorldFor: module.
	module lastDeepChild startInputAtEnd.
	self type: ':x' in: editor.
	self assert: 'const a={id:x}' equals: module sourceString
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
SBTSBlockTest >> testJsNestedMethodCall [

	| module editor |
	module := SBTSFileParser new
		parse: 'res.send().status'
		language: SBJavascript instance.
	editor := self editorAndWorldFor: module.
	module lastDeepChild startInputAtEnd.
	self type: '(x' in: editor.
	self assert: 'res.send().status(x)' equals: module sourceString
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsNumberToString [

	| module editor |
	module := SBTSFileParser new parse: '123' language: SBJavascript instance.
	editor := self editorAndWorldFor: module.
	module lastDeepChild startInputAtStart.
	self type: '''' in: editor.
	self assert: '''123''' equals: module sourceString
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

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsTypeAssignment [

	| module editor |
	module := SBTSFileParser new parse: '' language: SBJavascript.
	editor := self editorAndWorldFor: module.
	
	module startInputAtEnd.
	editor handle: (self keyboardEvent: Character arrowRight).
	self type: 'const a=5' in: editor.
	self assert: 'const a=5' equals: module childSandblocks first sourceString
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsTypeObject [

	| module editor |
	module := SBTSFileParser new parse: 'const a = {}' language: SBJavascript instance.
	editor := self editorAndWorldFor: module.
	module lastDeepChild startInsertAtEnd.
	self type: 'id:x' in: editor.
	self assert: 'const a={id:x}' equals: module sourceString
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testNewStatementAfterTransition [

	| method editor |
	method := SBTSFileParser new parse: 'abc 123' language: SBTSSmalltalk.
	editor := self editorFor: method.
	method lastDeepChild startInputAtEnd.
	self type: '+3
12' in: editor.
	self assert: 3 equals: method childSandblocks size
]

{ #category : #'tests - deleting' }
SBTSBlockTest >> testPyDeleteReturnType [

	| program |
	program := SBTSFileParser new parse: 'def a() -> int:
	pass' language: SBPython.
	self editorFor: program.
	program childSandblocks first childSandblocks second select; deleteBlock.
	self assert: 'def a():
	pass' equals: program sourceString
]

{ #category : #'tests - deleting' }
SBTSBlockTest >> testPyDeleteStatement [

	| program |
	program := SBTSFileParser new parse: 'a' language: SBPython.
	self editorFor: program.
	program childSandblocks first select; deleteBlock.
	self assert: 0 equals: program childSandblocks size
]

{ #category : #'tests - deleting' }
SBTSBlockTest >> testPyDeleteStatements [

	| program |
	program := SBTSFileParser new parse: 'a
b
c' language: SBPython.
	self editorFor: program.
	program childSandblocks second deleteBlock.
	self assert: 2 equals: program childSandblocks size
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testPyIfStatement [

	| program editor |
	program := SBTSFileParser new parse: '' language: SBPython.
	editor := self editorAndWorldFor: program.
	program startInsertAtEnd.
	self type: 'if' in: editor.
	self tick.
	self tick.
	editor handle: (self keyboardEvent: Character arrowDown).
	editor handle: (self keyboardEvent: Character cr).
	self assert: 'if_statement' equals: program childSandblocks first type
]

{ #category : #'tests - deleting' }
SBTSBlockTest >> testRegexDeleteCountQuantifier [

	| term editor |
	term := SBTSFileParser new parse: '[0]{0}' language: SBRegex.
	editor := self editorFor: term.
	term lastDeepChild select deleteBlock.
	self assert: '[0]' equals: term sourceString
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testRegexEnterClassRanges [

	| term editor |
	term := SBTSFileParser new parse: 'a' language: SBRegex.
	editor := self editorFor: term.
	term startInsertAtEnd.
	self type: '[A-Za-z]' in: editor.
	self assert: 'a[A-Za-z]' equals: term sourceString
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
	editor handle: (self keyboardEvent: $b).
	self assert: 7 equals: module childSandblocks second childSandblocks size.
	self assert: 'a test:123 abc:234 ab' equals: module childSandblocks second sourceString
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
SBTSBlockTest >> testSmalltalkTypeKeywordSignature [

	| module editor |
	module := SBTSFileParser new parse: 'unary' language: SBTSSmalltalk instance.
	editor := self editorAndWorldFor: module.
	module childSandblocks first childSandblocks first startInputAtEnd.
	editor handle: (self keyboardEvent: $:).
	editor handle: (self keyboardEvent: $t).
	editor handle: (self keyboardEvent: $e).
	self assert: 2 equals: module childSandblocks first childSandblocks size.
	self assert: 'unary:te' equals: module childSandblocks first sourceString
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testSmalltalkUnaryToKeyword [

	| method editor |
	method := SBTSFileParser new parse: 'abc a unary' language: SBTSSmalltalk instance.
	editor := self editorAndWorldFor: method.
	
	method childSandblocks second childSandblocks second startInputAtEnd.
	editor handle: (self keyboardEvent: $:).
	self assert: #'keyword_message' equals: method childSandblocks second type.
	editor handle: (self keyboardEvent: $4).
	self assert: #number equals: editor selection type
]

{ #category : #'tests - deleting' }
SBTSBlockTest >> testStDeleteAroundExpression [

	| module |
	module := SBTSFileParser new parse: 'abc a test: 123' language: SBTSSmalltalk.
	self editorFor: module.
	module lastDeepChild select.
	module lastDeepChild deleteAround.
	self assert: '123' equals: module childSandblocks second sourceString.
	self assert: 'statement' equals: module childSandblocks second slot lastNode type
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testStUnaryMessageSend [

	| method editor |
	method := SBTSFileParser new parse: 'a test' language: SBTSSmalltalk.
	editor := self editorAndWorldFor: method.
	method childSandblocks second startInputAtEnd.
	self type: ' ' in: editor.
	self type: 'show' in: editor.
	self assert: #'unary_message' equals: method childSandblocks second type
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testTypeSeparator [

	| module editor |
	module := SBTSFileParser new parse: 'function(a) {}' language: SBJavascript.
	editor := self editorFor: module.
	module childSandblocks first childSandblocks first startInputAtEnd.
	editor handle: (self keyboardEvent: $,).
	editor handle: (self keyboardEvent: $b).
	self assert: 'function(a,b)
{
}' equals: module sourceString
]

{ #category : #'tests - cursor position' }
SBTSBlockTest >> testTypingArray [

	| module editor |
	module := SBTSFileParser new parse: '' language: SBJavascript instance.
	editor := self editorAndWorldFor: module.
	module startInsertAtEnd.
	editor handle: (SBTest keyboardEvent: $[).
	self tick.
	self tick.
	editor handle: (SBTest keyboardEvent: Character cr).
	
	self
		assert: 'array'
		equals: module childSandblocks first type.
	self
		assert: module childSandblocks last
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
	module childSandblocks first startInsertAtEnd.
	editor handle: (SBTest keyboardEvent: $().
	self tick.
	self tick.
	editor handle: (SBTest keyboardEvent: Character arrowDown).
	editor handle: (SBTest keyboardEvent: Character cr).
	
	self assert: 'arrow_function' equals: module childSandblocks first childSandblocks first type.
	self assert: 'pattern' equals: editor cursor cursorPosition command element alternatives first type.
	self assert: #insert equals: editor cursor mode
]
