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
SBTSDisambiguatePopup >> applyChoice: aBlock [

	| editor nested found |
	self dismiss.
	
	editor := target sandblockEditor.
	editor do: (SBReplaceCommand new target: target replacer: aBlock).
	
	nested := nil.
	found := false.
	aBlock allMorphsDo: [:m | (nested isNil and: [m type = target type]) ifTrue: [nested := m]].
	
	aBlock cursorPositionsDo: [:position |
		(found and: [(position block ~= nested and: [(position block hasOwner: nested) not]) and: [position isInsert or: [position isText]]]) ifTrue: [^ editor cursor cursorPosition: (position placeAtEnd: true) explicitMove: false axis: #none].
		position block = nested ifTrue: [found := true]].
	
	"didn't find the nested block again, choose the very first"
	aBlock cursorPositionsDo: [:position | ((position isInsert and: [(position command element hasParentThat: #isTSOptional) not]) or: [position isText]) ifTrue: [^ editor cursor cursorPosition: (position placeAtEnd: true) explicitMove: false axis: #none]]
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
	aString
		ifNotEmpty: [
			choices := aBlock tryTransitionAfterInput: aString before: aBoolean.
			choices size = 1 ifTrue: [^ self applyChoice: choices first].
			choices size = 0 ifTrue: [^ self forwardInputToAdjacent: aString]]
		ifEmpty: [choices := #()].
	
	self contents: aString.
	
	self showBelow: aBlock closeOnDeselect: true.
	self moveCursorToEnd.
	self queueUpdateSuggestionsFocused: true
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> forwardInputToAdjacent: aString [

	self positionAfterDo: [:position |
		position isText ifTrue: [^ self class new for: position block input: aString before: false].
		position isInsert ifTrue: [
			(position command tryExpandWithInput: aString) ifTrue: [
				target sandblockEditor do: position command.
				^ self]]]
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
	(target containingArtefact ifNil: [target containingFloat]) cursorPositionsDo: [:position |
		(foundSelf and: [position isInsert or: [position isText and: [position block isUnknown]]]) ifTrue: [aBlock value: position].
		(position isText and: [position block = target]) ifTrue: [foundSelf := true]]
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> suggestAlways [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> suggestions [

	^ choices collect: [:choice |
		SBTSBlockSuggestion new
			block: choice in: target sandblockEditor;
			target: target]
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> updateChoices [

	self contents ifEmpty: [self dismiss] ifNotEmpty: [
		choices := target tryTransitionAfterInput: self contents before: before.
		choices size = 1 ifTrue: [^ self applyChoice: choices first]]
]
