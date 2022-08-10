Class {
	#name : #SBTSBlockTest,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #failures }
SBTSBlockTest >> expectedFailures [

	^ #(#testJoinNumberFromBinaryOp #testJsDeleteFunction #testJsDeleteStatementsWithEmpty)
]

{ #category : #'tests - adding' }
SBTSBlockTest >> testAddAdaptsSlotPythonStmt [

	| source target |
	source := (SBTSFileParser new parse: '2 + 3' language: SBPython) lastDeepChild.
	target := SBTSFileParser new parse: '4' language: SBPython.
	target addBlock: source.
	self
		assert: target childSandblocks first slot firstNode
		equals: target childSandblocks second slot firstNode.
	self
		assert: target childSandblocks first slot lastNode
		equals: target childSandblocks second slot lastNode
]

{ #category : #'tests - adding' }
SBTSBlockTest >> testAddAdaptsSlotSmalltalkStmt [

	| source target |
	source := (SBTSFileParser new parse: 'a 2 + 3' language: SBTSSmalltalk) lastDeepChild.
	target := SBTSFileParser new parse: 'a 4' language: SBTSSmalltalk.
	target addBlock: source.
	self
		assert: target childSandblocks second slot firstNode
		equals: target childSandblocks third slot firstNode.
	self
		assert: target childSandblocks second slot lastNode
		equals: target childSandblocks third slot lastNode
]

{ #category : #'tests - associativity' }
SBTSBlockTest >> testAdditionWithMember [

	| program editor |
	program := SBJavascript parseToplevel: 'a+b.c'.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtEnd.
	self type: '+x' in: editor.
	self assert: 'a+b.c+x;' equals: program sourceStringForCompare
]

{ #category : #'tests - associativity' }
SBTSBlockTest >> testAppendMultiplication [

	| program editor |
	program := SBJavascript parseToplevel: '1+2+3'.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtEnd.
	self type: '*4' in: editor.
	self assert: '1+2+3*4;' equals: program sourceStringForCompare
]

{ #category : #'tests - replacements' }
SBTSBlockTest >> testApplyPyFilePathReplacement [

	| parsed |
	parsed := SBTSFileParser new
		parse: 'with open(''data.csv'', newline='''') as csvfile:
	spamreader = csv.reader(csvfile, delimiter='' '', quotechar=''|'')
	for row in spamreader:
		print('', ''.join(row))'
		language: SBPython.
	parsed applyReplacements.
	self assert: (parsed childSandblocks first childSandblocks first childSandblocks first childSandblocks first childSandblocks second childSandblocks first isKindOf: SBPyFilePath)
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
SBTSBlockTest >> testBashContinueCommand [

	| program editor |
	program := SBBash parseToplevel: ''.
	editor := self editorAndWorldFor: program.
	program startInsertAtEnd.
	
	self type: 'git commit -am "hello' in: editor.
	self assert: 'git commit -am "hello"' equals: program sourceString
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testBinaryOpOnMemberExpression [

	| module editor |
	module := SBTSFileParser new parse: 'req.query' language: SBJavascript instance.
	editor := self editorAndWorldFor: module.
	module lastDeepChild startInputAtEnd.
	
	self type: '==2' in: editor.
	self assert: 'req.query==2;' equals: module sourceString
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testCTypeCall [

	| unit editor |
	unit := SBC parseToplevel: 'int main() {
}'.
	editor := self editorAndWorldFor: unit.
	unit childSandblocks first startInsertAtEnd.
	
	self type: 'call' in: editor.
	self tick.
	self tick.
	editor handle: (self keyboardEvent: Character arrowDown).
	editor handle: (self keyboardEvent: Character cr).
	self assert: #identifier equals: unit lastDeepChild type.
	self assert: (unit lastDeepChild compatibleWithType: #'_expression').
	
	editor handle: (self keyboardEvent: $().
	
	self assert: 'int main(){call();
}' equals: unit sourceStringForCompare
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testCanTypeOverKeywordSuggestion [

	| module editor |
	module := SBTSFileParser new parse: '' language: SBPython.
	editor := self editorAndWorldFor: module.
	self type: 'ifi' in: editor.
	self tick.
	self tick.
	editor handle: (self keyboardEvent: Character cr).
	self assert: 'identifier' equals: module childSandblocks first type
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testClojureAppendParens [

	| program editor |
	program := SBClojure parseToplevel: '((a))'.
	editor := self editorAndWorldFor: program.
	program childSandblocks first childSandblocks first startInputAtEnd.
	self type: ' (' in: editor.
	self assert: '((a) ())' equals: program sourceStringForCompare
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testClojureSymbol [

	| source editor |
	source := SBTSFileParser new parse: '' language: SBClojure.
	editor := self editorAndWorldFor: source.
	source startInputAtEnd.
	self type: '''abc' in: editor.
	self assert: '''abc' equals: source sourceString
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testClojureWithClosingParen [

	| program editor |
	program := SBClojure empty.
	editor := self editorAndWorldFor: program.
	
	self type: '(dec n)' in: editor.
	
	self assert: '(dec n)' equals: program sourceStringForCompare
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testClojureWrapInExpr [

	| program editor |
	program := SBTSFileParser new parse: '(+ 1 2)' language: SBClojure.
	editor := self editorAndWorldFor: program.
	program childSandblocks first startInputAtStart.
	editor handle: (self keyboardEvent: $().
	self tick.
	self tick.
	editor handle: (self keyboardEvent: Character cr).
	editor handle: (self keyboardEvent: Character arrowRight).
	editor handle: (self keyboardEvent: $*).
	self assert: '(* (+ 1 2))' equals: program sourceString
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
	8 timesRepeat: [editor handle: (self keyboardEvent: Character backspace)].
	self assert: '' equals: module sourceString
]

{ #category : #'tests - deleting' }
SBTSBlockTest >> testDeleteJsString [

	| program editor |
	program := SBJavascript parseToplevel: '"a"'.
	editor := self editorFor: program.
	program childSandblocks first startInputAtEnd.
	8 timesRepeat: [editor handle: (self keyboardEvent: Character backspace)].
	self assert: program childSandblocks isEmpty
]

{ #category : #'tests - deleting' }
SBTSBlockTest >> testDeletePrefix [

	| program editor |
	program := SBJavascript parseToplevel: '2 + 3'.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtStart.
	
	5 timesRepeat: [editor handle: (self keyboardEvent: Character backspace)].
	
	self assert: '3;' equals: program sourceStringForCompare
]

{ #category : #'tests - deleting' }
SBTSBlockTest >> testDeleteStBinaryOpStatement [

	| method editor |
	method := SBTSFileParser new parse: 'method a + 9' language: SBTSSmalltalk.
	editor := self editorFor: method.
	method lastDeepChild startInputAtEnd.
	editor handle: (self keyboardEvent: Character backspace).
	editor handle: (self keyboardEvent: Character backspace).
	self assert: 'method
a+' equals: method sourceString.
	editor handle: (self keyboardEvent: Character backspace).
	editor handle: (self keyboardEvent: Character backspace).
	self assert: 'method
a' equals: method sourceString.
	editor handle: (self keyboardEvent: Character backspace).
	editor handle: (self keyboardEvent: Character backspace).
	self assert: 'method' equals: method sourceStringForCompare.
	self assert: 1 equals: method childSandblocks size
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testForwardToAdjacentStatement [

	| module editor |
	module := SBTSFileParser new parse: '2;
() => 3' language: SBJavascript.
	editor := self editorFor: module.
	module lastDeepChild changeToUnknown.
	module childSandblocks first startInputAtEnd.
	editor handle: (self keyboardEvent: $,).
	"no change expected, but we had some issues with input forwarding causing infinite loop"
	self assert: '2;
()=>;' equals: module sourceString
]

{ #category : #'tests - associativity' }
SBTSBlockTest >> testInsertAddition [

	| program editor |
	program := SBJavascript parseToplevel: '1+3+4'.
	editor := self editorAndWorldFor: program.
	program firstDeepChild startInputAtEnd.
	self type: '+2' in: editor.
	self assert: '1+2+3+4;' equals: program sourceStringForCompare
]

{ #category : #'tests - deleting' }
SBTSBlockTest >> testJoinNumberFromBinaryOp [

	| program editor |
	program := SBJavascript parseToplevel: '2+3'.
	editor := self editorAndWorldFor: program.
	program childSandblocks first startInputAtEnd.
	
	2 timesRepeat: [editor handle: (self keyboardEvent: Character backspace)].
	self assert: '23;' equals: program sourceStringForCompare
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsAddAssignmentToStatement [

	| program editor |
	program := SBJavascript parseToplevel: '123'.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtStart.
	self type: (self keyboardEvent: Character space shift: true command: false) in: editor.
	self type: 'x=' in: editor.
	self tick.
	self tick.
	editor handle: (self keyboardEvent: Character cr).
	self assert: 'x=123;' equals: program sourceStringForCompare
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

{ #category : #'tests - associativity' }
SBTSBlockTest >> testJsBinaryInUnary [

	| program editor |
	program := SBJavascript parseToplevel: 'typeof x'.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtEnd.
	self type: '+x' in: editor.
	self assert: 'typeof x+x;' equals: program sourceStringForCompare
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsCall [

	| module editor |
	module := SBTSFileParser new parse: 'a.b' language: SBJavascript instance.
	editor := self editorAndWorldFor: module.
	
	editor selectNoInput: module childSandblocks first.
	editor handle: (self keyboardEvent: $ ).
	editor handle: (self keyboardEvent: $().
	self assert: #'call_expression' equals: module childSandblocks first type.
	self assert: #'call_expression' equals: editor cursor cursorPosition block type.
	self assert: editor cursor cursorPosition isInsert
]

{ #category : #'tests - modify' }
SBTSBlockTest >> testJsCallToSubscript [

	| module editor |
	module := SBTSFileParser new parse: 'abc(12)' language: SBJavascript.
	editor := self editorFor: module.
	module childSandblocks first startInputAtStart.
	editor handle: (self keyboardEvent: Character delete).
	editor handle: (self keyboardEvent: $[).
	self assert: 'subscript_expression' equals: module childSandblocks first type
]

{ #category : #'tests - deleting' }
SBTSBlockTest >> testJsChangePlusToDivide [

	| module editor |
	module := SBTSFileParser new parse: '2+3' language: SBJavascript.
	editor := self editorAndWorldFor: module.
	module lastDeepChild startInputAtEnd.
	editor handle: (self keyboardEvent: Character backspace).
	editor handle: (self keyboardEvent: Character backspace).
	self assert: '2+;' equals: module sourceString.
	editor handle: (self keyboardEvent: Character backspace).
	self assert: '2;' equals: module sourceString.
	editor handle: (self keyboardEvent: $/).
	self assert: '2/', Character null, ';' equals: module sourceStringForCompare.
	editor handle: (self keyboardEvent: $4).
	self assert: '2/4;' equals: module sourceStringForCompare
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

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsCompleteMemberNested [

	| module editor |
	module := SBTSFileParser new parse: '' language: SBJavascript.
	editor := self editorAndWorldFor: module.
	module startInsertAtEnd.
	self type: '123' in: editor.
	editor handle: (self keyboardEvent: Character arrowUp shift: true command: false).
	self type: ' .xy' in: editor.
	self assert: '123.xy;' equals: module sourceStringForCompare
]

{ #category : #'tests - deleting' }
SBTSBlockTest >> testJsDeleteDeclaration [

	| module editor |
	module := SBTSFileParser new parse: 'const a = 5' language: SBJavascript.
	editor := self editorFor: module.
	module lastDeepChild startInputAtEnd.
	
	editor handle: (self keyboardEvent: Character backspace).
	self assert: 'const a=', Character null, ';' equals: module sourceStringForCompare.
	editor handle: (self keyboardEvent: Character backspace).
	self assert: 'const a;' equals: module sourceStringForCompare.
	editor handle: (self keyboardEvent: Character backspace).
	editor handle: (self keyboardEvent: Character backspace).
	self assert: 'const', Character null, ';' equals: module sourceStringForCompare.
	8 timesRepeat: [editor handle: (self keyboardEvent: Character backspace)].
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
};' equals: module sourceStringForCompare.
	self assert: module childSandblocks first childSandblocks second equals: editor selection.
	'function' size + 3 timesRepeat: [editor handle: (self keyboardEvent: Character backspace)].
	self assert: '1+;' equals: module sourceString
]

{ #category : #'tests - deleting' }
SBTSBlockTest >> testJsDeleteImport [

	| module editor import |
	module := SBJavascript parseToplevel: 'import {a} from ''C'''.
	editor := self editorAndWorldFor: module.
	import := module queryNode: '(identifier)'.
	import deleteBlock
]

{ #category : #'tests - deleting' }
SBTSBlockTest >> testJsDeleteMethodCall [

	| program editor |
	program := SBJavascript parseToplevel: 'log()'.
	editor := self editorAndWorldFor: program.
	program childSandblocks first startInsertAtEnd.
	3 timesRepeat: [editor handle: (self keyboardEvent: Character backspace)].
	self assert: 'log;' equals: program sourceStringForCompare
]

{ #category : #'tests - deleting' }
SBTSBlockTest >> testJsDeleteStatements [

	| program editor |
	program := SBJavascript parseToplevel: 'console.log;
a;'.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtEnd.
	9 timesRepeat: [editor handle: (self keyboardEvent: Character backspace)].
	self assert: 'console;' equals: program sourceStringForCompare
]

{ #category : #'tests - deleting' }
SBTSBlockTest >> testJsDeleteStatementsWithEmpty [

	| program editor |
	program := SBJavascript parseToplevel: 'console.log;

a;'.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtEnd.
	2 timesRepeat: [editor handle: (self keyboardEvent: Character backspace)].
	self assert: 'console.log;
' equals: program sourceStringForCompare.
	2 timesRepeat: [editor handle: (self keyboardEvent: Character backspace)].
	self assert: 'console.log;' equals: program sourceStringForCompare
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsEndWithSemicolon [

	| program editor |
	program := SBJavascript empty.
	editor := self editorAndWorldFor: program.
	self type: 'a;' in: editor.
	self assert: 'a;' equals: program sourceStringForCompare
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsExpandObject [

	| module editor |
	module := SBTSFileParser new parse: 'const a = {id}' language: SBJavascript instance.
	editor := self editorAndWorldFor: module.
	module lastDeepChild startInputAtEnd.
	self type: ':x' in: editor.
	self assert: 'const a={id:x};' equals: module sourceString
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsForOf [

	| program editor |
	program := SBJavascript parseToplevel: ''.
	editor := self editorAndWorldFor: program.
	self type: 'for ' in: editor.
	self tick.
	self tick.
	editor handle: (self keyboardEvent: Character arrowDown).
	editor handle: (self keyboardEvent: Character cr).
	self
		assert: 'for(', Character null, Character null, Character null, (')', Character null)
		equals: program sourceStringForCompare.
	
	self type: 'const a' in: editor.
	self
		assert: 'for(const a', Character null, Character null, (')', Character null)
		equals: program sourceStringForCompare
]

{ #category : #'tests - modify' }
SBTSBlockTest >> testJsForOfToForIn [

	| program editor |
	program := SBJavascript parseToplevel: 'for (const a of [1]) {}'.
	editor := self editorFor: program.
	program childSandblocks first startInputAtStart.
	editor performForSelection: #clearInput.
	self assert: Character null asString, '(const a of[1])
{
}' equals: program sourceStringForCompare.
	
	editor performForSelection: #moveCursorLarger.
	editor performForSelection: #clearInput.
	self assert: Character null asString equals: program sourceStringForCompare
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsIdAdd [

	| program editor |
	program := SBTSFileParser new parse: 'a' language: SBJavascript.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtEnd.
	self type: '+b' in: editor.
	self assert: 'a+b;' equals: program sourceString
]

{ #category : #'tests - modify' }
SBTSBlockTest >> testJsIdentifierToAssignment [

	| program editor |
	program := SBJavascript parseToplevel: 'conts'.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtEnd.
	self assert: #identifier equals: program childSandblocks first type.
	
	editor handle: (self keyboardEvent: Character backspace).
	editor handle: (self keyboardEvent: Character backspace).
	editor handle: (self keyboardEvent: $s).
	editor handle: (self keyboardEvent: $t).
	self
		tick;
		tick.
	editor handle: (self keyboardEvent: Character arrowDown).
	editor handle: (self keyboardEvent: Character cr).
	self assert: #'lexical_declaration' equals: program childSandblocks first type
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsMethodCall [

	| module editor |
	module := SBTSFileParser new parse: '' language: SBJavascript instance.
	editor := self editorAndWorldFor: module.
	module startInputAtEnd.
	editor handle: (self keyboardEvent: Character arrowRight).
	
	self type: 'console.log("Hello' in: editor.
	self assert: 'console.log("Hello");' equals: module sourceString
]

{ #category : #'tests - modify' }
SBTSBlockTest >> testJsMethodChain [

	| program editor |
	program := SBJavascript empty.
	editor := self editorAndWorldFor: program.
	self type: 'a.b().c()' in: editor.
	self assert: 'a.b().c();' equals: program sourceStringForCompare
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
	self assert: 'res.send().status(x);' equals: module sourceString
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsNumberToString [

	| module editor |
	module := SBTSFileParser new parse: '123' language: SBJavascript instance.
	editor := self editorAndWorldFor: module.
	module lastDeepChild startInputAtStart.
	self type: '''' in: editor.
	self tick.
	self tick.
	editor handle: (self keyboardEvent: Character cr).
	self assert: '''123'';' equals: module sourceString
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsObjectInCall [

	| program editor |
	program := SBJavascript parseToplevel: 'a()'.
	editor := self editorAndWorldFor: program.
	
	program childSandblocks first startInsertAtEnd.
	self type: '{})' in: editor.
	self assert: 'a({});' equals: program sourceStringForCompare.
	self assert: ')' equals: editor cursor cursorPosition textMorph contents
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsObjectWithMultipleFieldsInCall [

	| program editor |
	program := SBJavascript parseToplevel: 'a()'.
	editor := self editorAndWorldFor: program.
	
	program childSandblocks first startInsertAtEnd.
	self type: '{a,b})' in: editor.
	self assert: 'a({a,b});' equals: program sourceStringForCompare.
	self assert: ')' equals: editor cursor cursorPosition textMorph contents
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsPatternToAssignmentPattern [

	| module editor |
	module := SBTSFileParser new parse: 'function(b) {}' language: SBJavascript instance.
	editor := self editorAndWorldFor: module.
	module childSandblocks first childSandblocks first startInputAtEnd.
	editor handle: (self keyboardEvent: $=).
	editor handle: (self keyboardEvent: $x).
	self tick.
	self tick.
	editor handle: (self keyboardEvent: Character cr).
	
	self assert: 'assignment_pattern' equals: module childSandblocks first childSandblocks first type.
	self assert: 'b=x' equals: module childSandblocks first childSandblocks first sourceString
]

{ #category : #'tests - modify' }
SBTSBlockTest >> testJsReinterpretIncompleteLabel [

	| module editor |
	module := SBTSFileParser new parse: 'abc()' language: SBJavascript.
	editor := self editorFor: module.
	module childSandblocks first startInsertAtEnd.
	self type: '..ab' in: editor.
	self assert: 'spread_element' equals: module childSandblocks first childSandblocks second type.
	self
		assert: 'identifier'
		equals: module childSandblocks first childSandblocks second childSandblocks first type
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsReturn [

	| program editor |
	program := SBJavascript parseToplevel: ''.
	editor := self editorAndWorldFor: program.
	
	program startInsertAtStart.
	editor performForSelection: #moveCursorRight.
	self type: 'return ' in: editor.
	self type: '2' in: editor.
	self assert: 'return 2;' equals: program sourceStringForCompare
]

{ #category : #'tests - cursor position' }
SBTSBlockTest >> testJsReturnInString [

	| program editor |
	program := SBJavascript parseToplevel: '"abc"'.
	editor := self editorFor: program.
	program lastDeepChild startInputAtStart.
	editor handle: (self keyboardEvent: Character cr).
	self assert: 2 equals: program childSandblocks size
]

{ #category : #'tests - cursor position' }
SBTSBlockTest >> testJsReturnMultilineInString [

	| program editor |
	program := SBJavascript parseToplevel: '"abc"'.
	editor := self editorFor: program.
	program lastDeepChild startInputAtStart.
	editor handle: (self keyboardEvent: Character cr shift: false command: true).
	self assert: '"
abc";' equals: program sourceStringForCompare.
	self assert: 1 equals: program childSandblocks size.
	editor handle: (self keyboardEvent: Character cr).
	self assert: '"

abc";' equals: program sourceStringForCompare
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsSeparatorInPendingArg [

	| program editor |
	program := SBJavascript parseToplevel: 'abc()'.
	editor := self editorAndWorldFor: program.
	program childSandblocks first startInsertAtEnd.
	self type: 'a' in: editor.
	self type: ',' in: editor.
	self assert: 'abc(a);' equals: program sourceStringForCompare
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsSeparatorInPendingPattern [

	| program editor |
	program := SBJavascript parseToplevel: 'function abc() {}'.
	editor := self editorAndWorldFor: program.
	(program queryNode: '(identifier)') startInputAtEnd.
	3 timesRepeat: [editor handle: (self keyboardEvent: Character arrowRight)].
	self type: 'a' in: editor.
	self type: ',' in: editor.
	self type: 'b' in: editor.
	self assert: 'function abc(a,b)
{
}' equals: program sourceStringForCompare
]

{ #category : #'tests - modify' }
SBTSBlockTest >> testJsSplitBinary [

	| program editor |
	program := SBTSFileParser new parse: '1123' language: SBJavascript.
	editor := self editorAndWorldFor: program.
	program childSandblocks first startInputAtStart.
	editor handle: (self keyboardEvent: Character arrowRight).
	editor handle: (self keyboardEvent: $+).
	self assert: '1+123;' equals: program sourceStringForCompare
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsStatementTerminator [

	| program editor |
	program := SBJavascript empty.
	editor := self editorAndWorldFor: program.
	program startInsertAtEnd.
	self type: 'x;' in: editor.
	self assert: 'x;' equals: program sourceStringForCompare
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsStringWithSpace [

	| program editor |
	program := SBJavascript empty.
	editor := self editorAndWorldFor: program.
	program startInsertAtEnd.
	
	self type: ''' ''' in: editor.
	self assert: ''' '';' equals: program sourceStringForCompare
]

{ #category : #'tests - cursor position' }
SBTSBlockTest >> testJsTabToEmptyStatement [

	| program editor |
	program := SBJavascript parseToplevel: 'a;
class {
}'.
	editor := self editorFor: program.
	program childSandblocks first startInputAtStart.
	editor handle: (self keyboardEvent: Character tab).
	self assert: #insert equals: editor cursor mode.
	editor handle: (self keyboardEvent: $x).
	self assert: 'a;
class
{
x
};' equals: program sourceStringForCompare.
	editor handle: (self keyboardEvent: $().
	self assert: 'a;
class
{
x()
{
}
};' equals: program sourceStringForCompare
]

{ #category : #'tests - modify' }
SBTSBlockTest >> testJsTripleEqualToDouble [

	| program editor |
	program := SBJavascript parseToplevel: 'a === 3'.
	editor := self editorAndWorldFor: program.
	program childSandblocks first startInputAtEnd.
	editor handle: (self keyboardEvent: Character backspace).
	self assert: 'a==3;' equals: program sourceStringForCompare.
	self assert: program childSandblocks first valid.
	
	editor handle: (self keyboardEvent: Character backspace).
	self assert: 'a=3;' equals: program sourceStringForCompare.
	self assert: program childSandblocks first valid
]

{ #category : #'tests - cursor position' }
SBTSBlockTest >> testJsTypeAmbiguousIdentifierAndSpace [

	| program editor |
	program := SBJavascript parseToplevel: ''.
	editor := self editorAndWorldFor: program.
	
	program startInsertAtEnd.
	
	editor handle: (self keyboardEvent: $a).
	editor handle: (self keyboardEvent: Character space).
	
	self assert: 'a;' equals: program sourceStringForCompare.
	self assert: #identifier equals: editor selection type
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsTypeAssignment [

	| module editor |
	module := SBTSFileParser new parse: '' language: SBJavascript.
	editor := self editorAndWorldFor: module.
	
	module startInputAtEnd.
	editor handle: (self keyboardEvent: Character arrowRight).
	self type: 'const a=5' in: editor.
	self assert: 'const a=5;' equals: module childSandblocks first sourceString
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsTypeIfWithoutSpace [

	| program editor |
	program := SBJavascript empty.
	editor := self editorAndWorldFor: program.
	program startInsertAtEnd.
	self type: 'if(' in: editor.
	self assert: #'if_statement' equals: program childSandblocks first type
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsTypeImport [

	| module editor import |
	module := SBJavascript parseToplevel: 'import {} from ''C'''.
	editor := self editorAndWorldFor: module.
	import := module queryNode: '(named_imports)'.
	import startInsertAtEnd.
	self type: 'a' in: editor.
	self assert: 6 equals: import recursiveSubmorphCount
]

{ #category : #'tests - modify' }
SBTSBlockTest >> testJsTypeMissingFor [

	| program editor |
	program := SBJavascript parseToplevel: 'for (const a of [1]) {}'.
	editor := self editorFor: program.
	program childSandblocks first startInputAtStart.
	editor performForSelection: #clearInput.
	self assert: Character null asString, '(const a of[1])
{
}' equals: program sourceStringForCompare.
	
	self type: 'for' in: editor.
	
	self assert: 'for(const a of[1])
{
}' equals: program sourceStringForCompare
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testJsTypeObject [

	| module editor |
	module := SBTSFileParser new parse: 'const a = {}' language: SBJavascript instance.
	editor := self editorAndWorldFor: module.
	module lastDeepChild startInsertAtEnd.
	self type: 'id:x' in: editor.
	self assert: 'const a={id:x};' equals: module sourceString
]

{ #category : #'tests - associativity' }
SBTSBlockTest >> testMemberInAssign [

	| program editor |
	program := SBJavascript empty.
	editor := self editorAndWorldFor: program.
	self type: 'x=x.x' in: editor.
	self assert: 'x=x.x;' equals: program sourceStringForCompare
]

{ #category : #'tests - associativity' }
SBTSBlockTest >> testMemberInObject [

	| program editor |
	program := SBJavascript empty.
	editor := self editorAndWorldFor: program.
	program startInputAtEnd.
	self type: '{a:b.x}' in: editor.
	self tick.
	self tick.
	editor handle: (self keyboardEvent: Character arrowDown).
	editor handle: (self keyboardEvent: Character cr).
	self assert: '{a:b.x};' equals: program sourceStringForCompare
]

{ #category : #'tests - associativity' }
SBTSBlockTest >> testNestMultiplication [

	| results |
	results := SBTSInputParser new
		optionsForTemplate: (SBTSNodeSymbol new type: #expression factory: SBJavascript instance grammar)
		given: '2+3*4'.
	self assert: results size = 1.
	self assert: '2+3*4' equals: results anyOne first sourceStringForCompare
]

{ #category : #'tests - associativity' }
SBTSBlockTest >> testNestedMemberInAssign [

	| program editor |
	program := SBJavascript parseToplevel: 'x=x.x'.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtEnd.
	self type: '.x' in: editor.
	self assert: 'x=x.x.x;' equals: program sourceStringForCompare
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

{ #category : #'tests - associativity' }
SBTSBlockTest >> testOrInAssign [

	| program editor |
	program := SBJavascript empty.
	editor := self editorAndWorldFor: program.
	self type: 'x=x||x' in: editor.
	self assert: 'x=x||x;' equals: program sourceStringForCompare
]

{ #category : #'tests - paste' }
SBTSBlockTest >> testPasteListIntoLiteral [

	| source editor |
	source := SBTSFileParser new parse: '5
(a)' language: SBClojure.
	editor := self editorFor: source.
	editor copyBuffer: source childSandblocks first.
	
	source childSandblocks second
		select;
		pasteReplace.
	
	self assert: '5
5' equals: source sourceString
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testPyAddKeywordToArg [

	| program editor |
	program := SBPython parseToplevel: 'myFunc(123)'.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtStart.
	self type: (self keyboardEvent: Character space shift: true command: false) in: editor.
	self type: 'arg=' in: editor.
	self tick.
	self tick.
	editor handle: (self keyboardEvent: Character cr).
	self assert: 'myFunc(arg=123)' equals: program sourceStringForCompare
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
	self type: 'if ' in: editor.
	self tick.
	self tick.
	editor handle: (self keyboardEvent: Character cr).
	self assert: 'if_statement' equals: program childSandblocks first type
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testPythonString [

	| program editor |
	program := SBPython empty.
	editor := self editorAndWorldFor: program.
	
	self type: '''a''' in: editor.
	self assert: '''a''' equals: program sourceStringForCompare
]

{ #category : #'tests - query' }
SBTSBlockTest >> testQueryBlockInlined [

	| regex |
	regex := SBTSFileParser new parse: '(?<test>123)' language: SBRegex.
	self assert: (regex queryRecursiveFirstMatch: '(named_capturing_group
	(group_name) @name
)' capturesDo: [:c | ])
]

{ #category : #'tests - deleting' }
SBTSBlockTest >> testRegexDeleteCountQuantifier [

	| term editor |
	term := SBTSFileParser new parse: '[0]{0}' language: SBRegex.
	editor := self editorFor: term.
	term lastDeepChild parentSandblock select deleteBlock.
	self assert: '[0]' equals: term sourceString
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testRegexEnterClassRanges [

	| term editor |
	term := SBTSFileParser new parse: 'a' language: SBRegex.
	editor := self editorFor: term.
	term startInsertAtEnd.
	self type: '[A-Za-z' in: editor.
	self assert: 'a[A-Za-z]' equals: term sourceString
]

{ #category : #'tests - replacements' }
SBTSBlockTest >> testReplacementBlockBinding [

	| regex source wrapped editor |
	source := '(?<test>1)'.
	regex := SBTSFileParser new parse: source language: SBRegex.
	editor := self editorAndWorldFor: regex.
	regex applyReplacements.
	wrapped := regex childSandblocks first childSandblocks first childSandblocks first.
	
	self assert: '1' equals: wrapped sourceString.
	self assert: source equals: regex sourceString.
	
	wrapped startInputAtEnd.
	self type: '2' in: editor.
	self assert: '12' equals: wrapped sourceString.
	self assert: '(?<test>12)' equals: regex sourceString
]

{ #category : #'tests - replacements' }
SBTSBlockTest >> testReplacementUndo [

	| regex source editor |
	source := '(?<test>1)'.
	regex := SBTSFileParser new parse: source language: SBRegex.
	editor := self editorFor: regex.
	regex applyReplacements.
	editor undo.
	self assert: source equals: regex sourceString.
	editor redo.
	self assert: source equals: regex sourceString
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
	
	method childSandblocks second startInsertAtEnd.
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

{ #category : #'tests - input transition' }
SBTSBlockTest >> testSmalltalkKeywordToUnary [

	| method editor |
	method := SBTSFileParser new
		parse: 'abc a keyword: 4'
		language: SBTSSmalltalk instance.
	editor := self editorAndWorldFor: method.
	
	method lastDeepChild startInputAtEnd.
	editor handle: (self keyboardEvent: Character backspace).
	editor handle: (self keyboardEvent: Character backspace).
	editor handle: (self keyboardEvent: Character backspace).
	self assert: #'unary_message' equals: method childSandblocks second type
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

{ #category : #'tests - modify' }
SBTSBlockTest >> testStBinaryToAssignment [

	| module editor |
	module := SBTSFileParser new parse: 'a b + c' language: SBTSSmalltalk.
	editor := self editorFor: module.
	module childSandblocks second childSandblocks second startInputAtEnd.
	editor handle: (self keyboardEvent: $a shift: false command: true).
	editor handle: (self keyboardEvent: $:).
	self assert: 'assignment' equals: module childSandblocks second type
]

{ #category : #'tests - modify' }
SBTSBlockTest >> testStCreateKeyword [

	| method editor |
	method := SBTSSmalltalk parseToplevel: 'a ni'.
	editor := self editorAndWorldFor: method.
	method lastDeepChild startInputAtEnd.
	
	editor handle: (self keyboardEvent: $l).
	self tick.
	self tick.
	editor handle: (self keyboardEvent: Character cr).
	
	self assert: 'a
nil' equals: method sourceStringForCompare
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
SBTSBlockTest >> testStKeywordAutocompletion [

	| method editor |
	method := SBTSFileParser new parse: 'a id' language: SBTSSmalltalk.
	editor := self editorAndWorldFor: method.
	method lastDeepChild startInputAtEnd.
	self type: ' cucucu' in: editor.
	self tick.
	self tick.
	editor handle: (self keyboardEvent: Character cr).
	self assert: #'keyword_message' equals: method childSandblocks second type.
	self
		assert: 'cull:cull:cull:'
		equals: (((method childSandblocks second submorphs select: [:m | m type = #keyword]) collect: #contents) joinSeparatedBy: '').
	self assert: editor selection equals: (method allBlocksDetect: #isUnknown)
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

{ #category : #'tests - associativity' }
SBTSBlockTest >> testTypeAddition [

	| program editor |
	program := SBJavascript empty.
	editor := self editorAndWorldFor: program.
	program startInsertAtEnd.
	self type: '1+2+3+4' in: editor.
	self assert: '1+2+3+4;' equals: program sourceStringForCompare
]

{ #category : #'tests - input transition' }
SBTSBlockTest >> testTypeCallAndStringWithClosingSymbols [

	| program editor source |
	program := SBJavascript empty.
	editor := self editorAndWorldFor: program.
	
	source := 'test("abc")'.
	program startInsertAtEnd.
	self type: source in: editor.
	self assert: source, ';' equals: program sourceStringForCompare
]

{ #category : #'tests - cursor position' }
SBTSBlockTest >> testTypeJsClass [

	| program editor |
	program := SBJavascript parseToplevel: ''.
	editor := self editorAndWorldFor: program.
	
	program startInsertAtEnd.
	self type: 'class ' in: editor.
	self tick.
	self tick.
	editor handle: (self keyboardEvent: Character cr).
	self assert: 'class' equals: program childSandblocks first type.
	
	self type: 'Name' in: editor.
	self assert: 'class Name
{
};' equals: program sourceString
]

{ #category : #'tests - associativity' }
SBTSBlockTest >> testTypeMember [

	| program editor |
	program := SBJavascript parseToplevel: 'a+b'.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtEnd.
	
	self type: '.' in: editor.
	self assert: 'a+b.', Character null, ';' equals: program sourceStringForCompare
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
};' equals: module sourceString
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
	editor handle: (SBTest keyboardEvent: $x).
	self tick.
	self tick.
	editor handle: (SBTest keyboardEvent: Character arrowDown).
	editor handle: (SBTest keyboardEvent: Character cr).
	
	self assert: 'arrow_function' equals: module childSandblocks first childSandblocks first type.
	self assert: 'x' equals: editor cursor cursorPosition block contents.
	self assert: #input equals: editor cursor mode
]

{ #category : #'tests - cursor position' }
SBTSBlockTest >> testVerticalPositions [

	| program editor queue lastPos |
	program := SBTSFileParser new
		parse: 'x
function(arg)
{
	first
	second
	third
}
last'
		language: SBJavascript.
	editor := self editorFor: program.
	
	program lastDeepChild select.
	queue := {
		program queryNode: '(identifier) ="x"'.
		program queryNode: '(function)'.
		program queryNode: '(identifier) ="first"'.
		program queryNode: '(identifier) ="second"'.
		program queryNode: '(identifier) ="third"'.
		program queryNode: '(identifier) ="last"'} reversed readStream.
	lastPos := nil.
	[queue atEnd] whileFalse: [
		queue peek = editor selection ifTrue: [queue next].
		editor cursor moveCursorUp.
		lastPos = editor cursor cursorPosition ifTrue: [self error: 'reached top without visiting all block'].
		lastPos := editor cursor cursorPosition]
]
