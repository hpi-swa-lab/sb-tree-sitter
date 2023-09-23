Class {
	#name : #SBTSLanguageTests,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Tests'
}

{ #category : #failures }
SBTSLanguageTests >> expectedFailures [

	^ #()
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testAliasedRootSymbol [

	SBToggledCode
		comment: ''
		active: 0
		do: {[SBVhdl parseToplevel: 'assert << constant obj : bar_t  >>;']}.
	SBJavascript parseToplevel: '{headers: "abc"}'
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testCInclude [

	SBC parseToplevel: '#include <stdio.h>
'.
	" fails because tree-sitter reports two \n as the last element of the directive "
	SBC parseToplevel: '#include <stdio.h>

'
]

{ #category : #'testing - printing' }
SBTSLanguageTests >> testCReturn [

	| source |
	source := 'return 2;'.
	self assert: source equals: (SBC parseToplevel: source) sourceString
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testCppConstructor [

	SBCpp parseToplevel: 'A::A() {
}'
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testJavascriptImport [

	| block |
	block := SBJavascript parseToplevel: 'import {A} from ''a'''.
	self assert: (block matchesQuery: '(program (import_statement (import_clause (named_imports (_ (identifier))))))').
	
	block := SBJavascript parseToplevel: 'import {A as B} from ''a'''.
	self assert: (block matchesQuery: '(program (import_statement (import_clause (named_imports (_ (identifier) (identifier))))))')
]

{ #category : #'testing - printing' }
SBTSLanguageTests >> testJavascriptNestedMemberExpression [

	| source |
	source := 'a.b.c;'.
	self assert: source equals: (SBJavascript parseExpression: source) sourceString
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testJavascriptTemplateString [

	| source |
	source := '`ab`;'.
	self assert: source equals: (SBJavascript parseToplevel: source) sourceString.
	
	source := '`ab${a}`;'.
	self assert: source equals: (SBJavascript parseToplevel: source) sourceString.
	
	source := '`ab${a}def${c}`;'.
	self assert: source equals: (SBJavascript parseToplevel: source) sourceString
]

{ #category : #'testing - printing' }
SBTSLanguageTests >> testJavascriptToString [

	| source |
	source := 'a;
b;'.
	self assert: source equals: (SBJavascript parseToplevel: source) sourceString.
	
	source := '<h2>Hi</h2>;'.
	self assert: source equals: (SBJavascript parseToplevel: source) sourceString.
	
	source := 'class A extends B
{
}'.
	self assert: source equals: (SBJavascript parseToplevel: source) sourceString.
	
	source := 'class Car extends React.Component
{
example={}
render()
{
a;
return<h2>Hi</h2>;
}
}'.
	self assert: source equals: (SBJavascript parseToplevel: source) sourceString.
	
	source := 'a(b,c);'.
	self assert: source equals: (SBJavascript parseToplevel: source) sourceString.
	
	source := 'a(2,3);'.
	self assert: source equals: (SBJavascript parseToplevel: source) sourceString.
	
	source := 'const a=5;'.
	self assert: source equals: (SBJavascript parseToplevel: source) sourceString.
	
	source := '<h2 style="color:red"></a>;'.
	self assert: source equals: (SBJavascript parseToplevel: source) sourceString.
	
	source := 'if(a)
{
}
else
{
}'.
	self assert: source equals: (SBJavascript parseToplevel: source) sourceString
]

{ #category : #'testing - printing' }
SBTSLanguageTests >> testJavascriptToStringSemicolons [

	| source |
	source := 'let a,b=5;'.
	self assert: source equals: (SBJavascript parseToplevel: source) sourceString.
	
	source := 'const a=5;'.
	self assert: source equals: (SBJavascript parseToplevel: source) sourceString
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testJsonString [

	SBJson parse: '"abc"'
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testJsonStringWithEscape [

	| source |
	source := '"ToGo-Schale 1,00€\/Stk."'.
	self assert: source equals: (SBJson parseToplevel: source) sourceString
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testParsePythonFormatString [

	| string |
	string := SBPython parseExpression: 'f"abc{var1}def{var2}ghi"'.
	self assert: 'f"abc{var1}def{var2}ghi"' equals: string sourceString.
	
	string := SBPython parseExpression: '"abc"'.
	self assert: 'abc' equals: string contents.
	
	string := SBPython parseExpression: 'f"abc"'.
	self assert: 'abc' equals: string textMorphs second contents
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testPythonComprehension [

	| source |
	source := '(123 for i in range)'.
	self assert: source equals: (SBPython parseToplevel: source) sourceString
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testPythonDecorators [

	| source |
	source := '@staticmethod
@abc
def a():
    pass'.
	self assert: source equals: (SBPython parseToplevel: source) sourceString
]

{ #category : #'testing - interactions' }
SBTSLanguageTests >> testPythonDeleteStatement [

	| block e |
	block := SBPython parseToplevel: 'a'.
	e := self editorFor: block.
	block childSandblocks first
		select;
		deleteBlock.
	self assert: block childSandblocks isEmpty
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testPythonEmptyModule [

	SBPython parseToplevel: ''
]

{ #category : #'testing - printing' }
SBTSLanguageTests >> testPythonIf [

	| source |
	source := 'if a:
    b
elif c:
    d
elif f:
    g
else:
    e'.
	self assert: source equals: (SBPython parseToplevel: source) sourceString
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testPythonImport [

	| block |
	block := SBPython parseToplevel: 'import numpy'.
	self assert: (block matchesQuery: '(module (import_statement (dotted_name (identifier))))').
	
	block := SBPython parseToplevel: 'import numpy as np'.
	self assert: (block matchesQuery: '(module (import_statement (aliased_import (dotted_name (identifier)) alias: (identifier))))')
]

{ #category : #'testing - printing' }
SBTSLanguageTests >> testPythonIndent [

	| source |
	source := 'if a:
    if b:
        pass'.
	self assert: source equals: (SBPython parseToplevel: source) sourceString.
	
	source := 'if a:
    print("a")
    print("b")
else:
    print("c")
    print("d")'.
	self assert: source equals: (SBPython parseToplevel: source) sourceString
]

{ #category : #'testing - interactions' }
SBTSLanguageTests >> testPythonInsertLambdaParameter [

	| module e |
	module := SBPython parseToplevel: 'lambda: x'.
	e := self editorFor: module.
	
	module childSandblocks first startInputAtStart.
	7 timesRepeat: [e performForSelection: #moveCursorRight].
	e handle: (self keyboardEvent: $a).
	
	self assert: 'a' equals: module childSandblocks first childSandblocks first childSandblocks first contents
]

{ #category : #'testing - interactions' }
SBTSLanguageTests >> testPythonNumber [

	| block e |
	block := SBPython parseToplevel: 'a'.
	e := self editorAndWorldFor: block.
	block childSandblocks first
		select;
		insertStatementBelow.
	e handle: (self keyboardEvent: $1).
	self assert: (block matchesQuery: '(module (integer))').
	
	e handle: (self keyboardEvent: $.).
	e handle: (self keyboardEvent: $3).
	self assert: (block matchesQuery: '(module (float))')
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testPythonString [

	self assert: 'abc' equals: (SBPython parseExpression: '''abc''') contents.
	self assert: 'abc' equals: (SBPython parseExpression: '"abc"') contents.
	self assert: 'abc' equals: (SBPython parseExpression: 'f"abc"') textMorphs second contents.
	self assert: '"abc\n"' equals: (SBPython parseExpression: '"abc\n"') sourceString.
	self assert: '"""abc\n"""' equals: (SBPython parseExpression: '"""abc\n"""') sourceString
]

{ #category : #'testing - interactions' }
SBTSLanguageTests >> testRegexResumeInput [

	| block e |
	block := SBRegex parseToplevel: 'abc'.
	e := self editorFor: block.
	block lastDeepChild startInputAtEnd.
	e selection keyStroke: (self keyboardEvent: $d).
	
	self assert: 'abcd' equals: block sourceString
]

{ #category : #'testing - parse' }
SBTSLanguageTests >> testSyntaxError [

	self shouldnt: [SBPython parseToplevel: '"abc"('] raise: SBTSSyntaxError
]
