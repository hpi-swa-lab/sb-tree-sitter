Class {
	#name : #DCEditTest,
	#superclass : #SBTest,
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCEditTest >> testAcceptJS [
	<timeout: 9000>

	| src editor |
	src := 'function() {}'.
	editor := self editorFor: (DCBlock parseBlock: src first asString language: SBJavascript).
	src allButFirst
		do: [:char | editor handle: (self keyboardEvent: char)]
		displayingProgress: 'a'
]

{ #category : #'as yet unclassified' }
DCEditTest >> testDeleteEmptyLine [

	| program editor |
	program := DCBlock parse: 'a;

b;' language: SBJavascript.
	editor := self editorAndWorldFor: program.
	program childSandblocks second startInputAtEnd.
	editor handle: (self keyboardEvent: Character backspace).
	self assert: 2 equals: editor childSandblocks first childSandblocks size
]

{ #category : #'as yet unclassified' }
DCEditTest >> testInsertsStatementTerminator [

	| program editor |
	program := DCBlock parse: 'a
b.
c.' language: SBTSSmalltalk.
	editor := self editorAndWorldFor: program.
	program childSandblocks second startInputAtEnd.
	self type: '
x' in: editor.
	self assert: 'a
b.
x.
c.' equals: editor childSandblocks first sourceString
]

{ #category : #'as yet unclassified' }
DCEditTest >> testSmalltalkAssignmentKeywordMethod [

	| program editor |
	program := DCBlock parse: 'a: arg
x := 3' language: SBTSSmalltalk.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtEnd.
	self type: '4' in: editor.
	self assert: 'a:arg
x := 34' equals: editor childSandblocks first sourceString
]

{ #category : #'as yet unclassified' }
DCEditTest >> testSwapBinaryAddition [

	| program editor |
	program := DCBlock parse: 'a + b' language: SBJavascript.
	editor := self editorAndWorldFor: program.
	program firstDeepChild select.
	editor selection swapRight.
	self assert: 'b+a' equals: editor childSandblocks first sourceString
]

{ #category : #'as yet unclassified' }
DCEditTest >> testSwapBlockExtents [

	| program editor |
	program := DCBlock parse: '{
	a;
}
b;' language: SBJavascript.
	editor := self editorAndWorldFor: program.
	program childSandblocks first startInputAtEnd.
	editor selection activeTextMorph contents.
	editor selection swapRight.
	self assert: '{
a;
b;
}' equals: editor childSandblocks first sourceString
]

{ #category : #'as yet unclassified' }
DCEditTest >> testSwapStatements [

	| program editor |
	program := DCBlock parse: 'let a;
let b;' language: SBJavascript.
	editor := self editorAndWorldFor: program.
	editor selectNoInput: program childSandblocks first.
	editor selection swapRight.
	self assert: 'let b;
let a;' equals: editor childSandblocks first sourceString
]

{ #category : #'as yet unclassified' }
DCEditTest >> testTypeKeywordAdjacentWithSpace [

	| program editor |
	program := DCBlock parse: 'i
let a;' language: SBJavascript.
	editor := self editorAndWorldFor: program.
	program firstDeepChild startInputAtEnd.
	self type: 'mport a from a;' in: editor.
	self assert: 'import a from a;
let a;' equals: editor childSandblocks first sourceString
]

{ #category : #'as yet unclassified' }
DCEditTest >> testTypeKeywordWithSpace [

	| program editor |
	program := DCBlock parse: 'let;' language: SBJavascript.
	editor := self editorAndWorldFor: program.
	program firstDeepChild startInputAtEnd.
	self type: ' a' in: editor.
	self assert: 'let a;' equals: editor childSandblocks first sourceString
]
