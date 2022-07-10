Class {
	#name : #SBTSNodeCursor,
	#superclass : #Object,
	#instVars : [
		'current',
		'library'
	],
	#category : #'Sandblocks-TreeSitter-FFI'
}

{ #category : #'as yet unclassified' }
SBTSNodeCursor >> currentNode [

	^ current
]

{ #category : #'as yet unclassified' }
SBTSNodeCursor >> gotoFirstChild [

	| new |
	new := library nodeChild: current at: 0.
	^ (library nodeIsNull: new) ifTrue: [false] ifFalse: [
		current := new.
		true]
]

{ #category : #'as yet unclassified' }
SBTSNodeCursor >> gotoNextSibling [

	| new |
	new := library nodeNextSibling: current.
	^ (library nodeIsNull: new) ifTrue: [false] ifFalse: [
		current := new.
		true]
]

{ #category : #'as yet unclassified' }
SBTSNodeCursor >> gotoParent [

	| new |
	new := library nodeParent: current.
	^ (library nodeIsNull: new) ifTrue: [false] ifFalse: [
		current := new.
		true]
]

{ #category : #'as yet unclassified' }
SBTSNodeCursor >> on: aNode library: aLibrary [

	current := aNode.
	library := aLibrary
]
