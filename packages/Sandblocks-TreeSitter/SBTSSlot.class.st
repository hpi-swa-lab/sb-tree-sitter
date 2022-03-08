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
SBTSSlot >> factory [

	^ self lastNode factory
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
SBTSSlot >> replaceLast: aNode [

	nodes removeLast.
	nodes add: aNode
]

{ #category : #'as yet unclassified' }
SBTSSlot >> type [

	^ self firstNode type
]
