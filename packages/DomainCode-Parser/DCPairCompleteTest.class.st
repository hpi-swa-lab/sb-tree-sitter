Class {
	#name : #DCPairCompleteTest,
	#superclass : #SBTest,
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCPairCompleteTest >> expectedFailures [

	^ #(#testDeleteInPair #testJumpAfterClosedPair)
]

{ #category : #'as yet unclassified' }
DCPairCompleteTest >> testDeleteInPair [

	| program editor |
	program := DCBlock parse: '()' language: SBJavascript.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtEnd.
	editor handle: (self keyboardEvent: Character backspace).
	self assert: '' equals: editor childSandblocks first sourceString
]

{ #category : #'as yet unclassified' }
DCPairCompleteTest >> testDontSkipInsertQuoteAfterSpace [

	| program editor |
	program := DCBlock parse: '"a' language: SBJavascript.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtEnd.
	self type: ' ''' in: editor.
	self assert: '"a ''''' equals: editor childSandblocks first sourceString
]

{ #category : #'as yet unclassified' }
DCPairCompleteTest >> testIgnoreAfterBackslash [

	| program editor |
	program := DCBlock parse: '"a\' language: SBJavascript.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtEnd.
	self type: '(' in: editor.
	self assert: '"a\(' equals: editor childSandblocks first sourceString
]

{ #category : #'as yet unclassified' }
DCPairCompleteTest >> testInputWhenImbalanced [

	| program editor |
	program := DCBlock parse: '{
	a {
}' language: SBJavascript.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtEnd.
	self type: '}' in: editor.
	self assert: '{
a
{
}
}' equals: editor childSandblocks first sourceString
]

{ #category : #'as yet unclassified' }
DCPairCompleteTest >> testInsertInPair [

	| program editor |
	program := DCBlock parse: 'a' language: SBJavascript.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtEnd.
	self type: '(' in: editor.
	self assert: 'a()' equals: editor childSandblocks first sourceString
]

{ #category : #'as yet unclassified' }
DCPairCompleteTest >> testInsertInPairAndContinue [

	| program editor |
	program := DCBlock parse: 'a' language: SBJavascript.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtEnd.
	self type: '(b' in: editor.
	self assert: 'a(b)' equals: editor childSandblocks first sourceString
]

{ #category : #'as yet unclassified' }
DCPairCompleteTest >> testJumpAfterClosedPair [

	| program editor |
	program := DCBlock parse: '{a}' language: SBJavascript.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtEnd.
	self assert: 'a' equals: editor selection contents.
	self type: '}b' in: editor.
	self assert: '{
a
}
b' equals: editor childSandblocks first sourceString
]

{ #category : #'as yet unclassified' }
DCPairCompleteTest >> testSkipClosedBracket [

	| program editor |
	program := DCBlock parse: 'a' language: SBJavascript.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtEnd.
	self type: '()' in: editor.
	self assert: 'a()' equals: editor childSandblocks first sourceString
]

{ #category : #'as yet unclassified' }
DCPairCompleteTest >> testSkipInsertQuoteWhenInWord [

	| program editor |
	program := DCBlock parse: 'a' language: SBJavascript.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtEnd.
	self type: '''' in: editor.
	self assert: 'a''' equals: editor childSandblocks first sourceString
]

{ #category : #'as yet unclassified' }
DCPairCompleteTest >> testSkipStringInString [

	| program editor |
	program := DCBlock parse: 'a' language: SBJavascript.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtEnd.
	self type: '("a"' in: editor.
	self assert: 'a("a")' equals: editor childSandblocks first sourceString
]
