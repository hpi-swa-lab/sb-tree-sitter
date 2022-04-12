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
SBTSInputParser >> normalizeResults: aCollection query: aString [

	| strings transitionPairs remaining hasAnyKeywords |
	"if we have a simple single-block result, see if some other results we found could be derived from that simple result. Heuristic is that if the source string starts the same as another block and we contain the innermost slot of that prefix, we can derive it"
	aCollection ifEmpty: [^ aCollection].
	
	strings := IdentityDictionary new.
	
	aCollection do: [:result |
		strings
			at: result
			put: (String streamContents: [:s | result do: [:r | r writeSourceOn: s indent: 0 forCompare: true]])].
	
	transitionPairs := aCollection first first factory transitionPairs.
	
	remaining := aCollection select: [:result | aCollection noneSatisfy: [:other | result ~~ other and: [(((strings at: result) beginsWith: (strings at: other)) and: [self blocks: result contain: other]) or: [transitionPairs anySatisfy: [:pair | pair key = other first type and: [pair value = result first type]]]]]].
	
	hasAnyKeywords := remaining anySatisfy: [:r | | node |
		node := r first firstDeepSubmorph slot firstNode.
		node isTSLabel and: [ | index |
			"only disambiguate keywords if they were terminated with a space, otherwise we may break typing e.g. `forage` because we abort with just one result after typing `for`"
			index := aString indexOfSubCollection: node label.
			index > 0 and: [(aString at: index + node label size ifAbsent: [$x]) = $ ]]].
	
	^ hasAnyKeywords
		ifTrue: [remaining select: [:r | r first firstDeepSubmorph slot firstNode isTSLabel]]
		ifFalse: [remaining]
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
	^ self
		normalizeResults: ((results select: [:parser | parser atEnd]) collect: [:parser | parser blocks])
		query: aString
]

{ #category : #query }
SBTSInputParser >> optionsForTemplate: aNode given: aString [

	| results |
	stream := aString readStream.
	memoizations := (1 to: stream originalContents size) collect: [:i | IdentityDictionary new].
	
	results := aNode resultsFor: self.
	results = #noMatch ifTrue: [^ #()].
	^ self
		normalizeResults: ((results select: [:parser | parser atEnd]) collect: [:parser | parser blocks])
		query: aString
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
SBTSInputParser >> remainingSize [

	^ stream originalContents size - stream position
]

{ #category : #stream }
SBTSInputParser >> stream [

	^ stream
]
