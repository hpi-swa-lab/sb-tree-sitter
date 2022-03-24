Class {
	#name : #SBTSDisambiguatePopup,
	#superclass : #SBPopup,
	#instVars : [
		'target',
		'choices',
		'before'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> applyChoice: aCollectionOfBlocks [

	self dismiss.
	target sandblockEditor do: (SBReplaceMultipleCommand new target: target replacers: aCollectionOfBlocks).
	self positionCursorFor: aCollectionOfBlocks first.
	
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
	target
		select;
		moveCursorToEnd
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> for: aBlock input: aString before: aBoolean [

	target := aBlock.
	before := aBoolean.
	
	target currentTextMorph ifNotNil: [:t | t slot firstNode isTSLabel ifTrue: [^ self tryReinterpretWith: aString from: target currentTextMorph]].
	
	aString
		ifNotEmpty: [
			choices := aBlock tryTransitionAfterInput: aString before: aBoolean.
			choices size = 1 ifTrue: [^ self applyChoice: choices first].
			choices size = 0 ifTrue: [
				^ (self forwardInputToAdjacent: aString) ifTrue: [true] ifFalse: [
					target currentTextMorph
						ifNotNil: [self tryReinterpretWith: aString from: target]
						ifNil: [false]]]]
		ifEmpty: [choices := #()].
	
	self contents: aString.
	
	self showBelow: aBlock closeOnDeselect: true.
	self moveCursorToEnd.
	self queueUpdateSuggestionsFocused: true.
	^ true
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> forwardInputToAdjacent: aString [

	self positionAfterDo: [:position |
		(position isText or: [position isSelect]) ifTrue: [
			(position block tryApplyChange: [:block | block contents: aString] input: aString) ifTrue: [
				(position isText and: [position block sandblockEditor notNil]) ifTrue: [position block startInputAtEnd].
				^ true]].
		position isInsert ifTrue: [
			(position command tryExpandWithInput: aString) ifTrue: [
				target sandblockEditor do: position command.
				^ true]]].
	^ false
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
	(target containingArtefact ifNil: [target containingFloat]) cursorPositionsDo: [:position |
		(foundSelf and: [position isInsert or: [position isText and: [position block wantsInput]]]) ifTrue: [aBlock value: position].
		(position isText and: [position block = target]) ifTrue: [foundSelf := true]]
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> positionCursorFor: aBlock [

	| editor found nested |
	nested := nil.
	found := false.
	editor := aBlock sandblockEditor.
	aBlock allMorphsDo: [:m | (nested isNil and: [m isTSBlock and: [m sourceString = target sourceString]]) ifTrue: [nested := m]].
	
	aBlock cursorPositionsDo: [:position |
		(found and: [(position block ~= nested and: [(position block hasOwner: nested) not]) and: [position isInsert or: [position isText]]]) ifTrue: [^ editor cursor cursorPosition: (position placeAtEnd: true) explicitMove: false axis: #none].
		position block = nested ifTrue: [found := true]].
	
	"didn't find the nested block again, choose the very first"
	aBlock cursorPositionsDo: [:position | ((position isInsert and: [(position command element hasParentThat: #isTSOptional) not]) or: [position isText]) ifTrue: [^ editor cursor cursorPosition: (position placeAtEnd: true) explicitMove: false axis: #none]]
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> suggestAlways [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> suggestions [

	^ choices collect: [:choice |
		SBTSBlockSuggestion new
			blocks: choice in: target sandblockEditor;
			target: target]
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> tryReinterpretWith: aString from: aMorph [

	| input myIndex choices |
	input := aMorph contents, aString.
	myIndex := aMorph submorphIndex.
	choices := SBTSInputParser new
		optionsFor: aMorph owner
		given: input
		before: ((aMorph owner submorphs first: myIndex - 1) select: #keepDuringTransform)
		after: ((aMorph owner submorphs allButFirst: myIndex) select: #keepDuringTransform).
	^ choices
		ifNotEmpty: [
			"multiple choices"
			self flag: #todo.
			target sandblockEditor do: (SBReplaceMultipleCommand new target: aMorph owner replacers: choices first).
			self positionCursorFor: (choices first last submorphs at: myIndex).
			true]
		ifEmpty: [false]
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> updateChoices [

	self contents ifEmpty: [self dismiss] ifNotEmpty: [
		choices := target tryTransitionAfterInput: self contents before: before.
		choices size = 1 ifTrue: [^ self applyChoice: choices first]]
]
