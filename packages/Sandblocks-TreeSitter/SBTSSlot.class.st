Class {
	#name : #SBTSSlot,
	#superclass : #Object,
	#instVars : [
		'nodes'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSSlot >> addNode: aNode [

	self assert: (aNode isKindOf: SBTSNodeBase).
	nodes add: aNode
]

{ #category : #'as yet unclassified' }
SBTSSlot >> allChildrenDo: aBlock [

	nodes reverseDo: [:node | node root allChildrenDo: aBlock]
]

{ #category : #'as yet unclassified' }
SBTSSlot >> allSuperTypesDo: aBlock [

	nodes do: [:node | node allSuperTypesDo: aBlock]
]

{ #category : #'as yet unclassified' }
SBTSSlot >> buildMorphWith: anObject [

	| morph |
	morph := nodes last buildMorphWith: anObject slot: self.
	^ morph
]

{ #category : #'as yet unclassified' }
SBTSSlot >> compatibleWithType: aTypeString [

	self allSuperTypesDo: [:type | type type = aTypeString ifTrue: [^ true]].
	^ false
]

{ #category : #'as yet unclassified' }
SBTSSlot >> delimiterBetween: aBlock and: anotherBlock [

	self factory delimitedRules
		at: self firstNode type
		ifPresent: [:delimiter | self firstNode bodyTemplate allChildrenDo: [:node | (node isTSRepeat and: [(aBlock slot lastNode hasParent: node element) and: [anotherBlock slot lastNode hasParent: node element]]) ifTrue: [^ delimiter first]]].
	^ ''
]

{ #category : #'as yet unclassified' }
SBTSSlot >> delimiterIn: aBlock [

	(self factory delimitedRules at: aBlock type) ifNotNil: [:delimiter | aBlock slot firstNode bodyTemplate allChildrenDo: [:node | (node isTSRepeat and: [self lastNode hasParent: node element]) ifTrue: [^ delimiter first]]].
	^ ''
]

{ #category : #'as yet unclassified' }
SBTSSlot >> factory [

	^ self lastNode factory
]

{ #category : #'as yet unclassified' }
SBTSSlot >> field [

	self allSuperTypesDo: [:type | type field ifNotNil: [:field | ^ field]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSSlot >> firstNode [

	^ nodes first
]

{ #category : #'as yet unclassified' }
SBTSSlot >> includesParent: aNode [

	^ self includesParentThat: [:p | p = aNode]
]

{ #category : #'as yet unclassified' }
SBTSSlot >> includesParentThat: aBlock [

	nodes do: [:node | node andParentsDo: [:parent | (aBlock value: parent) ifTrue: [^ true]]].
	^ false
]

{ #category : #'as yet unclassified' }
SBTSSlot >> includesRepeat [

	^ self includesParentThat: [:p | p isTSRepeat]
]

{ #category : #'as yet unclassified' }
SBTSSlot >> initialize [

	nodes := OrderedCollection new: 1
]

{ #category : #'as yet unclassified' }
SBTSSlot >> lastNode [

	^ nodes last
]

{ #category : #'as yet unclassified' }
SBTSSlot >> mergeWith: aSlot [

	nodes addAll: aSlot nodes
]

{ #category : #'as yet unclassified' }
SBTSSlot >> nodes [

	^ nodes
]

{ #category : #'as yet unclassified' }
SBTSSlot >> parentThat: aBlock [

	nodes do: [:node | node andParentsDo: [:parent | (aBlock value: parent) ifTrue: [^ parent]]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSSlot >> postCopy [

	nodes := nodes copy
]

{ #category : #'as yet unclassified' }
SBTSSlot >> printOn: aStream [

	aStream nextPutAll: self className.
	aStream nextPut: $(.
	nodes do: [:node | node printOn: aStream] separatedBy: [aStream nextPut: $,].
	aStream nextPut: $)
]

{ #category : #'as yet unclassified' }
SBTSSlot >> repeater [

	^ self parentThat: [:p | p isTSRepeat]
]

{ #category : #'as yet unclassified' }
SBTSSlot >> replaceLast: aNode [

	nodes removeLast.
	nodes add: aNode
]

{ #category : #'as yet unclassified' }
SBTSSlot >> separatorBetween: aBlock and: anotherBlock indent: aNumber [

	(self delimiterBetween: aBlock and: anotherBlock) ifNotEmpty: [:delimiter | ^ delimiter].
	(self factory hardLineBreakBetween: aBlock and: anotherBlock) ifTrue: [
		^ String streamContents: [:s |
			s cr.
			aNumber timesRepeat: [s tab]]].
	((aBlock sourceString ifNotEmpty: [:s | s last isAlphaNumeric] ifEmpty: [false]) and: [
		anotherBlock sourceString
			ifNotEmpty: [:s | s first isAlphaNumeric]
			ifEmpty: [false]]) ifTrue: [^ ' '].
	^ ''
]

{ #category : #'as yet unclassified' }
SBTSSlot >> type [

	^ self firstNode type
]

{ #category : #'as yet unclassified' }
SBTSSlot >> writeSourceOn: aStream with: aCollection [

	nodes last
]
