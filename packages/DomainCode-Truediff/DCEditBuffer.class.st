Class {
	#name : #DCEditBuffer,
	#superclass : #Object,
	#instVars : [
		'posBuf',
		'negBuf',
		'detachListNext'
	],
	#category : #'DomainCode-Truediff'
}

{ #category : #'as yet unclassified' }
DCEditBuffer >> apply [

	negBuf do: [:b | b value].
	posBuf do: [:b | b value]
]

{ #category : #'as yet unclassified' }
DCEditBuffer >> attach: aNode to: aParentNode at: aNumber [

	self assert: aNode ~~ aParentNode.
	posBuf add: [
		aParentNode ifNotNil: [ | target |
			target := aNode replacedParent ifNil: [aNode].
			aParentNode addMorph: target asElementNumber: aNumber]].
	self logChanges: {#attach. aNode. aParentNode. aNumber}
]

{ #category : #'as yet unclassified' }
DCEditBuffer >> detach: aNode [

	negBuf add: [ | target |
		target := aNode replacedParent ifNil: [aNode].
		target delete].
	detachListNext add: {aNode parent -> aNode}.
	self logChanges: {#detach. aNode}
]

{ #category : #'as yet unclassified' }
DCEditBuffer >> initialize [

	super initialize.
	
	posBuf := OrderedCollection new.
	negBuf := OrderedCollection new.
	detachListNext := OrderedCollection new
]

{ #category : #'as yet unclassified' }
DCEditBuffer >> logChanges: aCollection [

	true ifTrue: [Transcript showln: aCollection]
]

{ #category : #'as yet unclassified' }
DCEditBuffer >> remove: aNode [

	negBuf add: ["aNode replacedParent ifNotNil: [:p | p isReplacement ifTrue: [p queryState replacementDeleted: p]]"
	].
	self logChanges: {#remove. aNode}
]

{ #category : #'as yet unclassified' }
DCEditBuffer >> update: aNode to: aString [

	posBuf add: [aNode contents: aString].
	self logChanges: {#update. aNode. aString}
]
