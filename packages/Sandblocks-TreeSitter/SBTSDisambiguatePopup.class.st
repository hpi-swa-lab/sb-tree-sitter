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

	self dismiss.
	
	target sandblockEditor do: (SBReplaceCommand new target: target replacer: aBlock)
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
		(SBSuggestionItem selector: choice type label: 'b')
			preview: (choice
					width: 400;
					imageForm)
				previewOnly: true;
			completionAction: [:item | self applyChoice: choice]]
]

{ #category : #'as yet unclassified' }
SBTSDisambiguatePopup >> updateChoices [

	choices := transitionsDo value: self contents.
	choices size = 1 ifTrue: [^ self applyChoice: choices first]
]
