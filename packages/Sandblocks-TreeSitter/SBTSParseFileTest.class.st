Class {
	#name : #SBTSParseFileTest,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #failures }
SBTSParseFileTest >> expectedFailures [

	^ #(#testJavascriptTemplateString)
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
	self assert: 'binary_expression' equals: module childSandblocks first childSandblocks first type
]

{ #category : #tests }
SBTSParseFileTest >> testParseEmptyModule [

	SBTSFileParser new parse: '' language: SBJavascript instance
]

{ #category : #tests }
SBTSParseFileTest >> testParseStatement [

	| module |
	module := SBTSFileParser new parse: '2' language: SBJavascript instance.
	self assert: 'number' equals: module childSandblocks first childSandblocks first type
]
