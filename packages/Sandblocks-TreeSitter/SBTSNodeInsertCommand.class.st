Class {
	#name : #SBTSNodeInsertCommand,
	#superclass : #SBCommand,
	#instVars : [
		'container',
		'element',
		'morphs',
		'index',
		'continueInputString'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> container [

	^ container
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> continueAfterInsert: aCharacter [

	^ false
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> do [

	morphs := morphs ifNil: [element buildEmpty].
	morphs reverseDo: [:m | container addMorph: m asElementNumber: index].
	^ morphs detect: [:m | m isSandblock] ifFound: [:m | m] ifNone: [container]
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> element [

	^ element
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> element: aNode container: aBlock index: aNumber [

	element := aNode.
	container := aBlock.
	index := aNumber
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> hasSamePositionAs: aCommand [

	^ aCommand class ~= SBCombinedCommand and: [self container = aCommand container and: [self insertIndex = aCommand insertIndex and: [element = aCommand element]]]
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> index [

	^ index
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> insertIndex [

	^ self index
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> isInsert [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> morph [

	^ morphs first
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> morph: aMorph [

	morphs := {aMorph}
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> morphs [

	^ morphs
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> morphs: aCollection [

	morphs := aCollection
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> postDo [

	continueInputString
		ifNotNil: [
			SBTSInputReconcile new
				for: morphs first currentTextMorph
				input: continueInputString
				before: false]
		ifNil: [SBTSInputReconcile new positionCursorIn: morphs]
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> setArtefactFrom [

	^ container
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> suggestions [

	^ element language suggestionsForInsert: self
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> title [

	^ 'insert ', element printString
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> tryExpandWithInput: aString [

	| options |
	options := SBTSInputParser new optionsForTemplate: element given: aString.
	options size = 1 ifTrue: [morphs := options first].
	options size > 1 ifTrue: [continueInputString := aString].
	
	SBToggledCode comment: '' active: 0 do: {
		[
			(options isEmpty and: [
				self container submorphs
					at: self insertIndex
					ifPresent: [:c | true]
					ifAbsent: [false]]) ifTrue: [ | next |
				"try and forward the input"
				next := self container submorphs at: self insertIndex.
				"FIXME: string morphs confuse our positionAfterDo: code, we should instead always work with cursorpositions"
				next isStringMorph ifFalse: [SBTSDisambiguatePopup new for: next input: aString before: false].
				^ false]]}.
	
	^ options notEmpty
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> undo [

	morphs do: #delete.
	^ container
]
