Class {
	#name : #SBTSBlockSuggestion,
	#superclass : #SBSuggestionItem,
	#instVars : [
		'blocks',
		'target'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSBlockSuggestion >> blocks: aCollection in: anEditor [

	self selector: aCollection first printString label: 'block'.
	self
		preview: (anEditor newSelectionContainer
			addAllMorphs: aCollection;
			width: 400;
			imageForm)
		previewOnly: false.
	blocks := aCollection
]

{ #category : #'as yet unclassified' }
SBTSBlockSuggestion >> target: aBlock [

	target := aBlock
]

{ #category : #'as yet unclassified' }
SBTSBlockSuggestion >> useSuggestionOn: aBlock in: anEditor [

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
