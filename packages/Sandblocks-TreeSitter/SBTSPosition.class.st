Class {
	#name : #SBTSPosition,
	#superclass : #Magnitude,
	#instVars : [
		'line',
		'character'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSPosition class >> line: aNumber character: anotherNumber [

	^ self new line: aNumber character: anotherNumber
]

{ #category : #comparing }
SBTSPosition >> < aTSPosition [

	self line < aTSPosition line or: [self line = aTSPosition line and: [self character < aTSPosition character]]
]

{ #category : #comparing }
SBTSPosition >> = anObject [

	self species == anObject species ifFalse: [^ false].
	^ self line = anObject line and: [self character = anObject character]
]

{ #category : #'as yet unclassified' }
SBTSPosition >> character [

	^ character
]

{ #category : #'as yet unclassified' }
SBTSPosition >> column [

	^ self character
]

{ #category : #'as yet unclassified' }
SBTSPosition >> forLSP [

	^ Dictionary newFrom: {'line' -> line. 'character' -> character}
]

{ #category : #comparing }
SBTSPosition >> hash [

	^ self line hash bitXor: self character hash
]

{ #category : #'as yet unclassified' }
SBTSPosition >> line [

	^ line
]

{ #category : #'as yet unclassified' }
SBTSPosition >> line: aNumber character: anotherNumber [

	line := aNumber.
	character := anotherNumber
]

{ #category : #'as yet unclassified' }
SBTSPosition >> printOn: aStream [

	aStream nextPutAll: '(line='.
	aStream print: line.
	aStream nextPutAll: ',char='.
	aStream print: character.
	aStream nextPut: $)
]
