Class {
	#name : #SBTSPosition,
	#superclass : #Magnitude,
	#instVars : [
		'line',
		'character'
	],
	#category : #'Sandblocks-TreeSitter-Utils'
}

{ #category : #'instance creation' }
SBTSPosition class >> fromIndex: aNumber in: aString [

	| lines |
	"aNumber = 1 is before the first character"
	lines := (aString take: aNumber - 1) lines.
	lines ifEmpty: [lines := {''}].
	^ self line: lines size - 1 character: lines last size
]

{ #category : #'instance creation' }
SBTSPosition class >> fromLSP: aJsonObject [

	^ self line: (aJsonObject at: 'line') character: (aJsonObject at: 'character')
]

{ #category : #'instance creation' }
SBTSPosition class >> line: aNumber character: anotherNumber [

	^ self new line: aNumber character: anotherNumber
]

{ #category : #mutating }
SBTSPosition >> + aNumber [
	"advance the character index, does not consider line breaks"

	^ self copy line: line character: character + aNumber
]

{ #category : #converting }
SBTSPosition >> - aPosition [

	self assert: aPosition line = self line.
	^ self character - aPosition character
]

{ #category : #comparing }
SBTSPosition >> < aTSPosition [

	^ self line < aTSPosition line or: [self line = aTSPosition line and: [self character < aTSPosition character]]
]

{ #category : #comparing }
SBTSPosition >> = anObject [

	self species == anObject species ifFalse: [^ false].
	^ self line = anObject line and: [self character = anObject character]
]

{ #category : #converting }
SBTSPosition >> asIndexIn: aString [

	| index lineIndex |
	index := 0.
	lineIndex := 0.
	aString lineIndicesDo: [:start :endWithoutDelimiters :end |
		lineIndex < self line ifTrue: [index := end].
		lineIndex := lineIndex + 1].
	^ index + (self character + 1)
]

{ #category : #accessing }
SBTSPosition >> character [

	^ character
]

{ #category : #accessing }
SBTSPosition >> column [

	^ self character
]

{ #category : #converting }
SBTSPosition >> end [

	^ self
]

{ #category : #converting }
SBTSPosition >> forLSP [

	^ Dictionary newFrom: {'line' -> self line. 'character' -> self character}
]

{ #category : #comparing }
SBTSPosition >> hash [

	^ self line hash bitXor: self character hash
]

{ #category : #accessing }
SBTSPosition >> line [

	^ line
]

{ #category : #accessing }
SBTSPosition >> line: aNumber character: anotherNumber [

	line := aNumber.
	character := anotherNumber
]

{ #category : #offsetting }
SBTSPosition >> offsetBy: aTSPosition [

	^ self class line: self line + aTSPosition line character: (aTSPosition line > 0
		ifTrue: [aTSPosition character]
		ifFalse: [self character + aTSPosition character])
]

{ #category : #printing }
SBTSPosition >> printOn: aStream [

	aStream nextPutAll: '(line='.
	aStream print: self line.
	aStream nextPutAll: ',char='.
	aStream print: self character.
	aStream nextPut: $)
]

{ #category : #offsetting }
SBTSPosition >> relativeTo: aTSPosition [

	^ self class line: self line - aTSPosition line character: (self line = aTSPosition line
		ifTrue: [self character - aTSPosition character]
		ifFalse: [self character])
]

{ #category : #converting }
SBTSPosition >> start [

	^ self
]
