Class {
	#name : #SBTSParser,
	#superclass : #Object,
	#instVars : [
		'previousAlternatives',
		'stream',
		'memoizations',
		'visitedSupertypes'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #stream }
SBTSParser >> atEnd [

	^ stream atEnd
]

{ #category : #'as yet unclassified' }
SBTSParser >> incrementAlternativeFor: aNode [

	^ previousAlternatives at: aNode put: (self previousAlternativeFor: aNode) + 1
]

{ #category : #'initialize-release' }
SBTSParser >> initialize [

	super initialize.
	
	
]

{ #category : #memo }
SBTSParser >> markVisitedSuperType: aString [

	visitedSupertypes add: aString
]

{ #category : #memo }
SBTSParser >> memoizationFor: aString ifPresent: aSuccessBlock ifAbsentPut: aBlock [

	| dict |
	((visitedSupertypes includes: aString asSymbol) and: [stream peek = (Character value: 0)]) ifTrue: [
		visitedSupertypes remove: aString.
		"TODO: can we write this back?"
		^ aBlock value].
	
	dict := memoizations at: stream position + 1.
	^ dict at: aString asSymbol ifPresent: aSuccessBlock ifAbsent: [
		dict at: aString asSymbol put: #recur.
		dict at: aString asSymbol put: aBlock value]
]

{ #category : #stream }
SBTSParser >> next [

	^ stream next
]

{ #category : #query }
SBTSParser >> optionsFor: aNode given: aString before: aBoolean [

	| results |
	stream := (aBoolean
		ifTrue: [aString, (Character value: 0)]
		ifFalse: [(Character value: 0) asString, aString]) readStream.
	memoizations := (1 to: stream originalContents size) collect: [:i | IdentityDictionary new].
	visitedSupertypes := Set new.
	
	aNode allSuperTypesDo: [:typeNode |
		visitedSupertypes add: typeNode type asSymbol.
		aBoolean
			ifTrue: [memoizations last at: typeNode type asSymbol put: {typeNode}]
			ifFalse: [memoizations first at: typeNode type asSymbol put: {typeNode}]].
	
	results := aNode root resultsFor: self.
	results = #noMatch ifTrue: [^ #()].
	^ results select: [:result | result parser atEnd]
]

{ #category : #query }
SBTSParser >> optionsForTemplate: aNode given: aString [

	| results |
	stream := aString readStream.
	memoizations := (1 to: stream originalContents size) collect: [:i | IdentityDictionary new].
	results := aNode resultsFor: self.
	results = #noMatch ifTrue: [^ #()].
	^ results select: [:result | result parser atEnd]
]

{ #category : #stream }
SBTSParser >> peek [

	^ stream peek
]

{ #category : #stream }
SBTSParser >> position [

	^ stream position
]

{ #category : #stream }
SBTSParser >> position: aNumber [

	stream position: aNumber
]

{ #category : #copying }
SBTSParser >> postCopy [

	super postCopy.
	stream := stream veryDeepCopy.
	visitedSupertypes := visitedSupertypes copy
]

{ #category : #'as yet unclassified' }
SBTSParser >> previousAlternativeFor: aNode [

	^ previousAlternatives at: aNode ifAbsent: [1]
]

{ #category : #stream }
SBTSParser >> stream [

	^ stream
]
