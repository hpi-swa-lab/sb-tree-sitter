Class {
	#name : #DCQueryState,
	#superclass : #Object,
	#instVars : [
		'currentDecorators',
		'newDecorators',
		'rootBlock',
		'currentShortcut',
		'updateQueued',
		'suggestions',
		'transientReplacements',
		'currentTrigger',
		'querySourceOverride'
	],
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCQueryState >> addSuggestions: aCollection for: aBlock [

	(suggestions notNil and: [suggestions key = aBlock])
		ifTrue: [suggestions value: suggestions value, aCollection]
		ifFalse: [suggestions := aBlock -> aCollection].
	
	aBlock sandblockEditor suggestionMenu focusOnOpen: true.
	aBlock updateSuggestions
]

{ #category : #'as yet unclassified' }
DCQueryState >> ensureReplacement: aClass for: aBlock embed: aClosure initDo: anotherClosure [

	| replacement |
	replacement := (aBlock class = aClass or: [(aBlock replacedParent ifNotNil: #class) = aClass])
		ifFalse: [ | r hadFocus |
			hadFocus := (aBlock sandblockEditor ifNotNil: #textFocus)
				ifNotNil: [:t | t hasAnyParent: aBlock]
				ifNil: [false].
			r := aClass new.
			aBlock replacedParent: r.
			aBlock replaceBy: r.
			r
				source: aBlock;
				embed: aClosure.
			anotherClosure valueWithArguments: {r}, r updateEmbeds.
			hadFocus ifTrue: [r startInputAtEnd].
			r]
		ifTrue: [ | r |
			r := aBlock class = aClass ifFalse: [aBlock replacedParent] ifTrue: [aBlock].
			r updateEmbeds.
			r].
	(transientReplacements at: currentTrigger) add: replacement
]

{ #category : #'as yet unclassified' }
DCQueryState >> errors [

	^ Array streamContents: [:s | self rootBlock allBlocksDo: [:b | b withDecorator: SBErrorDecorator do: [:d | s nextPut: d] ifAbsent: []]]
]

{ #category : #'as yet unclassified' }
DCQueryState >> errorsDo: aBlock [

	self rootBlock allBlocksDo: [:b | b withDecorator: SBErrorDecorator do: [:d | aBlock value: d] ifAbsent: []]
]

{ #category : #'as yet unclassified' }
DCQueryState >> highlight: aBlock [

	(newDecorators at: aBlock ifAbsentPut: [OrderedCollection new]) add: SBHighlightDecorator new
]

{ #category : #'as yet unclassified' }
DCQueryState >> initialize [

	super initialize.
	
	currentDecorators := Dictionary new.
	transientReplacements := Dictionary new.
	self triggers do: [:t |
		currentDecorators at: t put: WeakKeyDictionary new.
		transientReplacements at: t put: WeakSet new].
	updateQueued := Dictionary new
]

{ #category : #shortcuts }
DCQueryState >> performShortcut: aSymbol for: aBlock [

	[
		currentShortcut := aSymbol.
		self queriesFor: #shortcut do: [:script |
			DCQuery script: script with: aBlock.
			currentShortcut ifNil: [^ true]]] ensure: [currentShortcut := nil].
	^ false
]

{ #category : #'as yet unclassified' }
DCQueryState >> queriesFor: aSymbol do: aBlock [

	querySourceOverride ifNotNil: [^ querySourceOverride value: aSymbol value: aBlock].
	
	Pragma withPragmasIn: DCBlock class do: [:pragma |
		(pragma keyword = #query: and: [
			pragma arguments first isSymbol
				ifTrue: [pragma arguments first = aSymbol]
				ifFalse: [pragma arguments first includes: aSymbol]]) ifTrue: [aBlock value: (DCBlock perform: pragma selector)]]
]

{ #category : #'as yet unclassified' }
DCQueryState >> querySourceOverride: aBlock [

	querySourceOverride := aBlock
]

{ #category : #'as yet unclassified' }
DCQueryState >> queueUpdateQueriesFor: aSymbol [

	(updateQueued at: aSymbol ifAbsent: [false]) ifTrue: [^ self].
	updateQueued at: aSymbol put: true.
	rootBlock world addAlarm: #updateQueriesFor: withArguments: {aSymbol} for: self at: Time millisecondClockValue
]

{ #category : #'as yet unclassified' }
DCQueryState >> reportError: aDecorator for: aBlock [

	(newDecorators at: aBlock ifAbsentPut: [OrderedCollection new]) add: aDecorator
]

{ #category : #'as yet unclassified' }
DCQueryState >> rerunQueriesFor: aSymbol do: aBlock [

	self assert: currentTrigger isNil.
	currentTrigger := aSymbol.
	
	[self updateTransientReplacementsDuring: [self updateDecoratorsDuring: [aBlock value]]] ensure: [currentTrigger := nil]
]

{ #category : #accessing }
DCQueryState >> rootBlock [

	^ rootBlock
]

{ #category : #accessing }
DCQueryState >> rootBlock: aBlock [

	rootBlock := aBlock
]

{ #category : #'as yet unclassified' }
DCQueryState >> suggestionsFor: aBlock [

	^ suggestions key = aBlock ifTrue: [suggestions value] ifFalse: [{}]
]

{ #category : #'as yet unclassified' }
DCQueryState >> triggers [

	^ #(#shortcut #change #type #selection #doubleClick #open #always #save)
]

{ #category : #shortcuts }
DCQueryState >> tryShortcut: aSymbol do: aBlock [

	currentShortcut = aSymbol ifTrue: [
		DCQuery script: aBlock value with: self rootBlock sandblockEditor selection.
		currentShortcut := nil]
]

{ #category : #'as yet unclassified' }
DCQueryState >> updateChangeQueries [

	self queueUpdateQueriesFor: #change.
	self queueUpdateQueriesFor: #type.
	self queueUpdateQueriesFor: #always
]

{ #category : #'as yet unclassified' }
DCQueryState >> updateDecoratorsDuring: aBlock [

	| oldDecorators |
	newDecorators := WeakKeyDictionary new.
	
	aBlock value.
	
	oldDecorators := currentDecorators at: currentTrigger.
	oldDecorators do: [:list | list do: [:d | d detach]].
	newDecorators keysAndValuesDo: [:block :list | list do: [:d | block attachDecorator: d]].
	currentDecorators at: currentTrigger put: newDecorators
]

{ #category : #'as yet unclassified' }
DCQueryState >> updateQueriesFor: aSymbol [

	updateQueued at: aSymbol put: false.
	self rerunQueriesFor: aSymbol do: [
		self
			queriesFor: aSymbol
			do: [:script | self rootBlock allChildrenDo: [:b | b isSandblock ifTrue: [DCQuery script: script with: b]]]]
]

{ #category : #'as yet unclassified' }
DCQueryState >> updateQueriesFor: aSymbol at: aBlock [

	self
		rerunQueriesFor: aSymbol
		do: [self queriesFor: aSymbol do: [:script | DCQuery script: script with: aBlock]]
]

{ #category : #'as yet unclassified' }
DCQueryState >> updateSelectionQueries [

	self queueUpdateQueriesFor: #selection
]

{ #category : #'as yet unclassified' }
DCQueryState >> updateTransientReplacementsDuring: aBlock [

	| old new |
	old := transientReplacements at: currentTrigger.
	new := WeakSet new.
	transientReplacements at: currentTrigger put: new.
	aBlock value.
	old do: [:r | (new includes: r) ifFalse: [r passiveUninstall]]
]

{ #category : #'as yet unclassified' }
DCQueryState >> updateTypeQueries [

	suggestions := nil.
	self queueUpdateQueriesFor: #type.
	self queueUpdateQueriesFor: #always
]
