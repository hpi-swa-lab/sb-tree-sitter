Class {
	#name : #SBTSPosition,
	#superclass : #Magnitude,
	#instVars : [
		'line',
		'character',
		'index'
	],
	#category : #'Sandblocks-TreeSitter-Utils'
}

{ #category : #'instance creation' }
SBTSPosition class >> fromIndex: aNumber in: aString [

	| lines |
	"aNumber = 1 is before the first character"
	lines := (aString take: aNumber - 1) lines.
	lines ifEmpty: [lines := {''}].
	^ self line: lines size - 1 character: lines last size index: aNumber
]

{ #category : #'instance creation' }
SBTSPosition class >> fromLSP: aJsonObject [

	^ self line: (aJsonObject at: 'line') character: (aJsonObject at: 'character')
]

{ #category : #'instance creation' }
SBTSPosition class >> line: aNumber character: anotherNumber [

	^ self new line: aNumber character: anotherNumber
]

{ #category : #'instance creation' }
SBTSPosition class >> line: aNumber character: anotherNumber index: aThirdNumber [

	^ self new line: aNumber character: anotherNumber index: aThirdNumber
]

{ #category : #'as yet unclassified' }
SBTSPosition class >> null [

	^ self line: 0 character: 0 index: 0
]

{ #category : #mutating }
SBTSPosition >> + aNumber [
	"advance the character index, does not consider line breaks"

	^ self copy
		line: line
		character: (character ifNotNil: [character + aNumber])
		index: index + aNumber
]

{ #category : #converting }
SBTSPosition >> - aPosition [

	self assert: aPosition line = self line.
	^ self character - aPosition character
]

{ #category : #comparing }
SBTSPosition >> < aTSPosition [

	(self index notNil and: [aTSPosition index notNil]) ifTrue: [^ self index < aTSPosition index].
	
	^ self line < aTSPosition line or: [self line = aTSPosition line and: [self character < aTSPosition character]]
]

{ #category : #comparing }
SBTSPosition >> = anObject [

	self species == anObject species ifFalse: [^ false].
	(self index notNil and: [anObject index notNil]) ifTrue: [^ self index = anObject index].
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

{ #category : #'as yet unclassified' }
SBTSPosition >> distance: aPoint [

	(aPoint line isNil or: [self line isNil]) ifTrue: ["FIXME: not the right solution, but we usually dont want to compare these"
	^ Float infinity].
	
	^ self line = aPoint line
		ifTrue: [(aPoint character - self character) abs]
		ifFalse: [ | a b width |
			width := 60.
			a := self min: aPoint.
			b := self max: aPoint.
			width - a character + b character + (b line - a line - 1 * width)]
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
SBTSPosition >> index [

	^ index
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

{ #category : #accessing }
SBTSPosition >> line: aNumber character: anotherNumber index: aThirdNumber [

	line := aNumber.
	character := anotherNumber.
	index := aThirdNumber
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
	index ifNotNil: [
		aStream nextPutAll: ',index='.
		aStream print: self index].
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
