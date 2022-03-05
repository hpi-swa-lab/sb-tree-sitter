Class {
	#name : #SBTSNodeInsertCommand,
	#superclass : #SBCommand,
	#instVars : [
		'container',
		'element',
		'morphs',
		'index'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> canInsert: aBlock do: aClosure [

	^ (SBTSRuleExplore new
		explore: element withNested: aBlock nestedBefore: false for: '' startSymbol: nil;
		deduplicate)
		ifNotEmpty: [:choices | aClosure value: choices first]
		ifEmpty: [false]
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> container [

	^ container
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> continueAfterInsert: aCharacter [

	^ morphs
		detect: [:m | m isTSBlock]
		ifFound: [:m | (m sourceString includes: aCharacter) not]
		ifNone: [false]
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
SBTSNodeInsertCommand >> setArtefactFrom [

	^ container
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> suggestions [

	^ element factory suggestionsForInsert: self
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> title [

	^ 'insert ', element printString
]

{ #category : #'as yet unclassified' }
SBTSNodeInsertCommand >> undo [

	morphs do: #delete.
	^ container
]