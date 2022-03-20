Class {
	#name : #SBTSParseFileTest,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

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

{ #category : #'tests - languages' }
SBTSParseFileTest >> testJavascriptImport [

	| block source |
	source := 'import{A}from''a'''.
	block := SBTSFileParser new parse: source language: SBJavascript instance.
	self assert: source equals: block sourceString.
	source := 'import{A as B}from''a'''.
	block := SBTSFileParser new parse: source language: SBJavascript instance.
	self assert: source equals: block sourceString
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testJavascriptString [

	| sourceString parsed |
	sourceString := '"a"'.
	parsed := SBTSFileParser new parse: sourceString language: SBJavascript instance.
	self assert: sourceString equals: parsed sourceString
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testJavascriptTemplateString [

	| source |
	source := '`ab`'.
	self
		assert: source
		equals: (SBTSFileParser new parse: source language: SBJavascript instance) sourceString.
	source := '`ab${a}`'.
	self
		assert: source
		equals: (SBTSFileParser new parse: source language: SBJavascript instance) sourceString.
	source := '`ab${a}def${c}`'.
	self
		assert: source
		equals: (SBTSFileParser new parse: source language: SBJavascript instance) sourceString
]

{ #category : #'tests - languages' }
SBTSParseFileTest >> testJsFunctionPatterns [

	| module |
	module := SBTSFileParser new parse: 'function(b) {}' language: SBJavascript instance.
	self assert: #(#identifier #pattern) equals: (module childSandblocks first childSandblocks first slot nodes
		collect: #type
		as: Array)
]

{ #category : #'tests - unit' }
SBTSParseFileTest >> testLabel [

	| factory parser rule |
	factory := SBTSTestLanguage new.
	rule := SBTSNodeSeq new elements: {SBTSNodeLabel new label: 'abc'}.
	parser := (rule takeNodesFrom: (SBTSFileParser new stream: {'abc'} readStream)) first.
	self assert: rule elements first equals: parser slots first lastNode
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
	block := SBTSFileParser new parse: 'a' language: SBJavascript rebuild.
	
	self assert: block childSandblocks first isTSBlock.
	self
		assert: (SBJavascript instance bodyNodeForRule: 'program') elements second element
		equals: block childSandblocks first slot lastNode
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
SBTSParseFileTest >> testPythonStatements [

	| source |
	source := 'a
b'.
	self
		assert: source
		equals: (SBTSFileParser new parse: source language: SBPython instance) sourceString
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

{ #category : #'tests - print' }
SBTSParseFileTest >> testStBinaryOp [

	| op |
	op := SBTSFileParser new parse: 'a 1+2' language: SBTSSmalltalk instance.
	self assert: '1+2' equals: op childSandblocks second sourceString
]

{ #category : #'tests - unit' }
SBTSParseFileTest >> testText [

	| factory parser rule |
	factory := SBTSTestLanguage new.
	rule := SBTSNodeSeq new elements: {SBTSNodeText new regexString: 'abc'}.
	parser := (rule takeNodesFrom: (SBTSFileParser new stream: {'abc'} readStream)) first.
	self assert: rule elements first equals: parser slots first lastNode
]
