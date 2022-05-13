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
	self atEnd ifTrue: [aBlock setProperty: #lastConstructed toValue: true]
]

{ #category : #blocks }
SBTSInputParser >> addEmptyBlocks: aCollection [

	aCollection do: [:b | blocks add: b]
]

{ #category : #memo }
SBTSInputParser >> answerResultsFor: aSymbol recursion: aRecursion at: aNumber [

	"self assert: symbolStack last = aSymbol type."
	symbolStack removeLast.
	^ aRecursion head
		ifNotNil: [:head |
			head first = aSymbol type
				ifTrue: [
					aRecursion seed: {self}.
					self growLeftRecursionAt: aNumber head: aRecursion head for: aSymbol]
				ifFalse: [
					self assert: aRecursion seed size = 1.
					self blocks: aRecursion seed.
					{self}]]
		ifNil: [
			((memoizations at: aNumber) at: aSymbol type) parsers: {self}.
			{self}]
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

	self assert: (aCollection allSatisfy: [:m | m isMorph]).
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

{ #category : #stream }
SBTSInputParser >> characterModeDuring: aBlock [

	stream characterMode: true.
	aBlock ensure: [stream characterMode: false]
]

{ #category : #memo }
SBTSInputParser >> growLeftRecursionAt: aNumber head: aHead for: aSymbol [

	| recurResults entry queue start |
	entry := (memoizations at: aNumber) at: aSymbol type.
	(aHead first ~= aSymbol type or: [self atEnd]) ifTrue: [^ entry lr seed].
	"self assert: aSymbol type = entry lr seed last blocks anyOne type."
	queue := OrderedCollection withAll: entry lr seed.
	recurResults := OrderedCollection new.
	
	activeRecursion at: aNumber put: aHead.
	start := self copy position: aNumber - 1.
	"can maybe drop"
	
	[queue notEmpty] whileTrue: [ | current results |
		aHead at: 3 put: aHead second copy.
		current := queue removeFirst.
		entry parsers: {current}.
		results := aSymbol resultsNonMemoizedFor: start copy.
		results := results select: [:result | result stream position > (aNumber - 1)].
		"check if current is already a valid case"
		results ifEmpty: [recurResults add: current] ifNotEmpty: [queue addAll: results]].
	
	activeRecursion at: aNumber put: nil.
	^ recurResults
]

{ #category : #'initialize-release' }
SBTSInputParser >> initialize [

	super initialize.
	
	visitedSupertypes := Set new.
	blocks := OrderedCollection new
]

{ #category : #memo }
SBTSInputParser >> memoizationFor: aSymbol ifAbsentPut: aBlock [

	| index |
	((visitedSupertypes includes: aSymbol type) and: [stream peek isMorph]) ifTrue: [
		visitedSupertypes remove: aSymbol type.
		"TODO: can we write this back?"
		^ aBlock value].
	
	(self peek isMorph and: [self peek slot includesParentThat: [:p | p type = aSymbol type]]) ifTrue: [ | block |
		block := self next copyBlock.
		block slot trimNodesToTypeOf: aSymbol.
		self addBlock: block.
		^ {self}].
	
	index := stream position.
	^ (self recall: aSymbol evalDo: aBlock)
		ifNil: [ | lr memoEntry |
			lr := SBTSRecursion new.
			memoEntry := SBTSMemoEntry new lr: lr.
			(memoizations at: index + 1) at: aSymbol type put: memoEntry.
			symbolStack add: aSymbol type.
			aBlock value gather: [:result | | a |
				a := result answerResultsFor: aSymbol recursion: lr at: index + 1.
				self assert: (a allSatisfy: [:c | c isKindOf: SBTSInputParser]).
				a]]
		ifNotNil: [:memoEntry |
			(memoEntry isLeftRecursion
				ifTrue: [
					SBToggledCode
						comment: ''
						active: 0
						do: {[memoEntry setLeftRecursionDetectedFrom: aSymbol stack: symbolStack]}.
					memoEntry lr seed]
				ifFalse: [memoEntry parsers]) collect: [:parser | parser copy updateStateFrom: self symbol: aSymbol]]
]

{ #category : #stream }
SBTSInputParser >> next [

	^ stream next
]

{ #category : #blocks }
SBTSInputParser >> normalizeResults: aCollection query: aString [

	| strings transitionPairs remaining hasAnyKeywords unique |
	"if we have a simple single-block result, see if some other results we found could be derived from that simple result. Heuristic is that if the source string starts the same as another block and we contain the innermost slot of that prefix, we can derive it"
	unique := aCollection.
	unique ifEmpty: [^ unique asArray].
	
	strings := IdentityDictionary new.
	
	unique do: [:result |
		strings
			at: result
			put: (String streamContents: [:s | result do: [:r | r writeSourceOn: s indent: 0 forCompare: true]])].
	
	transitionPairs := unique anyOne first factory transitionPairs.
	
	remaining := unique select: [:result | unique noneSatisfy: [:other | result ~~ other and: [(((strings at: result) beginsWith: (strings at: other)) and: [self blocks: result contain: other]) or: [transitionPairs anySatisfy: [:pair | pair key = other first type and: [pair value = result first type]]]]]].
	
	hasAnyKeywords := remaining anySatisfy: [:r | | node |
		node := r first firstDeepSubmorph slot firstNode.
		node isTSLabel and: [ | index |
			"only disambiguate keywords if they were terminated with a space, otherwise we may break typing e.g. `forage` because we abort with just one result after typing `for`"
			index := aString indexOfSubCollection: node label.
			index > 0 and: [(aString at: index + node label size ifAbsent: [$x]) = $ ]]].
	
	^ (hasAnyKeywords
		ifTrue: [remaining select: [:r | r first firstDeepSubmorph slot firstNode isTSLabel]]
		ifFalse: [remaining]) asArray
]

{ #category : #query }
SBTSInputParser >> optionsFor: aTSBlock given: aString before: aCollection after: anotherCollection [

	stream := SBTSBlockStringStream on: aCollection, aString asArray, anotherCollection.
	memoizations := (1 to: stream originalContents size) collect: [:i | IdentityDictionary new].
	activeRecursion := Array new: stream originalContents size withAll: nil.
	symbolStack := OrderedCollection new.
	
	SBToggledCode comment: '' active: 1 do: {
		[
			aCollection ifNotEmpty: [
				aCollection first slot allSuperTypesDo: [:typeNode | "if our nested element (char0) is at the start, we would immediately abort expanding instead of recursing. instead, allow one level of recursion for each type node that is above our nested element."
				aCollection first slot firstNode ~= typeNode ifTrue: [visitedSupertypes add: typeNode type]]]]}.
	
	SBToggledCode comment: '' active: 0 do: {
		[
			aCollection doWithIndex: [:block :index |
				block slot allSuperTypesDo: [:typeNode | | copy |
					copy := block copyBlock.
					copy slot trimNodesTo: typeNode.
					(memoizations at: index)
						at: typeNode type
						put: (SBTSMemoEntry new parsers: {self copy addBlock: copy})]]]}.
	SBToggledCode comment: '' active: 0 do: {
		[
			anotherCollection doWithIndex: [:block :index |
				block slot allSuperTypesDo: [:typeNode | | copy |
					copy := block copyBlock.
					copy slot trimNodesTo: typeNode.
					(memoizations at: aCollection size + (aString size + index))
						at: typeNode type
						put: (SBTSMemoEntry new parsers: {self copy addBlock: copy})]]]}.
	
	^ self
		normalizeResults: (((aTSBlock slot transitionRoot resultsFor: self) select: [:parser | parser atEnd]) collect: [:parser | parser blocks])
		query: aString
]

{ #category : #query }
SBTSInputParser >> optionsForTemplate: aNode given: aString [

	stream := SBTSBlockStringStream on: aString asArray.
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
	stream := (SBTSBlockStringStream on: stream contents)
		position: stream position;
		yourself.
	SBToggledCode
		comment: ''
		active: 0
		do: {[memoizations := memoizations collect: [:m | m collect: [:entry | entry copy]]]}.
	SBToggledCode
		comment: ''
		active: 0
		do: {[activeRecursion := activeRecursion collect: [:r | r copy]]}.
	symbolStack := symbolStack copy.
	visitedSupertypes := visitedSupertypes copy.
	blocks := blocks collect: [:block | block copyBlock]
]

{ #category : #memo }
SBTSInputParser >> recall: aSymbol evalDo: aBlock [

	| memoEntry recursion |
	memoEntry := (memoizations at: stream position + 1)
		at: aSymbol type
		ifAbsent: [nil].
	recursion := activeRecursion at: stream position + 1.
	
	recursion ifNil: [^ memoEntry].
	
	"symbol not involved in current recursion, deny"
	(memoEntry isNil and: [(recursion second includes: aSymbol type) not and: [aSymbol type ~= recursion first]]) ifTrue: [^ SBTSMemoEntry new parsers: {}].
	
	"symbol involved and hasn't been evaluated yet during this iteration"
	(recursion third includes: aSymbol type) ifTrue: [
		recursion third remove: aSymbol type.
		memoEntry parsers: aBlock value].
	
	^ memoEntry
]

{ #category : #stream }
SBTSInputParser >> remainingSize [

	^ stream originalContents size - stream position
]

{ #category : #stream }
SBTSInputParser >> stream [

	^ stream
]

{ #category : #accessing }
SBTSInputParser >> symbolStack [

	^ symbolStack
]

{ #category : #memo }
SBTSInputParser >> updateStateFrom: aParser symbol: aSymbol [

	symbolStack := aParser symbolStack copy.
	blocks ifNotEmpty: [blocks last slot replaceLast: aSymbol]
]
