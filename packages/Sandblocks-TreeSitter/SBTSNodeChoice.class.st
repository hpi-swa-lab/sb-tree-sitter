Class {
	#name : #SBTSNodeChoice,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'alternatives'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #accessing }
SBTSNodeChoice >> alternatives [

	^ alternatives
]

{ #category : #accessing }
SBTSNodeChoice >> alternatives: aCollection [

	alternatives := aCollection
]

{ #category : #copying }
SBTSNodeChoice >> basicCopy [

	^ super basicCopy alternatives: self alternatives
]

{ #category : #printing }
SBTSNodeChoice >> printOn: aStream [

	aStream nextPut: $(.
	self hasSubmorphs ifTrue: [
		aStream nextPut: $<.
		self firstSubmorph printOn: aStream.
		aStream nextPut: $>].
	self alternatives
		do: [:alt | aStream print: alt]
		separatedBy: [aStream nextPutAll: ' | '].
	aStream nextPut: $)
]

{ #category : #parsing }
SBTSNodeChoice >> resultsFor: aParser [

	^ (Array streamContents: [:stream |
		self alternatives do: [:alt | | parserCopy results |
			parserCopy := aParser copy.
			results := alt resultsFor: parserCopy.
			results = #noMatch ifFalse: [results do: [:result | stream nextPut: (self makeConcrete addChild: result)]]]]) ifEmpty: [#noMatch]
]
