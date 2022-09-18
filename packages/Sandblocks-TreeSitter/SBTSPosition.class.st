Class {
	#name : #SBTSPosition,
	#superclass : #Magnitude,
	#instVars : [
		'line',
		'character'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'instance creation' }
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

{ #category : #accessing }
SBTSPosition >> character [

	^ character
]

{ #category : #accessing }
SBTSPosition >> column [

	^ self character
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

{ #category : #printing }
SBTSPosition >> printOn: aStream [

	aStream nextPutAll: '(line='.
	aStream print: self line.
	aStream nextPutAll: ',char='.
	aStream print: self character.
	aStream nextPut: $)
]
