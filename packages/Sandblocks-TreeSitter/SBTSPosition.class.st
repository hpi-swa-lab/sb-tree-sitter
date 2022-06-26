Class {
	#name : #SBTSPosition,
	#superclass : #Object,
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

{ #category : #'as yet unclassified' }
SBTSPosition >> character [

	^ character
]

{ #category : #'as yet unclassified' }
SBTSPosition >> forLSP [

	^ Dictionary newFrom: {'line' -> line. 'character' -> character}
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
