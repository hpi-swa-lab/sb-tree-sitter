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
SBTSNodeInsertCommand >> adjacent [

	^ self container submorphs atPin: self insertIndex
]

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

	morphs := morphs
		ifNil: [element buildEmpty].
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
SBTSNodeInsertCommand >> firstTextMorphIn: aCollection [

	aCollection do: [:morph | morph isTextMorph ifTrue: [^morph] ifFalse: [morph allBlocksDo: [:m | m currentTextMorph ifNotNil: [^ m]]]].
	^ nil
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
SBTSNodeInsertCommand >> isJumpPoint [

	^ element parent multiple and: [(element parent groupsIn: self container) isEmpty]
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> isStatementInsert [

	^ element parent isStatementRepeater
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
				for: (self firstTextMorphIn: morphs)
				input: continueInputString
				at: SBTSInputReconcile endIndex]
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

	^ self element language showInsertHints
		ifTrue: ['insert ' asText, (Text streamContents: [:s | element labelPrintOn: s])]
		ifFalse: [nil]
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> tryExpandWithInput: aString [

	| options |
	(element parent isStatementRepeater and: [aString = String cr]) ifTrue: [
		element alternatives
			detect: [:alt | alt type = #empty]
			ifFound: [:alt | self morphs: alt buildEmpty].
		^ true].
	(aString = String tab or: [aString = String cr]) ifTrue: [^ false].
	
	options := SBTSInputParser new
		siblings: self container submorphs;
		optionsForTemplate: element given: aString.
	
	options size = 1 ifTrue: [morphs := options first].
	options size > 1 ifTrue: [continueInputString := aString].
	
	"if we cannot match anything here, look to the right of us to see if there is a position that could take the input"
	options isEmpty ifTrue: [
		true ifTrue: [
			self container hasSubmorphs ifTrue: [
			SBTSInputReconcile new
				for: self adjacent input: aString at: SBTSInputReconcile endIndex.
				^ SBDoItCommand new]].
		(self container sandblockEditor cursor cursorPosition
			moveHorizontal: 1
			wordWise: false) ifNotNil: [:newPos |
			"newPos isText ifTrue: [
				SBTSInputReconcile new for: newPos textMorph input: aString at: (newPos textMorph contentsForEdit
					ifEmpty: [SBTSInputReconcile endIndex]
					ifNotEmpty: [1]).
				^ newPos command]."
			newPos isInsert ifTrue: [
				SBTSInputReconcile new
					for: self container input: aString at: SBTSInputReconcile endIndex;
					findOptionsBlock: [:reconcile :string | reconcile optionsForInsert: newPos given: string].
				^ newPos command]]].
	
	^ options notEmpty
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> undo [

	morphs do: #delete.
	^ container
]
