Class {
	#name : #SBTSLanguageTests,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Tests'
}

{ #category : #failures }
SBTSLanguageTests >> expectedFailures [

	^ #(#testPythonPatternList #testJavascriptToStringSemicolons #testCInclude)
]

{ #category : #'testing - interactions' }
SBTSLanguageTests >> testApplyPyFilePathReplacement [

	| parsed |
	parsed := SBPython parseAndReplace: 'with open(''data.csv'', newline='''') as csvfile:
	spamreader = csv.reader(csvfile, delimiter='' '', quotechar=''|'')
	for row in spamreader:
		print('', ''.join(row))'.
	self assert: (parsed childSandblocks first childSandblocks first childSandblocks first childSandblocks second childSandblocks first isKindOf: SBPyFilepath)
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testCInclude [

	SBC parse: '#include <stdio.h>
'.
	" fails because tree-sitter reports two \n as the last element of the directive "
	SBC parse: '#include <stdio.h>

'
]

{ #category : #'testing - printing' }
SBTSLanguageTests >> testCReturn [

	| source |
	source := 'return 2;'.
	self assert: source equals: (SBC parse: source) sourceString
]

{ #category : #'testing - block inline' }
SBTSLanguageTests >> testJavascriptBlockInline [

	self assert: (SBJavascript instance shouldBlockInline: 'formal_parameters')
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testJavascriptFoundDelimiters [

	| lang |
	lang := SBJavascript rebuild.
	{
		'object' -> {','}.
		'arguments' -> {','}.
		'formal_parameters' -> {','}.
		'array_pattern' -> {','}.
		'named_imports' -> {','}} do: [:pair | self assert: (lang delimitedRules includesAssociation: pair)]
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testJavascriptImport [

	| block |
	block := SBJavascript parse: 'import {A} from ''a'''.
	self assert: (block matchesQuery: '(program (import_statement (import_clause (named_imports (identifier)))))').
	
	block := SBJavascript parse: 'import {A as B} from ''a'''.
	self assert: (block matchesQuery: '(program (import_statement (import_clause (named_imports (identifier) (identifier)))))')
]

{ #category : #'testing - interactions' }
SBTSLanguageTests >> testJavascriptNestedIdentifierForMethodField [

	| identifier |
	identifier := SBJavascript parseElement: 'abc'.
	
	self assert: 1 equals: (SBTSRuleExplore new
		maxRecursionDepth: 1;
		explore: (SBJavascript instance getTemplate: 'class_body') elements second element
			withNested: identifier
			nestedBefore: true
			for: '('
			startSymbol: nil) size
]

{ #category : #'testing - printing' }
SBTSLanguageTests >> testJavascriptNestedMemberExpression [

	| source |
	source := 'a.b.c'.
	self assert: source equals: (SBJavascript parseElement: source) sourceString
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testJavascriptTemplateString [

	| source |
	source := '`ab`'.
	self assert: source equals: (SBJavascript parse: source) sourceString.
	
	source := '`ab${a}`'.
	self assert: source equals: (SBJavascript parse: source) sourceString.
	
	source := '`ab${a}def${c}`'.
	self assert: source equals: (SBJavascript parse: source) sourceString
]

{ #category : #'testing - printing' }
SBTSLanguageTests >> testJavascriptToString [

	| source |
	source := '<h2>Hi</h2>'.
	self assert: source equals: (SBJavascript parseElement: source) sourceString.
	
	source := 'class A extends B{}'.
	self assert: source equals: (SBJavascript parseElement: source) sourceString.
	
	source := 'class Car extends React.Component{
example={};
render(){
a
return<h2>Hi</h2>}}'.
	self assert: source equals: (SBJavascript parseElement: source) sourceString.
	
	source := 'a(b,c)'.
	self assert: source equals: (SBJavascript parseElement: source) sourceString.
	
	source := 'a(2,3)'.
	self assert: source equals: (SBJavascript parseElement: source) sourceString.
	
	source := 'const a=5'.
	self assert: source equals: (SBJavascript parseElement: source) sourceString.
	
	source := '<h2 style="color:red"></a>'.
	self assert: source equals: (SBJavascript parseElement: source) sourceString
]

{ #category : #'testing - printing' }
SBTSLanguageTests >> testJavascriptToStringSemicolons [

	| source |
	source := 'let a,b = 5;'.
	self assert: source equals: (SBJavascript parseElement: source) sourceString.
	
	source := 'const a = 5;'.
	self assert: source equals: (SBJavascript parseElement: source) sourceString
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testMultipleDelimiters [

	| block |
	self assert: (SBJavascript rebuild delimitedRules includesAssociation: 'lexical_declaration' -> {';'. ','}).
	block := SBJavascript parse: 'let a;'
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testParsePythonFormatString [

	| string |
	SBPython rebuild.
	SBPython instance grammar rules at: '_newline'.
	string := SBPython parseElement: '"abc"'.
	self assert: 'abc' equals: string contents.
	
	string := SBPython parseElement: 'f"abc"'.
	self assert: 'abc' equals: string contents.
	
	string := SBPython parseElement: 'f"abc{var1}def{var2}ghi"'.
	self assert: 'abcdefghi' equals: string contents
]

{ #category : #'testing - interactions' }
SBTSLanguageTests >> testPythonBinaryOperator [

	| block e |
	block := SBPython parse: '123'.
	e := self editorFor: block.
	[
		block childSandblocks first
			select;
			keyStroke: (self keyboardEvent: $+)]
		on: ProvideAnswerNotification
		do: [:n | self assert: false].
	
	self assert: (block matchesQuery: '(module (expression_statement (binary_operator)))')
]

{ #category : #'testing - interactions' }
SBTSLanguageTests >> testPythonDeleteStatement [

	| block e |
	block := SBPython parse: 'a'.
	e := self editorFor: block.
	block childSandblocks first
		select;
		deleteBlock.
	self assert: block childSandblocks isEmpty
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testPythonFoundDelimiters [

	| lang |
	lang := SBPython rebuild.
	{'argument_list' -> {','}. 'parameters' -> {','}. 'tuple_pattern' -> {','}. 'list' -> {','}} do: [:pair | self assert: (lang delimitedRules includesAssociation: pair)]
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testPythonImport [

	| block |
	block := SBPython parse: 'import numpy'.
	self assert: (block matchesQuery: '(module (import_statement (dotted_name (identifier))))').
	
	block := SBPython parse: 'import numpy as np'.
	self assert: (block matchesQuery: '(module (import_statement (aliased_import (dotted_name (identifier)) alias: (identifier))))')
]

{ #category : #'testing - printing' }
SBTSLanguageTests >> testPythonIndent [

	| source |
	source := 'if a:
	if b:
		pass'.
	self assert: source equals: (SBPython parse: source) sourceString
]

{ #category : #'testing - interactions' }
SBTSLanguageTests >> testPythonInsertLambdaParameter [

	| module e |
	module := SBPython parse: 'lambda: x'.
	e := self editorFor: module.
	
	e performForSelection: #moveCursorRight.
	e performForSelection: #moveCursorRight.
	e performForSelection: #moveCursorRight.
	e handle: (self keyboardEvent: $a).
	
	self assert: 'a' equals: module access children first parameters children first contents
]

{ #category : #'testing - interactions' }
SBTSLanguageTests >> testPythonIntToFloat [

	| block e |
	block := SBPython parse: '123'.
	e := self editorFor: block.
	[
		block childSandblocks first
			select;
			moveCursorToEnd;
			keyStroke: (self keyboardEvent: $.)]
		on: ProvideAnswerNotification
		do: [:notification | " expect to receive float and member access "
		notification resume: 1].
	self assert: (block matchesQuery: '(module (expression_statement (float)))')
]

{ #category : #'testing - interactions' }
SBTSLanguageTests >> testPythonNumber [

	| block e |
	block := SBPython parse: 'a'.
	e := self editorFor: block.
	block childSandblocks first
		select;
		insertStatementBelow.
	[block childSandblocks second keyStroke: (self keyboardEvent: $1)]
		on: ProvideAnswerNotification
		do: [:n | self assert: false].
	
	self assert: (block matchesQuery: '(module (expression_statement (integer)))')
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testPythonPatternList [

	| lang |
	" not sure yet how to handle a,,,b = ... "
	lang := SBPython rebuild.
	lang
		traverse: (lang grammar rules at: 'pattern_list')
		do: [:obj | self assert: (obj type ~= 'STRING' or: [obj value ~= ','])].
	self assert: (lang delimitedRules includesAssociation: 'pattern_list' -> ',')
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testPythonString [

	self assert: 'abc' equals: (SBPython parseElement: '''abc''') contents.
	self assert: 'abc' equals: (SBPython parseElement: '"abc"') contents.
	self assert: 'abc' equals: (SBPython parseElement: 'f"abc"') contents.
	self assert: 'abc\n' equals: (SBPython parseElement: '"abc\n"') contents.
	self assert: 'abc\n' equals: (SBPython parseElement: '"""abc\n"""') contents
]

{ #category : #'testing - interactions' }
SBTSLanguageTests >> testRegexResumeInput [

	| block e |
	block := SBRegex parse: 'abc'.
	e := self editorFor: block.
	block lastDeepChild select.
	[e selection keyStroke: (self keyboardEvent: $d)]
		on: ProvideAnswerNotification
		do: [:n | self assert: false].
	
	self assert: 'abcd' equals: block sourceString
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testSyntaxError [

	self should: [SBPython parse: '"abc"('] raise: SBTSSyntaxError
]
