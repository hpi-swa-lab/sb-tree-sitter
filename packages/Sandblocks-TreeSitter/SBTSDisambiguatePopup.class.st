Class {
	#name : #SBTSDisambiguatePopup,
	#superclass : #SBPopup,
	#instVars : [
		'target',
		'transitionsDo',
		'choices'
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
		(found and: [position block ~= nested and: [position isInsert or: [position isText]]]) ifTrue: [^ editor cursor cursorPosition: (position placeAtEnd: true) explicitMove: false axis: #none].
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
SBTSDisambiguatePopup >> for: aBlock input: aString transitionsDo: aClosure [

	target := aBlock.
	transitionsDo := aClosure.
	choices := transitionsDo value: aString.
	choices size = 1 ifTrue: [^ self applyChoice: choices first].
	
	self contents: aString.
	
	self showBelow: aBlock closeOnDeselect: true.
	self moveCursorToEnd.
	self queueUpdateSuggestionsFocused: true
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> initialize [

	super initialize.
	
	self addMorphBack: (SBOwnTextMorph new when: #contentsChanged send: #updateChoices to: self)
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
		choices := transitionsDo value: self contents.
		choices size = 1 ifTrue: [^ self applyChoice: choices first]]
]
