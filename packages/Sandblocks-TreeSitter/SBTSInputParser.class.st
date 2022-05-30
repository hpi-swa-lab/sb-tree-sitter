Class {
	#name : #SBTSInputParser,
	#superclass : #Object,
	#instVars : [
		'stream',
		'memoizations',
		'visitedSupertypes',
		'blocks',
		'symbolStack',
		'activeRecursion',
		'allowIncomplete',
		'wasIncomplete'
	],
	#category : #'Sandblocks-TreeSitter-Parser'
}

{ #category : #blocks }
SBTSInputParser >> addBlock: aBlock [

	blocks add: aBlock.
	self atEnd ifTrue: [aBlock setProperty: #lastConstructed toValue: true]
]

{ #category : #blocks }
SBTSInputParser >> addBlocks: aCollection [

	blocks addAll: aCollection.
	(self atEnd and: [aCollection notEmpty]) ifTrue: [
		aCollection last setProperty: #lastConstructed toValue: true]
]

{ #category : #blocks }
SBTSInputParser >> addEmptyBlocks: aCollection [

	blocks addAll: aCollection.
	aCollection ifNotEmpty: [wasIncomplete := true]
]

{ #category : #accessing }
SBTSInputParser >> allowIncomplete [

	^ allowIncomplete
]

{ #category : #accessing }
SBTSInputParser >> allowIncomplete: aBoolean [

	allowIncomplete := aBoolean
]

{ #category : #stream }
SBTSInputParser >> atEnd [

	^ stream atEnd
]

{ #category : #blocks }
SBTSInputParser >> basicAddBlocks: aCollection [

	blocks addAll: aCollection
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
SBTSInputParser >> checkIntegrity [

	memoizations do: [:list | list keysAndValuesDo: [:sym :memos | self assert: (memos isLeftRecursion or: [memos parsers allSatisfy: [:p | (p blocks first factory isBlockInlinedInParent: sym) or: [sym = p blocks first slot lastNode type]]])]]
]

{ #category : #'as yet unclassified' }
SBTSInputParser >> getLastConstructed [

	^ self getLastConstructed: self blocks
]

{ #category : #'as yet unclassified' }
SBTSInputParser >> getLastConstructed: aCollection [

	| ret |
	ret := nil.
	aCollection do: [:b | b allMorphsDo: [:m | m valueOfProperty: #lastConstructed ifPresentDo: [:a | ret := m]]].
	^ ret
]

{ #category : #'initialize-release' }
SBTSInputParser >> initialize [

	super initialize.
	
	visitedSupertypes := Set new.
	blocks := OrderedCollection new.
	wasIncomplete := false.
	allowIncomplete := true
]

{ #category : #memo }
SBTSInputParser >> memoizationFor: aSymbol ifAbsentPut: aBlock [

	| index |
	index := stream position + 1.
	^ ((memoizations at: index) at: aSymbol type ifAbsent: [nil])
		ifNil: [ | lr results |
			lr := self memoizeRecursionMarkerAt: index for: aSymbol.
			symbolStack add: aSymbol type.
			results := aBlock value.
			self memoizeBlocks: results at: index for: aSymbol.
			(SBToggledCode comment: '' active: 1 do: {
				[true].
				["if we already have at least one result that got us to the end, abort. Definitely wrong, but easy workaround for now."
				results noneSatisfy: [:r | r position = memoizations size]]})
				ifTrue: [
					lr ifRecursionDetected: [
						activeRecursion at: index put: lr.
						lr newIteration.
						results := SBToggledCode
							comment: ''
							active: 1
							do: {[aBlock value]. [aBlock value, results]}.
						self memoizeBlocks: results at: index for: aSymbol.
						activeRecursion at: index put: nil]]
				ifFalse: [].
			symbolStack remove: aSymbol type.
			results collect: [:memo | memo adapt: self for: aSymbol]]
		ifNotNil: [:memoEntry |
			((activeRecursion at: index)
				ifNotNil: [:recur |
					recur
						tryExpandSymbol: aSymbol
						do: aBlock
						otherwise: [memoEntry getBlocksOrMarkRecursionFrom: aSymbol stack: symbolStack max: memoizations size]]
				ifNil: [memoEntry getBlocksOrMarkRecursionFrom: aSymbol stack: symbolStack max: memoizations size]) collect: [:memo | memo adapt: self for: aSymbol]]
]

{ #category : #memo }
SBTSInputParser >> memoizeBlocks: aCollection at: aNumber for: aSymbol [

	((memoizations at: aNumber) at: aSymbol type)
		parsers: aCollection
		symbol: aSymbol
]

{ #category : #memo }
SBTSInputParser >> memoizeRecursionMarkerAt: aNumber for: aSymbol [

	| lr |
	lr := SBTSRecursion new.
	(memoizations at: aNumber) at: aSymbol type put: (SBTSMemoEntry new lr: lr).
	^ lr
]

{ #category : #stream }
SBTSInputParser >> next [

	^ stream next
]

{ #category : #'as yet unclassified' }
SBTSInputParser >> normalizeResults2: aCollection query: aString [

	| results transitionPairs |
	SBToggledCode comment: '' active: 0 do: {[^ aCollection]. [self halt]}.
	results := (SBToggledCode comment: '' active: 1 do: {
		[(aCollection groupBy: [:candidate | candidate getLastConstructed ifNotNil: [:m | (m containingSandblock ifNotNil: #type ifNil: [m]) ifNil: [m slot firstNode]]]) values collect: [:candidates | (candidates sort: [:a :b | a sortsBefore: b]) first]].
		[aCollection].
		[
			(aCollection anySatisfy: [:candidate | candidate wasIncomplete not])
				ifTrue: [aCollection select: [:candidate | candidate wasIncomplete not]]
				ifFalse: [aCollection]]}) collect: [:candidate | candidate blocks].
	
	results ifNotEmpty: [
		transitionPairs := results anyOne first factory transitionPairs.
		results := results select: [:blocksA | results noneSatisfy: [:blocksB | transitionPairs anySatisfy: [:pair | pair key = blocksB first type and: [pair value = blocksA first type]]]]].
	
	^ results
]

{ #category : #blocks }
SBTSInputParser >> normalizeResults: aCollection query: aString [

	| strings transitionPairs remaining hasAnyKeywords unique final |
	"if we have a simple single-block result, see if some other results we found could be derived from that simple result. Heuristic is that if the source string starts the same as another block and we contain the innermost slot of that prefix, we can derive it"
	unique := aCollection.
	unique ifEmpty: [^ unique asArray].
	
	strings := IdentityDictionary new.
	
	unique do: [:result |
		strings
			at: result
			put: (String streamContents: [:s | result do: [:r | r writeSourceOn: s indent: 0 forCompare: true]])].
	
	transitionPairs := unique anyOne first factory transitionPairs.
	
	remaining := unique select: [:result | unique noneSatisfy: [:other | result ~~ other and: [(((strings at: result) beginsWith: (strings at: other)) and: [(strings at: result) size ~= (strings at: other) size and: [self blocks: result contain: other]]) or: [transitionPairs anySatisfy: [:pair | pair key = other first type and: [pair value = result first type]]]]]].
	
	hasAnyKeywords := remaining anySatisfy: [:r | | node |
		node := r first firstDeepSubmorph slot firstNode.
		node isTSLabel and: [ | index |
			"only disambiguate keywords if they were terminated with a space, otherwise we may break typing e.g. `forage` because we abort with just one result after typing `for`"
			index := aString indexOfSubCollection: node label.
			index > 0 and: [(aString at: index + node label size ifAbsent: [$x]) = $ ]]].
	
	remaining := hasAnyKeywords
		ifTrue: [remaining select: [:r | r first firstDeepSubmorph slot firstNode isTSLabel]]
		ifFalse: [remaining].
	
	"testAssignmentPattern produces exact duplicates -- this is a workaround for this"
	final := OrderedCollection new.
	remaining do: [:result | (final noneSatisfy: [:other | (strings at: result) = (strings at: other) and: [self blocks: result contain: other]]) ifTrue: [final add: result]].
	
	^ final
]

{ #category : #query }
SBTSInputParser >> optionsFor: aTSBlock given: aString before: aCollection after: anotherCollection [

	^ self
		optionsForTemplate: aTSBlock slot transitionRoot
		given: aString
		before: aCollection
		after: anotherCollection
]

{ #category : #query }
SBTSInputParser >> optionsForTemplate: aNode given: aString [

	^ self optionsForTemplate: aNode given: aString before: {} after: {}
]

{ #category : #query }
SBTSInputParser >> optionsForTemplate: aNode given: aString before: aCollection after: anotherCollection [

	stream := SBTSBlockStringStream on: aCollection, aString asArray, anotherCollection.
	memoizations := (1 to: stream originalContents size) collect: [:i | IdentityDictionary new].
	activeRecursion := Array new: stream originalContents size withAll: nil.
	symbolStack := OrderedCollection new.
	
	^ self normalizeResults2: ((aNode resultsFor: self) select: [:parser | parser atEnd]) query: aString
]

{ #category : #query }
SBTSInputParser >> optionsForTemplate: aNode givenBlock: aBlock [

	^ self optionsForTemplate: aNode given: '' before: {aBlock} after: {}
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
	(memoEntry isNil and: [(recursion second includes: aSymbol type) not and: [aSymbol type ~= recursion first]]) ifTrue: [^ SBTSMemoEntry new parsers: {} symbol: aSymbol].
	
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

{ #category : #'as yet unclassified' }
SBTSInputParser >> sortsBefore: aParser [

	| comp ours theirs |
	ours := self getLastConstructed containingSandblock ifNil: [self getLastConstructed].
	theirs := aParser getLastConstructed containingSandblock ifNil: [aParser getLastConstructed].
	comp := (ours slot precedenceAround: ours) compareTo: (theirs slot precedenceAround: theirs).
	"precedence compare doesnt work yet..."
	self flag: #fixme.
	^ (comp = 0 or: [true])
		ifTrue: [(self blocks collect: [:b | b recursiveSubmorphCount]) sum <= (aParser blocks collect: [:b | b recursiveSubmorphCount]) sum]
		ifFalse: [comp > 0]
]

{ #category : #stream }
SBTSInputParser >> stream [

	^ stream
]

{ #category : #accessing }
SBTSInputParser >> symbolStack [

	^ symbolStack
]

{ #category : #accessing }
SBTSInputParser >> wasIncomplete [

	^ wasIncomplete
]

{ #category : #accessing }
SBTSInputParser >> wasIncomplete: aBoolean [

	wasIncomplete := aBoolean
]
