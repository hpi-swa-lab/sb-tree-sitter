Class {
	#name : #DCPriorityTreeQueue,
	#superclass : #Object,
	#instVars : [
		'collection',
		'minimumHeight'
	],
	#category : #'DomainCode-Diff'
}

{ #category : #'as yet unclassified' }
DCPriorityTreeQueue >> add: tree [

	tree treeHeight >= self minimumHeight ifTrue: [collection add: tree]
]

{ #category : #'as yet unclassified' }
DCPriorityTreeQueue >> addAll: aCollection [

	aCollection do: [:tree | self add: tree]
]

{ #category : #'as yet unclassified' }
DCPriorityTreeQueue >> addTree: tree [

	tree submorphs do: [:child | self add: child]
]

{ #category : #'as yet unclassified' }
DCPriorityTreeQueue >> first [

	^ collection first
]

{ #category : #'as yet unclassified' }
DCPriorityTreeQueue >> initialize [

	super initialize.
	
	collection := SortedCollection sortBlock: [:a :b | a treeHeight > b treeHeight]
]

{ #category : #'as yet unclassified' }
DCPriorityTreeQueue >> isEmpty [

	^ collection isEmpty
]

{ #category : #'as yet unclassified' }
DCPriorityTreeQueue >> minimumHeight [

	^ minimumHeight ifNil: [0]
]

{ #category : #'as yet unclassified' }
DCPriorityTreeQueue >> minimumHeight: aNumber [

	minimumHeight := aNumber
]

{ #category : #'as yet unclassified' }
DCPriorityTreeQueue >> notEmpty [

	^ collection notEmpty
]

{ #category : #'as yet unclassified' }
DCPriorityTreeQueue >> removeAll [

	collection removeAll
]

{ #category : #'as yet unclassified' }
DCPriorityTreeQueue >> removeFirst [

	^ collection removeFirst
]

{ #category : #'as yet unclassified' }
DCPriorityTreeQueue >> removeHighest [

	^ Array streamContents: [:stream | | tree |
		tree := self removeFirst.
		stream nextPut: tree.
		[self notEmpty and: [tree treeHeight = self first treeHeight]] whileTrue: [
			tree := self removeFirst.
			stream nextPut: tree]]
]

{ #category : #'as yet unclassified' }
DCPriorityTreeQueue >> removeHighestAndOpen [

	^ self removeHighest
		do: [:tree | self addTree: tree];
		yourself
]

{ #category : #'as yet unclassified' }
DCPriorityTreeQueue >> synchronizePriorityWith: anotherQueue do: aBlock [

	[(self notEmpty and: [anotherQueue notEmpty]) and: [self first treeHeight ~= anotherQueue first treeHeight]] whileTrue: [
		self first treeHeight > anotherQueue first treeHeight
			ifTrue: [self removeFirst]
			ifFalse: [anotherQueue removeFirst]].
	
	(self isEmpty or: [anotherQueue isEmpty]) ifTrue: [
		self removeAll.
		anotherQueue removeAll.
		^ false].
	^ true
]
