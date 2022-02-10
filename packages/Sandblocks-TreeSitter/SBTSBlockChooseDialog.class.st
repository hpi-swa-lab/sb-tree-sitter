Class {
	#name : #SBTSBlockChooseDialog,
	#superclass : #DialogWindow,
	#instVars : [
		'query',
		'currentBlocks',
		'currentValues',
		'exploreBlock',
		'successBlock'
	],
	#category : #'Sandblocks-TreeSitter'
}

{ #category : #'as yet unclassified' }
SBTSBlockChooseDialog >> do: aBlock query: aString onSuccess: anotherBlock [

	query := aString.
	exploreBlock := aBlock.
	successBlock := anotherBlock.
	self update.
	
	currentValues ifEmpty: [^ nil].
	^ currentValues size = 1 ifTrue: [currentValues first] ifFalse: [
		(ProvideAnswerNotification signal: nil) ifNotNil: [:answer |
			(answer = #cancel or: [answer isNil]) ifTrue: [^ nil].
			^ currentValues at: answer].
		self getUserResponseAtHand.
		"we had an odd race condition where an event would be dispatched to the editor while the popup was still open. the successBlock was the hotfix for that, if it has already been used then it's set to nil."
		successBlock ifNotNil: [successBlock value: result]]
]

{ #category : #'as yet unclassified' }
SBTSBlockChooseDialog >> keyStroke: anEvent [

	({
		Character cr.
		Character escape.
		Character arrowDown.
		Character arrowLeft.
		Character arrowUp.
		Character arrowRight.
		Character tab} includes: anEvent keyCharacter) ifTrue: [^ super keyStroke: anEvent].
	
	anEvent keyCharacter = Character backspace
		ifTrue: [query := query allButLast]
		ifFalse: [query := query, anEvent keyCharacter].
	
	query ifEmpty: [^ self delete].
	
	self update
]

{ #category : #'as yet unclassified' }
SBTSBlockChooseDialog >> update [

	currentBlocks := exploreBlock value: query.
	currentValues := currentBlocks.
	
	currentValues size = 1
		ifTrue: [
			successBlock value: currentValues first.
			successBlock := nil.
			self closeDialog: currentValues first]
		ifFalse: [self updateBlocks]
]

{ #category : #'as yet unclassified' }
SBTSBlockChooseDialog >> updateBlocks [

	buttonRow removeAllMorphs.
	currentValues with: currentBlocks do: [:block :value |
		self
			createButton: (block
				fullBounds;
				yourself)
			value: value].
	currentValues ifNotEmpty: [
		self selectedButtonIndex: 1.
		self preferredPosition: self selectedButton.
		self moveToPreferredPosition]
]
