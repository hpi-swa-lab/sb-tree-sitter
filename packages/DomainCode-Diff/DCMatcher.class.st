Class {
	#name : #DCMatcher,
	#superclass : #Object,
	#category : #'DomainCode-Diff'
}

{ #category : #'as yet unclassified' }
DCMatcher >> matchFrom: src to: dest do: aBlock [

	| mappings |
	mappings := DCMappingStore new.
	DCGreedySubtreeMatcher new matchFrom: src to: dest in: mappings.
	DCGreedyBottomUpMatcher new matchFrom: src to: dest in: mappings.
	DCChawatheScriptGenerator new
		generateFrom: src
		to: dest
		in: mappings
		do: aBlock
]
