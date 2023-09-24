Class {
	#name : #SBTSCursor,
	#superclass : #SBTSCursorRaw,
	#category : #'Sandblocks-TreeSitter-FFI'
}

{ #category : #'as yet unclassified' }
SBTSCursor >> gotoFirstChild [

	| ret |
	ret := SBToggledCode
		comment: ''
		active: 1
		do: {[cursor gotoFirstChild]. [library cursorGotoFirstChild: cursor]}.
	ret ifTrue: [previousSiblings add: nil].
	(ret and: [self shouldSkipParsedNode: self node]) ifTrue: [^ self gotoNextSibling not].
	^ ret
		ifTrue: [
			atEnd := false.
			true]
		ifFalse: [false]
]

{ #category : #'as yet unclassified' }
SBTSCursor >> gotoNextSibling [

	| ret |
	previousSiblings atLast: 1 put: self node.
	self position: (self endByteIndex: self node).
	ret := SBToggledCode
		comment: ''
		active: 1
		do: {[cursor gotoNextSibling]. [library cursorGotoNextSibling: cursor]}.
	[ret and: [self shouldSkipParsedNode: self node]] whileTrue: [
		self position: (self endByteIndex: self node).
		previousSiblings atLast: 1 put: self node.
		ret := SBToggledCode
			comment: ''
			active: 1
			do: {[cursor gotoNextSibling]. [library cursorGotoNextSibling: cursor]}].
	^ atEnd := ret not
]
