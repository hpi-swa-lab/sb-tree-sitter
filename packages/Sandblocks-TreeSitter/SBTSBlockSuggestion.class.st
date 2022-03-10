Class {
	#name : #SBTSBlockSuggestion,
	#superclass : #SBSuggestionItem,
	#instVars : [
		'block',
		'target'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSBlockSuggestion >> block: aBlock in: anEditor [

	self selector: aBlock printString label: 'block'.
	self
		preview: (aBlock
			width: 400;
			wrapOffscreen: anEditor;
			imageForm)
		previewOnly: false.
	block := aBlock
]

{ #category : #'as yet unclassified' }
SBTSBlockSuggestion >> target: aBlock [

	target := aBlock
]

{ #category : #'as yet unclassified' }
SBTSBlockSuggestion >> useSuggestionOn: aBlock in: anEditor [

	| nested found |
	target := target ifNil: [aBlock].
	anEditor do: (SBReplaceCommand new target: target replacer: block).
	nested := nil.
	found := false.
	block allMorphsDo: [:m | (nested isNil and: [m type = target type]) ifTrue: [nested := m]].
	block cursorPositionsDo: [:position |
		(found and: [position block ~= nested and: [position isInsert or: [position isText]]]) ifTrue: [^ anEditor cursor cursorPosition: (position placeAtEnd: true) explicitMove: false axis: #none].
		position block = nested ifTrue: [found := true]].
	"didn't find the nested block again, choose the very first"
	^ block cursorPositionsDo: [:position | ((position isInsert and: [(position command element hasParentThat: #isTSOptional) not]) or: [position isText]) ifTrue: [^ anEditor cursor cursorPosition: (position placeAtEnd: true) explicitMove: false axis: #none]]
]
