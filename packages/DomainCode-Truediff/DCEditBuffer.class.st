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

{ #category : #operations }
DCEditBuffer >> attach: aNode to: aParentNode at: aNumber [

	self assert: aNode ~~ aParentNode.
	self assert: aNumber >= 1.
	posBuf add: [
		aParentNode ifNotNil: [
			aParentNode addBaseChild: aNode at: aNumber.
			aParentNode addMorph: aNode baseMorph asElementNumber: aNumber]].
	self logChanges: {#attach. aNode. aParentNode. aNumber}
]

{ #category : #operations }
DCEditBuffer >> detach: aNode [

	negBuf add: [
		aNode baseRemoveFromParent.
		aNode replacedParent ifNotNil: #delete ifNil: [aNode delete]].
	detachListNext add: {aNode baseParent -> aNode}.
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

	false ifTrue: [Transcript showln: aCollection]
]

{ #category : #operations }
DCEditBuffer >> remove: aNode [
	"used to deallocate deattached children, gc does that for us"

	negBuf add: [].
	self logChanges: {#remove. aNode}
]

{ #category : #operations }
DCEditBuffer >> update: aNode to: aString [

	posBuf add: [aNode contents: aString].
	self logChanges: {#update. aNode. aString}
]
