Class {
	#name : #DCMatchTest,
	#superclass : #TestCase,
	#category : #'DomainCode-Diff'
}

{ #category : #'as yet unclassified' }
DCMatchTest >> testAppendBinary [

	| src dest |
	Transcript clear.
	src := DCBlock parseBlock: 'a' language: SBJavascript.
	dest := DCBlock parseBlock: 'a+' language: SBJavascript.
	DCMatcher new matchFrom: src to: dest.
	self assert: 'a+' equals: src sourceString
]

{ #category : #'as yet unclassified' }
DCMatchTest >> testSplitBinary [

	| src dest |
	Transcript clear.
	src := DCBlock parseBlock: 'a2' language: SBJavascript.
	dest := DCBlock parseBlock: 'a+2' language: SBJavascript.
	DCMatcher new matchFrom: src to: dest.
	self assert: 'a+2' equals: src sourceString
]
