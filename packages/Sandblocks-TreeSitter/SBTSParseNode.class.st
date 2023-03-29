Class {
	#name : #SBTSParseNode,
	#superclass : #Object,
	#instVars : [
		'contents',
		'kind',
		'slot',
		'lastConstructed'
	],
	#category : #'Sandblocks-TreeSitter-Parser'
}

{ #category : #'as yet unclassified' }
SBTSParseNode class >> kind: aSymbol slot: aSlot contents: anObject [

	^ self basicNew kind: aSymbol slot: aSlot contents: anObject
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> allChildrenDo: aBlock [

	kind = #block ifTrue: [contents do: [:c | c allChildrenDo: aBlock]].
	aBlock value: self
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> buildCopyEmbeds: aBoolean [

	| morph |
	morph := kind caseOf: {
		[#block] -> [
			SBTSBlock new
				addAllMorphs: (contents collect: [:b | b buildCopyEmbeds: aBoolean]);
				slot: slot].
		[#unknown] -> [SBTSUnknownBlock new slot: slot].
		[#label] -> [
			SBTSLabel new
				contents: contents;
				slot: slot].
		[#text] -> [
			SBTSTextMorph new
				contents: contents;
				slot: slot].
		[#editableLabel] -> [
			SBTSTextMorph new
				fixedText: (contents size < slot firstNode label size
					ifTrue: [slot firstNode label]
					ifFalse: [nil]);
				contents: contents;
				slot: slot].
		[#blockEmbed] -> [(aBoolean ifTrue: [contents copyBlock] ifFalse: [contents]) slot: slot]}.
	self lastConstructed ifTrue: [morph setProperty: #lastConstructed toValue: true].
	^ morph
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> buildWith: aParser [

	^ self buildCopyEmbeds: aParser copyEmbeds
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> characterAndBlockCount [

	^ kind
		caseOf: {
			[#block] -> [contents inject: 1 into: [:sum :node | sum + node characterAndBlockCount]].
			[#text] -> ["give a small penalty to text nodes such that we prefer label nodes"
			contents size + 0.5].
			[#editableLabel] -> [slot firstNode label size].
			[#label] -> [contents size]}
		otherwise: [1]
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> children [

	^ kind = #block ifTrue: [contents] ifFalse: [{}]
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> containingNodeIn: aParser [

	^ (kind = #block or: [kind = #blockEmbed or: [kind = #unknown]])
		ifTrue: [self]
		ifFalse: [
			aParser blocks do: [:p | (p parentOf: self) ifNotNil: [:parent | ^ parent]].
			nil]
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> contents [

	^ contents
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> contents: anObject [

	contents := anObject
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> effectiveChildren [

	^ kind
		caseOf: {
			[#block] -> [contents].
			[#blockEmbed] -> [contents childSandblocks]}
		otherwise: [{}]
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> firstDeepChild [

	^ self children ifEmpty: [self] ifNotEmpty: [:c | c first firstDeepChild]
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> kind [

	^ kind
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> kind: aSymbol slot: aSlot contents: anObject [

	self assert: (aSymbol ~= #block or: [anObject allSatisfy: [:m | m isKindOf: self class]]).
	lastConstructed := false.
	kind := aSymbol.
	slot := aSlot.
	contents := anObject
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> lastConstructed [

	^ lastConstructed
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> lastConstructed: aBoolean [

	lastConstructed := aBoolean
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> lastDeepChild [

	^ self children ifEmpty: [self] ifNotEmpty: [:c | c last lastDeepChild]
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> parentChainIn: aParser [

	| chain current leaf |
	leaf := self typeOrAlias.
	current := self.
	[current typeOrAlias isNil and: [current notNil]] whileTrue: [
		current := aParser parentOf: current.
		current ifNil: [^ {{}. ''}].
		leaf := current typeOrAlias].
	
	chain := OrderedCollection new.
	[current notNil] whileTrue: [(current := aParser parentOf: current) ifNotNil: [chain add: current typeOrAlias]].
	SBToggledCode comment: '' active: 0 do: {
		[
			[current notNil] whileTrue: [
				current slot allParentsDo: [:sym | | first |
					first ifTrue: [first := false] ifFalse: [
						(sym isTSSymbol and: [sym isSuperType not]) ifTrue: [chain add: sym type].
						sym isTSAlias ifTrue: [chain add: sym alias]]].
				current := aParser parentOf: current]]}.
	^ {chain. leaf}
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> parentOf: aNode [

	kind = #block ifTrue: [
		contents do: [:c |
			aNode = c ifTrue: [^ self].
			(c parentOf: aNode) ifNotNil: [:p | ^ p]]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> postCopy [

	kind = #block ifTrue: [contents := contents copy]
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> printOn: aStream [

	aStream nextPutAll: self className.
	aStream nextPut: $(.
	aStream nextPutAll: (self type ifNil: ['']).
	aStream nextPut: $)
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> recursiveNodeCount [

	^ kind = #block
		ifTrue: [contents inject: 1 into: [:sum :node | sum + node recursiveNodeCount]]
		ifFalse: [1]
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> slot [

	^ slot
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> slot: aSlot [

	slot := aSlot
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> type [

	^ slot firstNode type
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> typeOrAlias [

	^ self slot type ifNil: [self slot alias]
]
