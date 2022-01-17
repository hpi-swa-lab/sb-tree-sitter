Class {
	#name : #SBTSNodeChoice,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'alternatives'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeChoice >> alternatives [

	^ alternatives
]

{ #category : #'as yet unclassified' }
SBTSNodeChoice >> alternatives: aCollection [

	alternatives := aCollection
]

{ #category : #'as yet unclassified' }
SBTSNodeChoice >> copy [

	^ super copy
		alternatives: self alternatives;
		addAllMorphs: (self submorphs collect: #copy)
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
SBTSNodeChoice >> resultsFor: aParser [

	^ (Array streamContents: [:stream |
		self alternatives do: [:alt | | parserCopy results |
			parserCopy := aParser copy.
			results := alt resultsFor: parserCopy.
			results = #noMatch ifFalse: [results do: [:result | stream nextPut: (self copy addChild: result)]]]]) ifEmpty: [#noMatch]
]
