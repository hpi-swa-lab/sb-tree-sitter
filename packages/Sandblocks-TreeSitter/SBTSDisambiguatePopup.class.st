Class {
	#name : #SBTSDisambiguatePopup,
	#superclass : #SBPopup,
	#instVars : [
		'target',
		'choices',
		'before',
		'source',
		'sourceString'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> applyChoice: aCollectionOfBlocks [

	self dismiss.
	target sandblockEditor do: (SBReplaceMultipleCommand new target: target replacers: aCollectionOfBlocks).
	self positionCursorIn: aCollectionOfBlocks.
	
	^ true
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> currentTextMorph [

	^ self firstSubmorph
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> dismiss [
	<action>

	self delete.
	target containingSandblock
		select;
		moveCursorToEnd
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> for: aBlock input: aString before: aBoolean [

	^ self for: aBlock input: aString before: aBoolean from: aBlock
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> for: aBlock input: aString before: aBoolean from: anotherBlock [

	target := aBlock.
	before := aBoolean.
	source := anotherBlock.
	sourceString := source sourceStringForCompare.
	self contents: aString.
	
	self tryTransition ifTrue: [^ true].
	(choices isNil or: [choices isEmpty]) ifTrue: [^ false].
	
	self showBelow: aBlock closeOnDeselect: true.
	self moveCursorToEnd.
	self queueUpdateSuggestionsFocused: true.
	^ true
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> initialize [

	super initialize.
	
	self addMorphBack: (SBOwnTextMorph new when: #contentsChanged send: #updateChoices to: self)
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> positionAfterDo: aBlock [

	| foundSelf |
	foundSelf := false.
	(target parentSandblock isTSBlock and: [target submorphAfter isNil]) ifTrue: [aBlock value: (SBCursorSelect new block: target parentSandblock)].
	target owner cursorPositionsDo: [:position |
		(foundSelf and: [position isInsert or: [position isText and: [position block wantsInput]]]) ifTrue: [aBlock value: position].
		(position isText and: [position block = target]) ifTrue: [foundSelf := true]]
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> positionCursorIn: aCollection [

	| all positionInAll stopIndex |
	all := Array streamContents: [:s | aCollection do: [:block | block allMorphsPreorderDo: [:m | s nextPut: m]]].
	stopIndex := all findFirst: [:m | m valueOfProperty: #lastConstructed ifAbsent: [false]].
	
	stopIndex > 0 ifTrue: [
		(all at: stopIndex) removeProperty: #lastConstructed.
		
		(all at: stopIndex) containingSandblock valid ifFalse: [^ (all at: stopIndex) containingSandblock startInputAtEnd].
		
		positionInAll := [:cursor |
			cursor isInsert
				ifTrue: [(all findFirst: [:m | m owner = cursor container]) + (cursor command insertIndex - 1)]
				ifFalse: [all indexOf: cursor block currentTextMorph]].
		
		aCollection do: [:block |
			block cursorPositionsDo: [:cursor |
				(((cursor isInsert and: [(cursor command element hasParentThat: [:p | p isTSRepeat and: [p required or: [p multiple not]]]) not]) or: [cursor isText]) and: [(positionInAll value: cursor) > stopIndex]) ifTrue: [
					^ block sandblockEditor cursor
						cursorPosition: (cursor placeAtEnd: true)
						explicitMove: false
						axis: #none]]]].
	
	aCollection last lastDeepChild startInputAtEnd
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> suggestAlways [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> suggestions [

	^ choices collect: [:choice |
		SBTSBlockSuggestion new
			blocks: choice in: target sandblockEditor popup: self;
			target: target]
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> tryAdjacent [

	self positionAfterDo: [:position |
		(position isText and: [position block wantsInput]) ifTrue: [
			^ SBTSDisambiguatePopup new
				for: position block
				input: self contents
				before: false
				from: source].
		position isInsert ifTrue: [
			(position command tryExpandWithInput: self contents) ifTrue: [
				target sandblockEditor do: position command.
				choices := #().
				^ true]]].
	^ false
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> tryFill [

	target isUnknown ifFalse: [^ false].
	
	choices := SBTSInputParser new
		optionsForTemplate: target slot lastNode
		given: self contents.
	^ choices notEmpty
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> tryOwner [

	target owner owner isTSBlock ifFalse: [^ false].
	
	^ SBTSDisambiguatePopup new
		for: target owner
		input: self contents
		before: before
		from: source
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> tryReinterpret [

	| myIndex directChild input |
	source contents ifNil: [^ false].
	
	directChild := source orOwnerSuchThat: [:m | m owner = target].
	directChild ifNil: [^ false].
	myIndex := directChild submorphIndex.
	
	input := before
		ifTrue: [self contents, source contents]
		ifFalse: [source contents, self contents].
	choices := SBTSInputParser new
		optionsFor: target
		given: input
		before: ((target submorphs first: myIndex - 1) select: #keepDuringTransform)
		after: ((target submorphs allButFirst: myIndex) select: #keepDuringTransform).
	
	choices ifNotEmpty: [sourceString := input].
	^ choices notEmpty
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> tryTransition [

	self tryFill ifFalse: [self tryReinterpret ifFalse: [self tryWrap ifFalse: [self tryAdjacent ifFalse: [^ self tryOwner]]]].
	choices size = 1 ifTrue: [^ self applyChoice: choices first].
	choices size = 0 ifTrue: [^ true].
	^ false
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> tryWrap [

	target isTSBlock ifFalse: [^ false].
	
	choices := SBTSInputParser new
		optionsFor: target
		given: self contents
		before: (before ifTrue: [{}] ifFalse: [{target}])
		after: (before ifTrue: [{target}] ifFalse: [{}]).
	^ choices notEmpty
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> updateChoices [

	choices ifNil: ["still initializing"
	^ self].
	
	self contents ifEmpty: [self dismiss] ifNotEmpty: [self tryTransition]
]
