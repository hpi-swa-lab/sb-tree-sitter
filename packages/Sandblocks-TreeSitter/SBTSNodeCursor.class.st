Class {
	#name : #SBTSNodeCursor,
	#superclass : #Object,
	#instVars : [
		'current',
		'library',
		'cursor'
	],
	#category : #'Sandblocks-TreeSitter-FFI'
}

{ #category : #'as yet unclassified' }
SBTSNodeCursor >> currentNode [

	^ library cursorCurrentNode: cursor
]

{ #category : #'as yet unclassified' }
SBTSNodeCursor >> gotoFirstChild [

	^ library cursorGotoFirstChild: cursor
]

{ #category : #'as yet unclassified' }
SBTSNodeCursor >> gotoNextSibling [

	^ library cursorGotoNextSibling: cursor
]

{ #category : #'as yet unclassified' }
SBTSNodeCursor >> gotoParent [

	^ library cursorGotoParent: cursor
]

{ #category : #'as yet unclassified' }
SBTSNodeCursor >> on: aNode library: aLibrary [

	cursor := aLibrary cursorNew: aNode.
	current := aNode.
	library := aLibrary
]

{ #category : #'as yet unclassified' }
SBTSNodeCursor >> postCopy [

	cursor := library cursorCopy: cursor
]
