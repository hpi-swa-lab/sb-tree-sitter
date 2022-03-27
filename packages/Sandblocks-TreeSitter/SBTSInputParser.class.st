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
SBTSInputParser >> addBlock: aBlock [

	blocks add: aBlock.
	self atEnd ifTrue: [
		aBlock setProperty: #lastConstructed toValue: true]
]

{ #category : #blocks }
SBTSInputParser >> addEmptyBlocks: aCollection [

	aCollection do: [:b | blocks add: b]
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

{ #category : #blocks }
SBTSInputParser >> blocks: aCollection contain: anotherCollection [

	| find |
	find := anotherCollection first isSandblock
		ifTrue: [anotherCollection first lastDeepChild]
		ifFalse: [anotherCollection first].
	find isUnknown ifTrue: [^ false].
	aCollection do: [:morph | morph allMorphsDo: [:m | (m type = find type and: [m contents = find contents]) ifTrue: [^ true]]].
	^ false
]

{ #category : #'initialize-release' }
SBTSInputParser >> initialize [

	super initialize.
	
	visitedSupertypes := Set new.
	blocks := OrderedCollection new
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

{ #category : #blocks }
SBTSInputParser >> normalizeResults: aCollection [

	| strings |
	"if we have a simple single-block result, see if some other results we found could be derived from that simple result. Heuristic is that if the source string starts the same as another block and we contain the innermost slot of that prefix, we can derive it"
	false ifTrue: [^ aCollection].
	
	strings := IdentityDictionary new.
	
	aCollection do: [:result |
		strings
			at: result
			put: (String streamContents: [:s | result do: [:r | r writeSourceOn: s indent: 0 forCompare: true]])].
	
	^ aCollection select: [:result | aCollection noneSatisfy: [:other | result ~~ other and: [((strings at: result) beginsWith: (strings at: other)) and: [self blocks: result contain: other]]]]
]

{ #category : #query }
SBTSInputParser >> optionsFor: aTSBlock given: aString before: aBoolean [

	| results |
	stream := (aBoolean
		ifTrue: [aString, (Character value: 0)]
		ifFalse: [(Character value: 0) asString, aString]) readStream.
	memoizations := (1 to: stream originalContents size) collect: [:i | IdentityDictionary new].
	
	aBoolean ifFalse: [
		aTSBlock slot allSuperTypesDo: [:typeNode | "if our nested element (char0) is at the start, we would immediately abort expanding instead of recursing. instead, allow one level of recursion for each type node that is above our nested element."
		aTSBlock slot firstNode ~= typeNode ifTrue: [visitedSupertypes add: typeNode type]]].
	
	aTSBlock slot allSuperTypesDo: [:typeNode | | parser |
		parser := self copy addBlock: aTSBlock copyBlock.
		aBoolean
			ifTrue: [memoizations last at: typeNode type put: {parser}]
			ifFalse: [memoizations first at: typeNode type put: {parser}]].
	
	results := aTSBlock slot transitionRoot resultsFor: self.
	results = #noMatch ifTrue: [^ #()].
	^ (results select: [:parser | parser atEnd]) collect: [:parser | parser blocks]
]

{ #category : #query }
SBTSInputParser >> optionsFor: aTSBlock given: aString before: aCollection after: anotherCollection [

	| results |
	stream := ((aCollection collect: [:i | Character value: 0] as: String), (aString, (anotherCollection collect: [:i | Character value: 0] as: String))) readStream.
	memoizations := (1 to: stream originalContents size) collect: [:i | IdentityDictionary new].
	
	aCollection ifNotEmpty: [
		aCollection first slot allSuperTypesDo: [:typeNode | "if our nested element (char0) is at the start, we would immediately abort expanding instead of recursing. instead, allow one level of recursion for each type node that is above our nested element."
		aCollection first slot firstNode ~= typeNode ifTrue: [visitedSupertypes add: typeNode type]]].
	
	aCollection doWithIndex: [:block :index |
		block slot allSuperTypesDo: [:typeNode | | copy |
			copy := block copyBlock.
			copy slot trimNodesTo: typeNode.
			(memoizations at: index) at: typeNode type put: {self copy addBlock: copy}]].
	anotherCollection doWithIndex: [:block :index |
		block slot allSuperTypesDo: [:typeNode | | copy |
			copy := block copyBlock.
			copy slot trimNodesTo: typeNode.
			(memoizations at: aCollection size + (aString size + index))
				at: typeNode type
				put: {self copy addBlock: copy}]].
	
	results := aTSBlock slot transitionRoot resultsFor: self.
	results = #noMatch ifTrue: [^ #()].
	^ (results select: [:parser | parser atEnd]) collect: [:parser | parser blocks]
]

{ #category : #query }
SBTSInputParser >> optionsForTemplate: aNode given: aString [

	| results |
	stream := aString readStream.
	memoizations := (1 to: stream originalContents size) collect: [:i | IdentityDictionary new].
	
	results := aNode resultsFor: self.
	results = #noMatch ifTrue: [^ #()].
	^ self normalizeResults: ((results select: [:parser | parser atEnd]) collect: [:parser | parser blocks])
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
