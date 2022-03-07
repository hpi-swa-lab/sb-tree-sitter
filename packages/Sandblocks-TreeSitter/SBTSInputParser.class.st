Class {
	#name : #SBTSInputParser,
	#superclass : #Object,
	#instVars : [
		'stream',
		'memoizations',
		'visitedSupertypes',
		'blocks'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #blocks }
SBTSInputParser >> addAllBlocks: aCollection [

	aCollection do: [:b | self addBlock: b]
]

{ #category : #blocks }
SBTSInputParser >> addBlock: aBlock [

	blocks add: aBlock
]

{ #category : #stream }
SBTSInputParser >> atEnd [

	^ stream atEnd
]

{ #category : #blocks }
SBTSInputParser >> blocks [

	^ blocks
]

{ #category : #blocks }
SBTSInputParser >> blocks: aCollection [

	blocks := aCollection
]

{ #category : #'initialize-release' }
SBTSInputParser >> initialize [

	super initialize.
	
	visitedSupertypes := Set new.
	blocks := OrderedCollection new
]

{ #category : #blocks }
SBTSInputParser >> makeRootBlock: aBlock [

	aBlock slot firstNode isSuperType
		ifTrue: [
			self assert: blocks size = 1.
			blocks first slot mergeWith: aBlock slot]
		ifFalse: [blocks := OrderedCollection with: (aBlock addAllMorphs: blocks)]
]

{ #category : #memo }
SBTSInputParser >> memoizationFor: aString ifPresent: aSuccessBlock ifAbsentPut: aBlock [

	| dict |
	((visitedSupertypes includes: aString) and: [stream peek = (Character value: 0)]) ifTrue: [
		visitedSupertypes remove: aString.
		"TODO: can we write this back?"
		^ aBlock value].
	
	dict := memoizations at: stream position + 1.
	^ dict
		at: aString
		ifPresent: [:results | aSuccessBlock value: (results = #noMatch ifTrue: [results] ifFalse: [results collect: [:p | p copy]])]
		ifAbsent: [ | results |
			dict at: aString put: #recur.
			results := aBlock value.
			dict at: aString put: (results = #noMatch ifTrue: [results] ifFalse: [
				results collect: [:p |
					self assert: (p isKindOf: SBTSInputParser).
					p copy]]).
			results]
]

{ #category : #stream }
SBTSInputParser >> next [

	^ stream next
]

{ #category : #query }
SBTSInputParser >> optionsFor: aTSBlock given: aString before: aBoolean [

	| results |
	stream := (aBoolean
		ifTrue: [aString, (Character value: 0)]
		ifFalse: [(Character value: 0) asString, aString]) readStream.
	memoizations := (1 to: stream originalContents size) collect: [:i | IdentityDictionary new].
	
	aTSBlock slot allSuperTypesDo: [:typeNode | "if our nested element (char0) is at the start, we would immediately abort expanding instead of recursing. instead, allow one level of recursion for each type node that is above our nested element."
	aBoolean ifFalse: [visitedSupertypes add: typeNode type]].
	aTSBlock slot allSuperTypesDo: [:typeNode | | parser |
		parser := self copy addBlock: aTSBlock copyBlock.
		aBoolean
			ifTrue: [memoizations last at: typeNode type put: {parser}]
			ifFalse: [memoizations first at: typeNode type put: {parser}]].
	
	results := aTSBlock slot lastNode resultsFor: self.
	results = #noMatch ifTrue: [^ #()].
	^ (results select: [:parser | parser atEnd]) collect: [:parser | parser root]
]

{ #category : #query }
SBTSInputParser >> optionsForTemplate: aNode given: aString [

	| results |
	stream := aString readStream.
	memoizations := (1 to: stream originalContents size) collect: [:i | IdentityDictionary new].
	
	results := aNode resultsFor: self.
	results = #noMatch ifTrue: [^ #()].
	^ (results select: [:parser | parser atEnd]) collect: [:parser | parser blocks first]
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
	visitedSupertypes := visitedSupertypes copy.
	blocks := blocks collect: [:block | block copyBlock]
]

{ #category : #stream }
SBTSInputParser >> stream [

	^ stream
]
