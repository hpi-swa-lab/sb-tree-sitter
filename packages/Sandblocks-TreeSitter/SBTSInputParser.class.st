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
		'matchFullToken',
		'wasIncomplete',
		'nodeCountCache',
		'copyEmbeds',
		'lastConstructedCache',
		'validCondition',
		'siblings'
	],
	#category : #'Sandblocks-TreeSitter-Parser'
}

{ #category : #'as yet unclassified' }
SBTSInputParser >> adaptSlotsFor: aCollectionOfBlock to: aNode [

	| results |
	self allowIncomplete: false.
	results := self optionsForTemplate: aNode transitionRoot givenBlocks: aCollectionOfBlock.
	self assert: results size = 1.
	^ results anyOne
]

{ #category : #blocks }
SBTSInputParser >> addBlock: aBlock [

	blocks add: aBlock.
	self atEndOfInput ifTrue: [aBlock lastConstructed: true]
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

{ #category : #'as yet unclassified' }
SBTSInputParser >> atEndOfInput [

	stream position + 1
		to: stream size
		do: [:i | (stream contents at: i) isCharacter ifTrue: [^ false]].
	^ true
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

{ #category : #query }
SBTSInputParser >> canInsert: aBlock for: aNode [

	self allowIncomplete: false.
	^ (self rawOptionsForTemplate: aNode transitionRoot given: '' before: {aBlock} after: {}) notEmpty
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

{ #category : #accessing }
SBTSInputParser >> copyEmbeds [

	^ copyEmbeds
]

{ #category : #accessing }
SBTSInputParser >> copyEmbeds: aBoolean [

	copyEmbeds := aBoolean
]

{ #category : #'initialize-release' }
SBTSInputParser >> initialize [

	super initialize.
	
	visitedSupertypes := Set new.
	blocks := OrderedCollection new.
	wasIncomplete := false.
	allowIncomplete := true.
	matchFullToken := false.
	copyEmbeds := true
]

{ #category : #'as yet unclassified' }
SBTSInputParser >> is: aCollection orderedSupersetOf: anotherCollection [

	| haystack search |
	self example: [SBTSInputParser new] args: [{#(#a #b #c). #(#a #d)}] label: 'fail'.
	self example: [SBTSInputParser new] args: [{#(#x #a #b #c). #(#a #c)}] label: 'success'.
	haystack := aCollection readStream.
	search := anotherCollection readStream.
	[haystack atEnd] whileFalse: [haystack next = search peek ifTrue: [search next]].
	^ search atEnd
]

{ #category : #'as yet unclassified' }
SBTSInputParser >> isCurrentlyRecursingFor: aSymbol [

	^ ((activeRecursion at: stream position + 1) ifNotNil: #head) = aSymbol type
]

{ #category : #accessing }
SBTSInputParser >> lastConstructed [

	| ret |
	lastConstructedCache ifNotNil: [^ lastConstructedCache].
	ret := nil.
	blocks do: [:b | b allChildrenDo: [:m | m lastConstructed ifTrue: [ret := m]]].
	^ lastConstructedCache := ret
]

{ #category : #'as yet unclassified' }
SBTSInputParser >> lastConstructedChain [

	^ self lastConstructed ifNotNil: [:l | l parentChainIn: self] ifNil: [{''. ''}]
]

{ #category : #stream }
SBTSInputParser >> limit [

	^ stream originalContents size
]

{ #category : #'as yet unclassified' }
SBTSInputParser >> matchFullToken [

	^ matchFullToken
]

{ #category : #'as yet unclassified' }
SBTSInputParser >> matchFullToken: aboolean [

	matchFullToken := aboolean
]

{ #category : #memo }
SBTSInputParser >> memoizationFor: aSymbol ifAbsentPut: aBlock [

	| index expand |
	expand := [ | res |
		symbolStack add: aSymbol.
		res := aBlock value.
		symbolStack remove: aSymbol.
		res].
	index := stream position + 1.
	^ ((memoizations at: index) at: aSymbol type ifAbsent: [nil])
		ifNil: [ | lr results |
			lr := self memoizeRecursionMarkerAt: index for: aSymbol.
			results := expand value.
			self memoizeBlocks: results at: index for: aSymbol.
			lr ifRecursionDetected: [ | lastMax |
				lastMax := 0.
				activeRecursion at: index put: lr.
				[
					SBToggledCode comment: '' active: 2 do: {
						[true].
						[results notEmpty and: [(results collect: [:r | r position]) max > lastMax]].
						[(results noneSatisfy: [:r | r position = self limit]) and: [results notEmpty]]}] whileTrue: [
					lastMax := (results collect: [:r | r position]) max.
					lr newIteration.
					results := expand value.
					self memoizeBlocks: results at: index for: aSymbol].
				activeRecursion at: index put: nil].
			results collect: [:memo | memo adapt: self for: aSymbol]]
		ifNotNil: [:memoEntry |
			(activeRecursion at: index)
				ifNotNil: [:recur |
					recur
						tryExpandSymbol: aSymbol
						do: [ | all |
							all := memoEntry parsers, expand value.
							self memoizeBlocks: all at: index for: aSymbol.
							all collect: [:memo | memo adapt: self for: aSymbol]]
						otherwise: [memoEntry getBlocksOrMarkRecursionFrom: aSymbol stack: symbolStack parser: self]]
				ifNil: [memoEntry getBlocksOrMarkRecursionFrom: aSymbol stack: symbolStack parser: self]]
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

{ #category : #'as yet unclassified' }
SBTSInputParser >> merge: candidate intoGroups: groups [

	| new newEntry |
	newEntry := OrderedCollection with: candidate.
	new := candidate lastConstructedChain.
	groups keys do: [:existing |
		(existing second = new second and: [self is: new first orderedSupersetOf: existing first]) ifTrue: [^ (groups at: existing) add: candidate].
		(existing second = new second and: [self is: existing first orderedSupersetOf: new first]) ifTrue: [
			newEntry addAll: (groups at: existing).
			groups removeKey: existing]].
	groups at: new put: newEntry
]

{ #category : #stream }
SBTSInputParser >> next [

	^ stream next
]

{ #category : #'as yet unclassified' }
SBTSInputParser >> normalizeResults2: aCollection query: aString factory: aFactory [

	| results transitionPairs hasAnyKeywords groups |
	SBToggledCode comment: '' active: 0 do: {[^ aCollection collect: #blocks]. [self halt]}.
	groups := Dictionary new.
	aCollection do: [:candidate | self merge: candidate intoGroups: groups].
	results := groups values collect: [:candidates | | min |
		min := candidates first.
		candidates allButFirstDo: [:c | (c sortsBefore: min) ifTrue: [min := c]].
		min blocks].
	
	results ifNotEmpty: [
		transitionPairs := aFactory language transitionPairs.
		results := results select: [:blocksA | results noneSatisfy: [:blocksB | transitionPairs anySatisfy: [:pair | pair key = blocksB first type and: [pair value = blocksA first type]]]]].
	
	hasAnyKeywords := results anySatisfy: [:r | | node block |
		block := r first firstDeepChild.
		(node := block slot firstNode) isTSLabel and: [ | index |
			"only disambiguate keywords if they were terminated with a non-word character, otherwise we may break typing e.g. `forage` because we abort with just one result after typing `for`"
			index := aString indexOfSubCollection: node label.
			index > 0 and: [(aString at: index + node label size ifAbsent: [$x]) isAlphaNumeric not]]].
	
	results := hasAnyKeywords
		ifTrue: [results select: [:r | r first firstDeepChild slot firstNode isTSLabel]]
		ifFalse: [results].
	
	^ results sort: [:a :b | a first characterAndBlockCount <= b first characterAndBlockCount]
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

	^ (self
		normalizeResults2: (self rawOptionsForTemplate: aNode given: aString before: aCollection after: anotherCollection)
		query: aString
		factory: aNode factory) collect: [:parseNodes | parseNodes collect: [:p | p buildWith: self]]
]

{ #category : #query }
SBTSInputParser >> optionsForTemplate: aNode givenBlocks: aCollection [

	^ self optionsForTemplate: aNode given: '' before: aCollection after: {}
]

{ #category : #'as yet unclassified' }
SBTSInputParser >> parentOf: aNode [

	self blocks do: [:p | (p parentOf: aNode) ifNotNil: [:parent | ^ parent]].
	^ nil
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
	blocks := blocks collect: [:block | block copy]
]

{ #category : #query }
SBTSInputParser >> rawOptionsForTemplate: aNode given: aString before: aCollection after: anotherCollection [

	stream := SBTSBlockStringStream on: aCollection, aString asArray, anotherCollection.
	memoizations := (1 to: stream originalContents size) collect: [:i | IdentityDictionary new].
	activeRecursion := Array new: stream originalContents size withAll: nil.
	symbolStack := OrderedCollection with: aNode.
	
	^ (aNode resultsFor: self) select: [:parser | self validCondition value: parser]
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

{ #category : #accessing }
SBTSInputParser >> recursiveNodeCount [

	nodeCountCache ifNotNil: [^ nodeCountCache].
	^ nodeCountCache := self blocks
		inject: 0
		into: [:sum :block | sum + block recursiveNodeCount]
]

{ #category : #stream }
SBTSInputParser >> remainingSize [

	^ stream originalContents size - stream position
]

{ #category : #'as yet unclassified' }
SBTSInputParser >> shouldAbortIncompleteExpansion [
	"check if we want to allow an incomplete result at the moment. do not allow it, if:
- we have a memoized result that consumed all our input, and
- we are currently recursing

e.g., this will block from expanding to 2+_ if our input was just a 2"

	self blocks ifEmpty: [^ true].
	
	memoizations withIndexDo: [:memo :index |
		memo
			at: self blocks last type
			ifPresent: [:b | ((b anyResultIsAtEndFor: self) and: [(activeRecursion at: index) notNil]) ifTrue: [^ true]]
			ifAbsent: [false]].
	
	^ false
]

{ #category : #accessing }
SBTSInputParser >> siblings [

	^ siblings ifNil: [blocks]
]

{ #category : #accessing }
SBTSInputParser >> siblings: aCollection [
	"can set this for context-sensitive text nodes to gather information"

	siblings := aCollection
]

{ #category : #'as yet unclassified' }
SBTSInputParser >> sortsBefore: aParser [

	| comp ours theirs ourLast theirLast |
	theirLast := aParser lastConstructed.
	ourLast := self lastConstructed.
	ours := ((ourLast ifNotNil: [ourLast containingNodeIn: self]) ifNil: [ourLast]) ifNil: [self blocks first].
	theirs := ((theirLast ifNotNil: [theirLast containingNodeIn: aParser]) ifNil: [theirLast]) ifNil: [aParser blocks first].
	"precedence compare doesnt work yet..."
	self flag: #fixme.
	comp := SBToggledCode
		comment: ''
		active: 1
		do: {[0]. [(ours slot precedenceAround: ours) compareTo: (theirs slot precedenceAround: theirs)]}.
	^ comp = 0 ifTrue: [self recursiveNodeCount <= aParser recursiveNodeCount] ifFalse: [comp > 0]
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
SBTSInputParser >> trimResults: aCollection [

	^ aCollection reject: #wasIncomplete
]

{ #category : #accessing }
SBTSInputParser >> validCondition [

	^ validCondition ifNil: [[:p | p atEnd]]
]

{ #category : #accessing }
SBTSInputParser >> validCondition: aBlock [

	validCondition := aBlock
]

{ #category : #accessing }
SBTSInputParser >> wasIncomplete [

	^ wasIncomplete
]

{ #category : #accessing }
SBTSInputParser >> wasIncomplete: aBoolean [

	wasIncomplete := aBoolean
]
