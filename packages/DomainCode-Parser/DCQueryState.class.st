Class {
	#name : #DCQueryState,
	#superclass : #Object,
	#instVars : [
		'highlights',
		'newHighlights',
		'rootBlock',
		'selectionUpdateQueued',
		'currentShortcut'
	],
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCQueryState >> highlight: aBlock [

	newHighlights add: aBlock
]

{ #category : #'as yet unclassified' }
DCQueryState >> initialize [

	super initialize.
	
	highlights := WeakSet new.
	selectionUpdateQueued := false
]

{ #category : #'as yet unclassified' }
DCQueryState >> performShortcut: aSymbol for: aBlock [

	[
		currentShortcut := aSymbol.
		self queriesFor: #shortcut do: [:selector |
			DCQuery script: (DCBlock perform: selector) with: aBlock.
			currentShortcut ifNil: [^ true]]] ensure: [currentShortcut := nil].
	^ false
]

{ #category : #'as yet unclassified' }
DCQueryState >> queriesFor: aSymbol do: aBlock [

	Pragma
		withPragmasIn: DCBlock class
		do: [:pragma | (pragma keyword = #query: and: [pragma arguments first includes: aSymbol]) ifTrue: [aBlock value: pragma selector]]
]

{ #category : #'as yet unclassified' }
DCQueryState >> rerunQueriesDo: aBlock [

	newHighlights := WeakSet new.
	aBlock value.
	highlights do: [:block | (newHighlights includes: block) ifFalse: [block detachDecorators: SBHighlightDecorator]].
	newHighlights do: [:block | (highlights includes: block) ifFalse: [block attachDecorator: SBHighlightDecorator new]].
	highlights := newHighlights
]

{ #category : #'as yet unclassified' }
DCQueryState >> rootBlock [

	^ rootBlock
]

{ #category : #'as yet unclassified' }
DCQueryState >> rootBlock: aBlock [

	rootBlock := aBlock
]

{ #category : #'as yet unclassified' }
DCQueryState >> tryShortcut: aSymbol do: aBlock [

	currentShortcut = aSymbol ifTrue: [
		DCQuery script: aBlock value with: self rootBlock sandblockEditor selection.
		currentShortcut := nil]
]

{ #category : #'as yet unclassified' }
DCQueryState >> updateSelectionQueries [

	selectionUpdateQueued ifTrue: [^ self].
	selectionUpdateQueued := true.
	Project current addDeferredUIMessage: [
		selectionUpdateQueued := false.
		self rerunQueriesDo: [
			self
				queriesFor: #selection
				do: [:selector | self rootBlock allBlocksDo: [:b | DCQuery script: (DCBlock perform: selector) with: b]]]]
]
