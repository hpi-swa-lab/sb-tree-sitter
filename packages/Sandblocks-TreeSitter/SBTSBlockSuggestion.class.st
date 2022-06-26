Class {
	#name : #SBTSBlockSuggestion,
	#superclass : #SBSuggestionItem,
	#instVars : [
		'blocks',
		'target',
		'disambiguatePopup',
		'command'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSBlockSuggestion >> blocks: aCollection in: anEditor [

	self blocks: aCollection in: anEditor popup: nil
]

{ #category : #'as yet unclassified' }
SBTSBlockSuggestion >> blocks: aCommand in: anEditor popup: aPopup [

	disambiguatePopup := aPopup.
	self selector: aCommand morphs first printString label: 'block'.
	self
		preview: (anEditor newSelectionContainer
			addAllMorphs: aCommand morphs;
			width: 400;
			imageForm)
		previewOnly: false.
	command := aCommand
]

{ #category : #'as yet unclassified' }
SBTSBlockSuggestion >> oldUseSuggestionOn: aBlock in: anEditor [

	| nested found block |
	target := target ifNil: [aBlock].
	anEditor do: (SBReplaceMultipleCommand new target: target replacers: blocks).
	nested := nil.
	found := false.
	
	block := blocks first.
	block allMorphsDo: [:m | (nested isNil and: [m type = target type]) ifTrue: [nested := m]].
	block cursorPositionsDo: [:position |
		(found and: [position block ~= nested and: [position isInsert or: [position isText]]]) ifTrue: [^ anEditor cursor cursorPosition: (position placeAtEnd: true) explicitMove: false axis: #none].
		position block = nested ifTrue: [found := true]].
	"didn't find the nested block again, choose the very first"
	^ block cursorPositionsDo: [:position | ((position isInsert and: [(position command element hasParentThat: #isTSOptional) not]) or: [position isText]) ifTrue: [^ anEditor cursor cursorPosition: (position placeAtEnd: true) explicitMove: false axis: #none]]
]

{ #category : #'as yet unclassified' }
SBTSBlockSuggestion >> target: aBlock [

	target := aBlock
]

{ #category : #'as yet unclassified' }
SBTSBlockSuggestion >> useSuggestionOn: aBlock in: anEditor [

	disambiguatePopup
		ifNotNil: [:popup | popup applyCommand: command]
		ifNil: [anEditor do: command]
]
