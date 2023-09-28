Class {
	#name : #DCMatcher,
	#superclass : #Object,
	#category : #'DomainCode-Diff'
}

{ #category : #'as yet unclassified' }
DCMatcher >> applyEditsIn: aDest to: aSrc [

	DCChawatheScriptGenerator new
		generateFrom: aSrc
		to: aDest
		in: (self matchFrom: aSrc to: aDest)
]

{ #category : #'as yet unclassified' }
DCMatcher >> doCommandForEditsIn: aDest to: aSrc in: anEditor [

	DCCommandScriptGenerator new
		editor: anEditor;
		generateFrom: aSrc to: aDest in: (self matchFrom: aSrc to: aDest)
]

{ #category : #'as yet unclassified' }
DCMatcher >> matchFrom: src to: dest [

	| mappings |
	mappings := DCMappingStore new.
	DCGreedySubtreeMatcher new matchFrom: src to: dest in: mappings.
	DCGreedyBottomUpMatcher new matchFrom: src to: dest in: mappings.
	^ mappings
]
