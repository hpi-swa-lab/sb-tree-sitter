Class {
	#name : #SBLineInfoStream,
	#superclass : #WriteStream,
	#instVars : [
		'currentLine',
		'currentIndexInLine'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBLineInfoStream >> currentIndexInLine [

	^ currentIndexInLine
]

{ #category : #'as yet unclassified' }
SBLineInfoStream >> currentLine [

	^ currentLine
]

{ #category : #'as yet unclassified' }
SBLineInfoStream >> hasLineInfo [

	^ true
]

{ #category : #'as yet unclassified' }
SBLineInfoStream >> nextPut: anObject [

	(anObject = Character cr or: [anObject = Character lf and: [self peekLast ~= Character cr]])
		ifTrue: [
			currentLine := currentLine + 1.
			currentIndexInLine := 0]
		ifFalse: [currentIndexInLine := currentIndexInLine + 1].
	super nextPut: anObject
]

{ #category : #'as yet unclassified' }
SBLineInfoStream >> nextPutAll: aCollection [

	| localLast |
	localLast := self peekLast.
	aCollection do: [:char |
		(char = Character cr or: [char = Character lf and: [localLast ~= Character cr]])
			ifTrue: [
				currentLine := currentLine + 1.
				currentIndexInLine := 0]
			ifFalse: [currentIndexInLine := currentIndexInLine + 1].
		localLast := char].
	super nextPutAll: aCollection
]

{ #category : #'as yet unclassified' }
SBLineInfoStream >> on: aString [

	super on: aString.
	currentLine := 0.
	currentIndexInLine := 0
]
