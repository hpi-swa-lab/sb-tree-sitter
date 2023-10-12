Class {
	#name : #DCMatchTest,
	#superclass : #TestCase,
	#category : #'DomainCode-Diff'
}

{ #category : #'as yet unclassified' }
DCMatchTest >> testAppendBinary [

	| src dest |
	src := DCBlock parseBlock: 'a' language: SBJavascript.
	dest := DCBlock parseBlock: 'a+' language: SBJavascript.
	DCMatcher new applyEditsIn: dest to: src.
	self assert: 'a+' equals: src generatedSourceString
]

{ #category : #'as yet unclassified' }
DCMatchTest >> testSplitBinary [

	| src dest |
	src := DCBlock parseBlock: 'a2' language: SBJavascript.
	dest := DCBlock parseBlock: 'a+2' language: SBJavascript.
	DCMatcher new applyEditsIn: dest to: src.
	self assert: 'a+2' equals: src generatedSourceString
]
