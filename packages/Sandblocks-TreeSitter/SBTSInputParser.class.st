Class {
	#name : #SBTSInputParser,
	#superclass : #Object,
	#instVars : [
		'stream',
		'memoizations',
		'visitedSupertypes',
		'blocks',
		'symbolStack',
		'activeRecursion'
	],
	#category : #'Sandblocks-TreeSitter-Parser'
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
SBTSInputParser >> memoizationFor: aSymbol ifPresent: aSuccessBlock ifAbsentPut: aBlock [

	| dict index recursion |
	((visitedSupertypes includes: aSymbol type) and: [stream peek = (Character value: 0)]) ifTrue: [
		visitedSupertypes remove: aSymbol type.
		"TODO: can we write this back?"
		^ aBlock value].
	
	index := stream position.
	dict := memoizations at: index + 1.
	recursion := activeRecursion at: index + 1.
	
	^ dict
		at: aSymbol type
		ifPresent: [:results |
			aSuccessBlock value: (results isLeftRecursion
				ifTrue: [
					SBToggledCode
						comment: ''
						active: 0
						do: {[results setLeftRecursionDetectedFrom: aSymbol stack: symbolStack]}.
					{}]
				ifFalse: [results parsers collect: [:p | p copy]])]
		ifAbsent: [ | results entry startGrowingSeed lr |
			recursion ifNotNil: [
				((recursion second includes: aSymbol type) not and: [aSymbol type ~= recursion first]) ifTrue: [^ {}].
				(recursion third includes: aSymbol type) ifTrue: [
					recursion third remove: aSymbol type.
					^ aBlock value]].
			
			lr := SBTSRecursion new.
			entry := SBTSMemoEntry new parsers: lr.
			dict at: aSymbol type put: entry.
			symbolStack add: aSymbol type.
			results := aBlock value.
			symbolStack removeLast.
			
			startGrowingSeed := SBToggledCode
				comment: ''
				active: 2
				do: {[false]. [entry isLeftRecursion and: [entry leftRecursionDetected and: [results notEmpty]]]}.
			entry parsers: (results collect: [:p | p copy]).
			startGrowingSeed
				ifTrue: [ | recurResults |
					lr seed: entry parsers.
					"grow lr"
					activeRecursion at: index + 1 put: lr head.
					[
						lr head at: 3 put: lr head second copy.
						results first stream position: index.
						recurResults := aSymbol bodyTemplate resultsFor: results first] doWhileTrue: ["todo position advanced"
					recurResults notEmpty and: [recurResults first stream position <= index]].
					activeRecursion at: index + 1 put: nil.
					recurResults]
				ifFalse: [results]]
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

	stream := ((aCollection collect: [:i | Character value: 0] as: String), (aString, (anotherCollection collect: [:i | Character value: 0] as: String))) readStream.
	memoizations := (1 to: stream originalContents size) collect: [:i | IdentityDictionary new].
	activeRecursion := Array new: stream originalContents size withAll: nil.
	symbolStack := OrderedCollection new.
	
	aCollection ifNotEmpty: [
		aCollection first slot allSuperTypesDo: [:typeNode | "if our nested element (char0) is at the start, we would immediately abort expanding instead of recursing. instead, allow one level of recursion for each type node that is above our nested element."
		aCollection first slot firstNode ~= typeNode ifTrue: [visitedSupertypes add: typeNode type]]].
	
	aCollection doWithIndex: [:block :index |
		block slot allSuperTypesDo: [:typeNode | | copy |
			copy := block copyBlock.
			copy slot trimNodesTo: typeNode.
			(memoizations at: index)
				at: typeNode type
				put: (SBTSMemoEntry new parsers: {self copy addBlock: copy})]].
	anotherCollection doWithIndex: [:block :index |
		block slot allSuperTypesDo: [:typeNode | | copy |
			copy := block copyBlock.
			copy slot trimNodesTo: typeNode.
			(memoizations at: aCollection size + (aString size + index))
				at: typeNode type
				put: (SBTSMemoEntry new parsers: {self copy addBlock: copy})]].
	
	^ self
		normalizeResults: (((aTSBlock slot transitionRoot resultsFor: self) select: [:parser | parser atEnd]) collect: [:parser | parser blocks])
		query: aString
]

{ #category : #query }
SBTSInputParser >> optionsForTemplate: aNode given: aString [

	stream := aString readStream.
	activeRecursion := Array new: aString size withAll: nil.
	symbolStack := OrderedCollection new.
	memoizations := (1 to: stream originalContents size) collect: [:i | IdentityDictionary new].
	^ self
		normalizeResults: (((aNode resultsFor: self) select: [:parser | parser atEnd]) collect: [:parser | parser blocks])
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
	symbolStack := symbolStack copy.
	activeRecursion := activeRecursion collect: [:r | r copy].
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
