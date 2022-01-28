Class {
	#name : #SBTSParseFileTest,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #failures }
SBTSParseFileTest >> expectedFailures [

	^ #(#testJavascriptTemplateString #testPythonImport)
]

{ #category : #tests }
SBTSParseFileTest >> testJavascriptImport [

	| block |
	block := SBTSFileParser new
		parse: 'import {A} from ''a'''
		language: SBJavascript instance.
	self assert: (block matchesQuery: '(program (import_statement (import_clause (named_imports (identifier)))))').
	block := SBTSFileParser new
		parse: 'import {A as B} from ''a'''
		language: SBJavascript instance.
	self assert: (block matchesQuery: '(program (import_statement (import_clause (named_imports (identifier) (identifier)))))')
]

{ #category : #tests }
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

{ #category : #tests }
SBTSParseFileTest >> testParseBinaryExpression [

	| module |
	module := SBTSFileParser new parse: '2+2' language: SBJavascript instance.
	self assert: 'binary_expression' equals: module childSandblocks first type
]

{ #category : #tests }
SBTSParseFileTest >> testParseEmptyModule [

	SBTSFileParser new parse: '' language: SBJavascript instance
]

{ #category : #tests }
SBTSParseFileTest >> testParsePythonFormatString [

	| string |
	string := (SBTSFileParser new parse: '"abc"' language: SBPython instance) access children first.
	self assert: 'abc' equals: string contents.
	string := (SBTSFileParser new parse: 'f"abc"' language: SBPython instance) access children first.
	self assert: 'abc' equals: string contents.
	string := (SBTSFileParser new
		parse: 'f"abc{var1}def{var2}ghi"'
		language: SBPython instance) access children first.
	self assert: 'abcdefghi' equals: string contents
]

{ #category : #tests }
SBTSParseFileTest >> testParseStatement [

	| module |
	module := SBTSFileParser new parse: '2' language: SBJavascript instance.
	self assert: 'number' equals: module childSandblocks first type
]

{ #category : #tests }
SBTSParseFileTest >> testPythonComprehension [

	| source |
	source := '(0 for i in range)'.
	self
		assert: source
		equals: (SBTSFileParser new parse: source language: SBPython instance) sourceString
]

{ #category : #tests }
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

{ #category : #tests }
SBTSParseFileTest >> testPythonImport [

	| block |
	block := SBTSFileParser new parse: 'import numpy' language: SBPython instance.
	self assert: (block matchesQuery: '(module (import_statement (dotted_name (identifier))))').
	block := SBTSFileParser new parse: 'import numpy as np' language: SBPython instance.
	block printSExpr.
	self assert: (block matchesQuery: '(module (import_statement (aliased_import (dotted_name (identifier)) alias: (identifier))))')
]

{ #category : #tests }
SBTSParseFileTest >> testVerilogAliases [

	SBTSFileParser new
		parse: 'module rmem_respfifo #(parameter integer WIDTH = 550) (
    input              clock
) ;
endmodule'
		language: SBVerilog instance
]
