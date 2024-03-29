Class {
	#name : #SBTSUnknown,
	#superclass : #SBUnknown,
	#instVars : [
		'type',
		'factory',
		'template'
	],
	#category : #'Sandblocks-TreeSitter'
}

{ #category : #'as yet unclassified' }
SBTSUnknown >> buildCopy [

	^ self class new
		type: self type factory: self factory;
		template: self template;
		hint: self hint;
		yourself
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> childOrNil [

	^ nil
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> childrenForQueryDo: aBlock [

	
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> contents: aString [

	self currentTextMorph contents: aString
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> copyBlock [

	^ self buildCopy
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> cursorPositionsDo: aBlock shallow: aBoolean [

	aBlock value: (SBCursorSelect new block: self).
	self startInputCommand ifNotNil: [:command |
		aBlock value: (SBCursorText new
			block: self;
			currentCommand: command)]
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> deleteTarget [

	self owner isInlineBlock ifFalse: [^ nil].
	self owner inline ifFalse: [^ nil].
	((self owner isKindOf: SBInlineBlockRepeat) and: [self owner submorphCount > 1 or: [self owner required not]]) ifTrue: [^ self].
	^ self owner deleteTarget
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> factory [

	^ factory ifNil: [self owner isInlineBlock ifTrue: [self owner factory] ifFalse: [nil]]
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> factory: aFactory [

	factory := aFactory
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> firstDifferingBlocksWith: aMorph do: aBlock [

	(self template value hasSameStructureAs: aMorph template value) ifFalse: [^ aBlock value: self value: aMorph].
	^ nil
]

{ #category : #accessing }
SBTSUnknown >> firstVisibleType [

	^ nil
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> grammarHandler [

	^ self factory ifNotNil: #grammarHandler
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> hasSameContentsAs: aBlock [

	^ aBlock class = self class and: [aBlock template value hasSameStructureAs: self template value]
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> hasSameStructureAs: aBlock [

	^ aBlock class = self class and: [self type = aBlock type]
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> hint [

	^ self currentTextMorph placeholderText
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> hint: aString [

	self currentTextMorph placeholderText: aString
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> inline [

	^ false
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> instantiate [

	^ self
]

{ #category : #testing }
SBTSUnknown >> isBuilt [

	^ true
]

{ #category : #testing }
SBTSUnknown >> isTSLabel [

	^ false
]

{ #category : #testing }
SBTSUnknown >> isTSNode [

	^ false
]

{ #category : #testing }
SBTSUnknown >> isTSRepeat [

	^ false
]

{ #category : #testing }
SBTSUnknown >> isTSSeq [

	^ false
]

{ #category : #testing }
SBTSUnknown >> isTSSymbol [

	^ false
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> isTemplate [

	^ false
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> keyStroke: anEvent [

	self currentTextMorph keyStroke: anEvent.
	self tryInterpretInput: self contents
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> language [

	^ self factory ifNotNil: [:f | f class language]
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> lengthOfLeftMostPath [

	^ 1
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> newNullBlock [

	^ SBTSUnknown new
		template: self template value buildCopy;
		grammarHandler: self grammarHandler
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> numAlternativesIn: anOption [

	^ 1
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> printOn: aStream [

	aStream nextPutAll: 'unknown '.
	template value printTitleOn: aStream
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> suggestAlways [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> suggestions [

	| t |
	t := self template value.
	^ ((t isKindOf: SBInlineBlockChoice) and: [t alternatives allSatisfy: [:alt | alt isKindOf: SBInlineBlockLabel]])
		ifTrue: [t alternatives collect: [:alt | SBSuggestionItem selector: alt contents label: (self hint ifNil: [''])]]
		ifFalse: [#()]
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> takeStreamFrom: anOption [

	^ false
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> template [

	^ template
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> template: aBlock [

	self hint ifEmpty: [self hint: aBlock value hint].
	template := aBlock
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> tryInterpretInput: aString [

	SBTSBlockChooseDialog new
		do: [:query |
			SBTSRuleExplore new
				explore: template value withNested: nil nestedBefore: false for: query startSymbol: type;
				deduplicate]
		query: aString
		onSuccess: [:selected | | replacer |
			replacer := selected.
			self sandblockEditor do: (SBReplaceCommand new
				target: self;
				replacer: replacer).
			SBToggledCode comment: '' active: 1 do: {
				[(replacer firstBlock ifNil: [replacer containingSandblock]) startInputAtEnd].
				[
					(replacer firstBlock ifNil: [replacer containingSandblock]) select.
					3 timesRepeat: [replacer sandblockEditor performForSelection: #moveCursorSmaller]].
				[
					(replacer startInputCommand
						ifNotNil: [replacer]
						ifNil: [replacer nextBlockThat: [:m | m startInputCommand notNil]])
						ifNotNil: [:m | ((m hasOwner: replacer) or: [m = replacer]) ifTrue: [replacer sandblockEditor startInput: m at: 900000000 replacingContents: false]]
						ifNil: [replacer firstBlock ifNotNil: #select]]}]
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> type [

	^ type
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> type: aString factory: aFactory [

	type := aString.
	factory := aFactory
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> unbuiltChildrenIn: anOption [

	^ #()
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> useSuggestion: anItem [

	self tryInterpretInput: anItem contents
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> valid [

	^ self isStatement and: [self contents isEmpty]
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> veryDeepCopyWith: deepCopier [

	| f copy t |
	f := factory.
	t := template.
	factory := nil.
	template := nil.
	copy := super veryDeepCopyWith: deepCopier.
	factory := f.
	template := t.
	copy factory: f.
	copy template: t.
	^ copy
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> writeMetaSourceOn: aStream [

	aStream nextPutAll: ' '
]

{ #category : #'as yet unclassified' }
SBTSUnknown >> writeSourceOn: aStream indent: aNumber [

	
]
