Class {
	#name : #DCMatchTest,
	#superclass : #TestCase,
	#category : #'DomainCode-Diff'
}

{ #category : #'as yet unclassified' }
DCMatchTest >> testSimple [

	| src dest mappings |
	Transcript clear.
	src := DCBlock parseBlock: 'ab + 22' language: SBJavascript.
	dest := DCBlock parseBlock: 'abc + 2' language: SBJavascript.
	mappings := DCMappingStore new.
	DCGreedySubtreeMatcher new matchFrom: src to: dest in: mappings.
	DCGreedyBottomUpMatcher new matchFrom: src to: dest in: mappings.
	Transcript showln: (Array streamContents: [:stream |
		DCChawatheScriptGenerator new
			generateFrom: src
			to: dest
			in: mappings
			do: [:op :args | stream nextPut: {op. args}]])
]