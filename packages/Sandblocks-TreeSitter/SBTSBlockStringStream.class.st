Class {
	#name : #SBTSBlockStringStream,
	#superclass : #ReadStream,
	#instVars : [
		'characterMode'
	],
	#category : #'Sandblocks-TreeSitter-Utils'
}

{ #category : #'as yet unclassified' }
SBTSBlockStringStream >> characterMode: aBoolean [

	characterMode := aBoolean
]

{ #category : #'as yet unclassified' }
SBTSBlockStringStream >> next [

	| char |
	char := super next.
	^ (char isMorph and: [characterMode])
		ifTrue: [Character value: 0]
		ifFalse: [char]
]

{ #category : #'as yet unclassified' }
SBTSBlockStringStream >> on: aCollection [

	super on: aCollection.
	characterMode := false
]

{ #category : #'as yet unclassified' }
SBTSBlockStringStream >> printOn: stream [

	super printOn: stream.
	stream nextPut: $(.
	stream print: self position.
	stream nextPut: $)
]
