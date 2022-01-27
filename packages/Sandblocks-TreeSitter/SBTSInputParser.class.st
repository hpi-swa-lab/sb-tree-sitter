Class {
	#name : #SBTSInputParser,
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
SBTSInputParser >> atEnd [

	^ stream atEnd
]

{ #category : #'initialize-release' }
SBTSInputParser >> initialize [

	super initialize.
	
	visitedSupertypes := Set new
]

{ #category : #memo }
SBTSInputParser >> memoizationFor: aString ifPresent: aSuccessBlock ifAbsentPut: aBlock [

	| dict |
	((visitedSupertypes includes: aString) and: [stream peek = (Character value: 0)]) ifTrue: [
		visitedSupertypes remove: aString.
		"TODO: can we write this back?"
		^ aBlock value].
	
	dict := memoizations at: stream position + 1.
	^ dict at: aString ifPresent: aSuccessBlock ifAbsent: [
		dict at: aString put: #recur.
		dict at: aString put: aBlock value]
]

{ #category : #stream }
SBTSInputParser >> next [

	^ stream next
]

{ #category : #query }
SBTSInputParser >> optionsFor: aNode given: aString before: aBoolean [

	| results |
	stream := (aBoolean
		ifTrue: [aString, (Character value: 0)]
		ifFalse: [(Character value: 0) asString, aString]) readStream.
	memoizations := (1 to: stream originalContents size) collect: [:i | IdentityDictionary new].
	
	aNode allSuperTypesDo: [:typeNode |
		"if our nested element (char0) is at the start, we would immediately abort expanding instead of recursing. instead, allow one level of recursion for each type node that is above our nested element."
		aBoolean ifFalse: [visitedSupertypes add: typeNode type].
		aBoolean
			ifTrue: [memoizations last at: typeNode type put: {typeNode}]
			ifFalse: [memoizations first at: typeNode type put: {typeNode}]].
	
	results := aNode root makeTemplate resultsFor: self.
	results = #noMatch ifTrue: [^ #()].
	^ results select: [:result | result parser atEnd]
]

{ #category : #query }
SBTSInputParser >> optionsForTemplate: aNode given: aString [

	| results |
	stream := aString readStream.
	memoizations := (1 to: stream originalContents size) collect: [:i | IdentityDictionary new].
	results := aNode resultsFor: self.
	results = #noMatch ifTrue: [^ #()].
	^ results select: [:result | result parser atEnd]
]

{ #category : #stream }
SBTSInputParser >> peek [

	^ stream peek
]

{ #category : #stream }
SBTSInputParser >> position [

	^ stream position
]

{ #category : #stream }
SBTSInputParser >> position: aNumber [

	stream position: aNumber
]

{ #category : #copying }
SBTSInputParser >> postCopy [

	super postCopy.
	stream := (ReadStream on: stream contents)
		position: stream position;
		yourself.
	visitedSupertypes := visitedSupertypes copy
]

{ #category : #stream }
SBTSInputParser >> stream [

	^ stream
]
