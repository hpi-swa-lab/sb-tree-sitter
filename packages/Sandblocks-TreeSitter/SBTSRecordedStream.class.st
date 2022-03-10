Class {
	#name : #SBTSRecordedStream,
	#superclass : #ReadStream,
	#instVars : [
		'furthestAdvance'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSRecordedStream class >> regex: aRegex matchPrefix: aString [

	| stream |
	"hacky way to get an estimate of how far in the input string we got -- we append a character that never matches and see if we the stream ever advanced to that character

likely that there are cases where this fails but I haven't found any just yet"
	stream := SBTSRecordedStream on: aString, (Character value: 0).
	aRegex matchesStreamPrefix: stream.
	^ stream likelyMatchedPrefix
]

{ #category : #'as yet unclassified' }
SBTSRecordedStream >> furthestAdvance [

	^ furthestAdvance
]

{ #category : #'as yet unclassified' }
SBTSRecordedStream >> likelyMatchedPrefix [

	^ self furthestAdvance = readLimit
]

{ #category : #'as yet unclassified' }
SBTSRecordedStream >> next [

	| ret |
	ret := super next.
	furthestAdvance := furthestAdvance max: self position.
	^ ret
]

{ #category : #'as yet unclassified' }
SBTSRecordedStream >> on: aCollection [

	super on: aCollection.
	
	furthestAdvance := 0
]
