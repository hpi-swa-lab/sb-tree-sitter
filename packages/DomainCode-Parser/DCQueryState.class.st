Class {
	#name : #DCQueryState,
	#superclass : #Object,
	#instVars : [
		'currentDecorators',
		'newDecorators',
		'rootBlock',
		'currentShortcut',
		'updateQueued'
	],
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCQueryState >> errors [

	^ Array streamContents: [:s | self rootBlock allBlocksDo: [:b | b withDecorator: SBErrorDecorator do: [:d | s nextPut: d] ifAbsent: []]]
]

{ #category : #'as yet unclassified' }
DCQueryState >> highlight: aBlock [

	(newDecorators at: aBlock ifAbsentPut: [OrderedCollection new]) add: SBHighlightDecorator new
]

{ #category : #'as yet unclassified' }
DCQueryState >> initialize [

	super initialize.
	
	currentDecorators := Dictionary new
		at: #selection put: WeakKeyDictionary new;
		at: #change put: WeakKeyDictionary new;
		at: #type put: WeakKeyDictionary new;
		yourself.
	updateQueued := Dictionary new
]

{ #category : #shortcuts }
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
		do: [:pragma | (pragma keyword = #query: and: [pragma arguments first = aSymbol]) ifTrue: [aBlock value: pragma selector]]
]

{ #category : #'as yet unclassified' }
DCQueryState >> reportError: aDecorator for: aBlock [

	(newDecorators at: aBlock ifAbsentPut: [OrderedCollection new]) add: aDecorator
]

{ #category : #'as yet unclassified' }
DCQueryState >> rerunQueriesFor: aSymbol do: aBlock [

	| oldDecorators |
	newDecorators := WeakKeyDictionary new.
	
	aBlock value.
	
	oldDecorators := currentDecorators at: aSymbol.
	oldDecorators do: [:list | list do: [:d | d detach]].
	newDecorators keysAndValuesDo: [:block :list | list do: [:d | block attachDecorator: d]].
	currentDecorators at: aSymbol put: newDecorators
]

{ #category : #accessing }
DCQueryState >> rootBlock [

	^ rootBlock
]

{ #category : #accessing }
DCQueryState >> rootBlock: aBlock [

	rootBlock := aBlock
]

{ #category : #shortcuts }
DCQueryState >> tryShortcut: aSymbol do: aBlock [

	currentShortcut = aSymbol ifTrue: [
		DCQuery script: aBlock value with: self rootBlock sandblockEditor selection.
		currentShortcut := nil]
]

{ #category : #'as yet unclassified' }
DCQueryState >> updateChangeQueries [

	self updateQueriesFor: #change.
	self updateTypeQueries
]

{ #category : #'as yet unclassified' }
DCQueryState >> updateQueriesFor: aSymbol [

	(updateQueued at: aSymbol ifAbsent: [false]) ifTrue: [^ self].
	updateQueued at: aSymbol put: true.
	Project current addDeferredUIMessage: [
		updateQueued at: aSymbol put: false.
		self rerunQueriesFor: aSymbol do: [
			self
				queriesFor: aSymbol
				do: [:selector | self rootBlock allBlocksDo: [:b | DCQuery script: (DCBlock perform: selector) with: b]]]]
]

{ #category : #'as yet unclassified' }
DCQueryState >> updateSelectionQueries [

	self updateQueriesFor: #selection
]

{ #category : #'as yet unclassified' }
DCQueryState >> updateTypeQueries [

	self updateQueriesFor: #type
]
