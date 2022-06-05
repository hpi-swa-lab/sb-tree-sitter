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
SBTSParseNode >> buildWith: aParser [

	| morph |
	morph := kind caseOf: {
		[#block] -> [
			SBTSBlock new
				addAllMorphs: (contents collect: [:b | b buildWith: aParser]);
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
		[#blockEmbed] -> [contents copyBlock slot: slot]}.
	self lastConstructed ifTrue: [morph setProperty: #lastConstructed toValue: true].
	^ morph
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
SBTSParseNode >> firstDeepChild [

	^ self children ifEmpty: [self] ifNotEmpty: [:c | c first firstDeepChild]
]

{ #category : #'as yet unclassified' }
SBTSParseNode >> isLabel [

	^ kind = #label
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
SBTSParseNode >> parentChainIn: aParser [

	| chain current leaf |
	leaf := self type.
	current := self.
	leaf ifNil: [
		current := aParser parentOf: current.
		leaf := current type, ',', leaf].
	
	chain := ''.
	[current notNil] whileTrue: [(current := aParser parentOf: current) ifNotNil: [chain := current type, ',', chain]].
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
