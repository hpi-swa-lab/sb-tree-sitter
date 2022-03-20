Class {
	#name : #SBRegexStream,
	#superclass : #ReadStream,
	#instVars : [
		'maxReadPosition',
		'maxPeekPosition'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBRegexStream class >> on: aString [

	^ self basicNew on: aString from: 1 to: aString size
]

{ #category : #'as yet unclassified' }
SBRegexStream class >> tryMatchPrefix: aString regex: aRegex [

	| s |
	s := self on: aString.
	aRegex matchesStream: s.
	^ s wasSuccess or: [aRegex matches: aString]
]

{ #category : #'as yet unclassified' }
SBRegexStream >> next [

	| ret |
	self atEnd ifTrue: [
		maxReadPosition := readLimit + 1.
		^ nil].
	ret := super next.
	maxReadPosition := maxReadPosition max: self position.
	^ ret
]

{ #category : #'as yet unclassified' }
SBRegexStream >> on: aCollection from: firstIndex to: lastIndex [

	super on: aCollection from: firstIndex to: lastIndex.
	maxReadPosition := 0
]

{ #category : #'as yet unclassified' }
SBRegexStream >> wasSuccess [

	^ maxReadPosition = (readLimit + 1)
]