Class {
	#name : #DCZhangShashaMatcherTest,
	#superclass : #TestCase,
	#category : #'DomainCode-Diff'
}

{ #category : #'as yet unclassified' }
DCZhangShashaMatcherTest >> testSimpleTree [

	| src dest mappings |
	src := DCBlock parseBlock: '2+c' language: SBJavascript.
	dest := DCBlock parseBlock: '2+ab+c' language: SBJavascript.
	
	mappings := DCMappingStore new.
	DCZhangShashaMatcher new matchFrom: src to: dest in: mappings.
	mappings
]
