Class {
	#name : #SBTSCursorStream,
	#superclass : #ReadStream,
	#instVars : [
		'cursorDo'
	],
	#category : #'Sandblocks-TreeSitter-Utils'
}

{ #category : #'as yet unclassified' }
SBTSCursorStream >> cursorDo: aClosure [

	cursorDo := aClosure
]

{ #category : #'as yet unclassified' }
SBTSCursorStream >> flush [

	[self atEnd] whileFalse: [self next]
]

{ #category : #'as yet unclassified' }
SBTSCursorStream >> next [

	| morph |
	morph := super next.
	(morph notNil and: [morph isTSBlock and: [morph isError]]) ifTrue: [
		cursorDo value: (SBCursorSelect new block: morph).
		cursorDo value: (SBCursorText new
			block: morph;
			currentCommand: (SBTextCommand new textMorph: morph firstSubmorph)).
		^ self next].
	^ morph
]

{ #category : #'as yet unclassified' }
SBTSCursorStream >> peek [
	"override peek to not trigger our side effect in #next"

	self atEnd ifTrue: [^ nil].
	^ collection at: position + 1
]
