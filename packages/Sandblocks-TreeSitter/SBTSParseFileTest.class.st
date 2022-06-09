Class {
	#name : #SBTSParseFileTest,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Parser'
}

{ #category : #failures }
SBTSParseFileTest >> expectedFailures [

	^ #()
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testAdaptRegexNodes [

	| a b |
	a := SBTSFileParser new parse: 'ab' language: SBRegex.
	b := SBTSFileParser new parse: 'x' language: SBRegex.
	
	self
		assert: a childSandblocks first childSandblocks first slot firstNode
		equals: a childSandblocks first childSandblocks second slot firstNode.
	self
		assert: a childSandblocks first childSandblocks first slot firstNode
		equals: b childSandblocks first childSandblocks first slot firstNode
]

{ #category : #'tests - unit' }
SBTSParseFileTest >> testChoice [

	| factory parser rule |
	factory := SBTSTestLanguage new.
	rule := SBTSNodeSeq new elements: {
		SBTSNodeChoice new alternatives: {SBTSNodeSymbol new type: 'id' factory: factory. SBTSNodeSymbol new type: 'other' factory: factory}.
		SBTSNodeSymbol new type: 'id' factory: factory}.
	parser := (rule takeNodesFrom: (SBTSFileParser new stream: {SBTSNodeSymbol new type: 'other' factory: factory. SBTSNodeSymbol new type: 'id' factory: factory} readStream)) first.
	self assert: rule elements first alternatives second equals: parser slots first lastNode.
	self assert: rule elements second equals: parser slots second lastNode
]

{ #category : #'tests - print' }
SBTSParseFileTest >> testClojureSpaces [

	| source |
	source := '(+ 3 test =)'.
	self assert: source equals: (SBTSFileParser new parse: source language: SBClojure) sourceString
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testJavascriptImport [

	| block source |
	source := 'import{A}from''a'';'.
	block := SBTSFileParser new parse: source language: SBJavascript instance.
	self assert: source equals: block sourceString.
	source := 'import{A as B}from''a'';'.
	block := SBTSFileParser new parse: source language: SBJavascript instance.
	self assert: source equals: block sourceString
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testJavascriptString [

	| sourceString parsed |
	sourceString := '"a";'.
	parsed := SBTSFileParser new parse: sourceString language: SBJavascript instance.
	self assert: sourceString equals: parsed sourceString
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testJavascriptTemplateString [

	| source |
	source := '`ab`;'.
	self
		assert: source
		equals: (SBTSFileParser new parse: source language: SBJavascript instance) sourceString.
	source := '`ab${a}`;'.
	self
		assert: source
		equals: (SBTSFileParser new parse: source language: SBJavascript instance) sourceString.
	source := '`ab${a}def${c}`;'.
	self
		assert: source
		equals: (SBTSFileParser new parse: source language: SBJavascript instance) sourceString
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testJsFunctionPatterns [

	| module editor |
	module := SBTSFileParser new parse: 'function(b) {}' language: SBJavascript instance.
	editor := self editorFor: module.
	self assert: #(#identifier #pattern) equals: (module childSandblocks first childSandblocks first slot nodes
		collect: #type
		as: Array).
	self assert: #('"("' #formal_parameters) equals: (module childSandblocks first submorphs second slot nodes
		collect: #type
		as: Array).
	
	module childSandblocks first childSandblocks first startInputAtEnd.
	editor handle: (self keyboardEvent: Character arrowRight).
	editor handle: (self keyboardEvent: $x).
	self assert: #(#identifier #pattern) equals: (module childSandblocks first childSandblocks second slot nodes
		collect: #type
		as: Array)
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testJsObjectFieldNames [

	| module |
	module := SBTSFileParser new parse: '{id: 123}' language: SBJavascript.
	self
		assert: #('key' 'value')
		equals: (module childSandblocks first childSandblocks first childSandblocks collect: #field)
]

{ #category : #'tests - print' }
SBTSParseFileTest >> testJsParameters [

	| source |
	source := 'function a(b,c)
{
}'.
	self
		assert: source
		equals: (SBTSFileParser new parse: source language: SBJavascript instance) sourceString
]

{ #category : #'tests - unit' }
SBTSParseFileTest >> testLabel [

	| factory parser rule |
	factory := SBTSTestLanguage new.
	rule := SBTSNodeSeq new elements: {SBTSNodeLabel new label: 'abc'}.
	parser := (rule takeNodesFrom: (SBTSFileParser new stream: {'abc'} readStream)) first.
	self assert: rule elements first equals: parser slots first lastNode
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testNodesAreShared [

	| a b |
	a := SBTSFileParser new parse: '2' language: SBPython.
	b := SBTSFileParser new parse: '2' language: SBPython.
	
	self assert: a childSandblocks first slot firstNode equals: b childSandblocks first slot firstNode
]

{ #category : #'tests - print parentheses' }
SBTSParseFileTest >> testParensJsBinaryOp [

	| source module |
	source := '(3+4)*5;'.
	module := SBTSFileParser new parse: source language: SBJavascript.
	self editorFor: module.
	
	"remove the explicit parenthesis node"
	(module queryNode: '(parenthesized_expression (expression) @)') deleteAround.
	
	self assert: source equals: module sourceString
]

{ #category : #'tests - print parentheses' }
SBTSParseFileTest >> testParensStBinaryOp [

	| source module |
	source := 'a
2+(3+4)'.
	module := SBTSFileParser new parse: source language: SBTSSmalltalk.
	self editorFor: module.
	(module queryNode: '(parenthesized_expression (expression) @)') deleteAround.
	self assert: source equals: module sourceString
]

{ #category : #'tests - print parentheses' }
SBTSParseFileTest >> testParensStKeyword [

	| source module |
	source := 'a
2 raisedTo:(3 raisedTo:4)'.
	module := SBTSFileParser new parse: source language: SBTSSmalltalk.
	self editorFor: module.
	(module queryNode: '(parenthesized_expression (expression) @)') deleteAround.
	self assert: source equals: module sourceString
]

{ #category : #'tests - unit' }
SBTSParseFileTest >> testParse [

	| factory moduleRule cursor block |
	factory := SBTSTestLanguage new.
	factory
		add: 'module' rule: (moduleRule := SBTSNodeSeq new
			elements: {SBTSNodeSymbol new type: 'id' factory: factory. SBTSNodeSymbol new type: 'id' factory: factory};
			factory: factory);
		add: 'id' rule: (SBTSNodeText new
			regexString: '[a-z]+';
			factory: factory).
	cursor := SBTSTestCursor new
		factory: factory;
		tree: {'module'. ''. true. {{'id'. 'ab'. true}. {'id'. 'cd'. true}}}.
	block := SBTSFileParser new nodeForCursor: cursor.
	
	self assert: block childSandblocks first isTSBlock.
	self assert: moduleRule elements first equals: block childSandblocks first slot lastNode.
	self assert: 'ab' equals: block childSandblocks first contents.
	self assert: moduleRule elements second equals: block childSandblocks second slot lastNode.
	self assert: 'cd' equals: block childSandblocks second contents
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testParseBashCommand [

	| program |
	program := SBTSFileParser new parse: 'ls' language: SBBash.
	self assert: (program childSandblocks first childSandblocks first slot includesParentThat: [:p | p type = 'command_name'])
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testParseBinaryExpression [

	| module |
	module := SBTSFileParser new parse: '2+2' language: SBJavascript instance.
	self assert: 'binary_expression' equals: module childSandblocks first type
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testParseEmptyModule [

	SBTSFileParser new parse: '' language: SBJavascript instance
]

{ #category : #'tests - unit' }
SBTSParseFileTest >> testParseJS [

	| block |
	block := SBTSFileParser new parse: 'a' language: SBJavascript.
	
	self assert: block childSandblocks first isTSBlock.
	self
		assert: (SBJavascript instance grammar bodyNodeForRule: 'program') elements second element
		equals: block childSandblocks first slot lastNode
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testParseJsArrowFunc [

	| module |
	module := SBTSFileParser new parse: '() => 1' language: SBJavascript.
	self assert: 7 equals: (module childSandblocks first performEnum: #cursorPositionsDo:) size
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testParseMemberExpression [
	" this will produce two valid trees choice($.expression, $.primary_expression)) "

	SBTSFileParser new parse: 'a.b' language: SBJavascript instance
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testParsePythonFormatString [

	| source |
	source := '"abc"'.
	self
		assert: source
		equals: (SBTSFileParser new parse: source language: SBPython instance) sourceString.
	source := 'f"abc"'.
	self
		assert: source
		equals: (SBTSFileParser new parse: source language: SBPython instance) sourceString.
	source := 'f"abc{var1}def{var2}ghi"'.
	self
		assert: source
		equals: (SBTSFileParser new parse: source language: SBPython instance) sourceString
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testParseRegexClassCharacter [

	SBTSFileParser new parse: '[-]' language: SBRegex instance.
	SBTSFileParser new parse: '[a]' language: SBRegex instance
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testParseStatement [

	| module |
	module := SBTSFileParser new parse: '2' language: SBJavascript instance.
	self assert: 'number' equals: module childSandblocks first type
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testPythonComprehension [

	| source |
	source := '(0 for i in range)'.
	self
		assert: source
		equals: (SBTSFileParser new parse: source language: SBPython instance) sourceString
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testPythonDecorators [

	| source |
	source := '@staticmethod
@abc
def a():
	pass'.
	self
		assert: source
		equals: (SBTSFileParser new parse: source language: SBPython instance) sourceString
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testPythonFunction [

	| source |
	source := 'def a(b,c):
	pass'.
	self
		assert: source
		equals: (SBTSFileParser new parse: source language: SBPython instance) sourceString
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testPythonIdentifiers [

	| source |
	source := 'global a'.
	self
		assert: source
		equals: (SBTSFileParser new parse: source language: SBPython instance) sourceString
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testPythonIf [

	| source |
	source := 'if a:
	b
elif c:
	d
elif f:
	g
else:
	e'.
	self
		assert: source
		equals: (SBTSFileParser new parse: source language: SBPython instance) sourceString
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testPythonImport [

	| block |
	block := SBTSFileParser new parse: 'import numpy' language: SBPython instance.
	self assert: (block matchesQuery: '(module (import_statement (dotted_name (identifier))))').
	block := SBTSFileParser new parse: 'import numpy as np' language: SBPython instance.
	self assert: (block matchesQuery: '(module (import_statement (aliased_import (dotted_name (identifier)) alias: (identifier))))')
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testPythonList [

	| source |
	source := '[a,b,c]'.
	self
		assert: source
		equals: (SBTSFileParser new parse: source language: SBPython instance) sourceString
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testPythonPrint [

	SBTSFileParser new parse: 'print()' language: SBPython
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testPythonStatements [

	| source module |
	source := 'a
b'.
	module := SBTSFileParser new parse: source language: SBPython instance.
	self assert: source equals: module sourceString.
	
	self
		assert: #(#identifier #'primary_expression' #expression #'expression_statement' #'_simple_statement')
		equals: (module childSandblocks first slot nodes collect: #type as: Array)
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testPythonStringEmpty [

	| module |
	module := SBTSFileParser new parse: '""' language: SBPython.
	self assert: 'string' equals: module childSandblocks first type.
	self assert: 0 equals: module childSandblocks first childSandblocks size
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testPythonStringEscaped [

	| module |
	module := SBTSFileParser new parse: '"\""' language: SBPython.
	self assert: 'string' equals: module childSandblocks first type
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testPythonStringNestedQuotes [

	| module |
	module := SBTSFileParser new parse: '"''"' language: SBPython.
	self assert: 'string' equals: module childSandblocks first type
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testPythonStringSlot [

	| module |
	module := SBTSFileParser new parse: '"abc"' language: SBPython instance.
	"python strings contain a promoted inline symbol and are thus a corner case"
	self assert: module childSandblocks first submorphs second slot notNil
]

{ #category : #'tests - print' }
SBTSParseFileTest >> testRegexCharacterClasses [

	| term source |
	source := '[A-Za-z0-9]'.
	term := SBTSFileParser new parse: source language: SBRegex.
	self assert: source equals: term sourceString
]

{ #category : #'tests - unit' }
SBTSParseFileTest >> testRepeat [

	| factory parser rule |
	factory := SBTSTestLanguage new.
	rule := SBTSNodeRepeat new
		multiple: true
		required: true
		element: (SBTSNodeLabel new label: 'abc').
	parser := ((rule takeNodesFrom: (SBTSFileParser new stream: {'abc'. 'abc'. 'abc'} readStream)) select: #atEnd) first.
	self assert: rule element equals: parser slots first lastNode.
	self assert: rule element equals: parser slots second lastNode.
	self assert: rule element equals: parser slots third lastNode
]

{ #category : #'tests - unit' }
SBTSParseFileTest >> testSeq [

	| factory parser rule |
	factory := SBTSTestLanguage new.
	rule := SBTSNodeSeq new elements: {SBTSNodeSymbol new type: 'id' factory: factory. SBTSNodeSymbol new type: 'id' factory: factory}.
	parser := (rule takeNodesFrom: (SBTSFileParser new stream: {SBTSNodeSymbol new type: 'id' factory: factory. SBTSNodeSymbol new type: 'id' factory: factory} readStream)) first.
	self assert: rule elements first equals: parser slots first lastNode.
	self assert: rule elements second equals: parser slots second lastNode
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testSmalltalkEmptyString [

	| source |
	source := 'a
'''''.
	self assert: source equals: (SBTSFileParser new parse: source language: SBTSSmalltalk) sourceString
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testSmalltalkString [

	| source |
	source := 'a
''abc'''.
	self assert: source equals: (SBTSFileParser new parse: source language: SBTSSmalltalk) sourceString
]

{ #category : #'tests - print' }
SBTSParseFileTest >> testStBinaryOp [

	| op |
	op := SBTSFileParser new parse: 'a 1+2' language: SBTSSmalltalk instance.
	self assert: '1+2' equals: op childSandblocks second sourceString
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testStSymbol [

	SBTSFileParser new parse: 'a #a' language: SBTSSmalltalk
]

{ #category : #'tests - unit' }
SBTSParseFileTest >> testText [

	| factory parser rule |
	factory := SBTSTestLanguage new.
	rule := SBTSNodeSeq new elements: {SBTSNodeText new regexString: 'abc'}.
	parser := (rule takeNodesFrom: (SBTSFileParser new stream: {'abc'} readStream)) first.
	self assert: rule elements first equals: parser slots first lastNode
]
