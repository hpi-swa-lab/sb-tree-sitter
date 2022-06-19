Class {
	#name : #SBTSNodeText,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'regexString',
		'regex',
		'plainPrefix'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeText >> allChildrenDo: aBlock [

	aBlock value: self
]

{ #category : #'as yet unclassified' }
SBTSNodeText >> allElementsDo: aBlock [

	aBlock value: self
]

{ #category : #copying }
SBTSNodeText >> basicCopy [

	^ super basicCopy
		regexString: self regexString;
		contents: self contents
]

{ #category : #'as yet unclassified' }
SBTSNodeText >> buildEmpty [

	^ {self buildMorphWith: '' slot: (SBTSSlot with: self)}
]

{ #category : #'as yet unclassified' }
SBTSNodeText >> buildEmptyNodes [

	^ {SBTSParseNode kind: #text slot: (SBTSSlot with: self) contents: ''}
]

{ #category : #build }
SBTSNodeText >> buildMorphWith: aString slot: aSlot [

	^ SBTSTextMorph new
		contents: aString;
		slot: aSlot
]

{ #category : #'as yet unclassified' }
SBTSNodeText >> characterValid: aCharacter in: aParser [

	^ self regex matches: aCharacter
]

{ #category : #query }
SBTSNodeText >> childrenForQuery [

	^ #()
]

{ #category : #query }
SBTSNodeText >> childrenForQueryDo: aBlock [

	aBlock value: self
]

{ #category : #copying }
SBTSNodeText >> copy [

	self assert: self isConcrete.
	^ self basicCopy contents: self contents
]

{ #category : #accessing }
SBTSNodeText >> currentTextMorph [

	^ self firstSubmorph
]

{ #category : #printing }
SBTSNodeText >> cursorPositionsDo: aClosure shallow: aBoolean blocks: aStream parent: aBlock [

	(aStream peek isTextMorph and: [aStream peek slot includesParent: self]) ifTrue: [ | block |
		block := aStream next.
		aClosure value: (SBCursorText new
			block: block containingSandblock;
			currentCommand: (SBTextCommand new textMorph: block))]
]

{ #category : #accessing }
SBTSNodeText >> elements [

	^ #()
]

{ #category : #testing }
SBTSNodeText >> hasEqualStructure: aNode [

	^ (super hasEqualStructure: aNode) and: [aNode regexString = self regexString]
]

{ #category : #testing }
SBTSNodeText >> isTSText [

	^ true
]

{ #category : #accessing }
SBTSNodeText >> maxChildren [

	^ 0
]

{ #category : #'as yet unclassified' }
SBTSNodeText >> prefixValidFor: aString [

	^ SBRegexStream tryMatchPrefix: aString regex: regex
]

{ #category : #printing }
SBTSNodeText >> printOn: aStream [

	aStream nextPut: $/.
	aStream nextPutAll: self regexString.
	aStream nextPut: $/
]

{ #category : #accessing }
SBTSNodeText >> regex [

	^ regex
]

{ #category : #accessing }
SBTSNodeText >> regexString [

	^ regexString
]

{ #category : #accessing }
SBTSNodeText >> regexString: aString [

	| link |
	self example: [SBTSNodeText new] args: [{'ab.'}] label: 'simple'.
	self example: [SBTSNodeText new] args: [{'\$'}] label: 'special prefix'.
	regexString := aString.
	regex := aString asRegex.
	"extract all leading elements of the regex that are just plain characters -- used for early feedback during matching"
	link := regex instVarNamed: #matcher.
	plainPrefix := String streamContents: [:s |
		[(link isKindOf: RxmMarker) or: [(link isKindOf: RxmSubstring) or: [link isKindOf: RxmPredicate]]] whileTrue: [
			(link isKindOf: RxmSubstring) ifTrue: [s nextPutAll: (link instVarNamed: #sampleStream) contents].
			(link isKindOf: RxmPredicate) ifTrue: [ | char predicate |
				predicate := link instVarNamed: #predicate.
				predicate basicSize > 0 and: [(char := predicate at: 1) isCharacter ifTrue: [s nextPut: char]]].
			link := link next]]
]

{ #category : #parsing }
SBTSNodeText >> resultsFor: aParser [

	aParser characterModeDuring: [ | start remaining |
		" word-rule? "
		self flag: #todo.
		
		start := aParser position.
		(self regex matchesStreamPrefix: aParser stream) ifTrue: [ | contents |
			contents := aParser stream originalContents
				copyFrom: start + 1
				to: aParser position.
			(contents noneSatisfy: [:c | c isMorph])
				ifTrue: [
					[aParser peek = $ ] whileTrue: [aParser next].
					^ {
						aParser addBlock: (SBTSParseNode kind: #text slot: (SBTSSlot with: self) contents: (String withAll: contents))}]
				ifFalse: [aParser stream position: start]].
		
		remaining := aParser stream upToEnd.
		(SBToggledCode comment: '' active: 1 do: {
			[(remaining noneSatisfy: [:c | c isMorph]) and: [self prefixValidFor: remaining]].
			[plainPrefix beginsWith: remaining]}) ifTrue: [
			^ {
				aParser addBlock: (SBTSParseNode kind: #text slot: (SBTSSlot with: self) contents: (String withAll: (plainPrefix size > remaining size
					ifTrue: [plainPrefix]
					ifFalse: [remaining])))}].
		
		aParser stream position: start.
		^ {}]
]

{ #category : #parsing }
SBTSNodeText >> resultsForBlocks: aParser [

	^ (aParser peekHasText and: [self characterValid: aParser peekText in: aParser])
		ifTrue: [ | text |
			text := aParser peekText.
			{
				aParser addBlock: (SBTSTextMorph new
					contents: text;
					slot: (SBTSSlot with: self))}]
		ifFalse: [(self regex matches: '') ifTrue: [{aParser}] ifFalse: [{}]]
]

{ #category : #parsing }
SBTSNodeText >> takeNodesFrom: aParser [

	^ (aParser atEnd not and: [aParser peek isString and: [self characterValid: aParser peek in: aParser]])
		ifTrue: [
			aParser next.
			{aParser copy addSlot: self}]
		ifFalse: [(self regex matches: '') ifTrue: [{aParser copy}] ifFalse: [{}]]
]

{ #category : #'as yet unclassified' }
SBTSNodeText >> traverseBlocks: aStream do: aBlock [

	(aStream peek isTextMorph and: [aStream peek slot includesParent: self]) ifTrue: [ | block |
		block := aStream next.
		aBlock value: block]
]

{ #category : #testing }
SBTSNodeText >> validFor: aString [

	^ regex matches: aString
]

{ #category : #printing }
SBTSNodeText >> writeSourceOn: aStream indent: aNumber [

	aStream nextPutAll: self contents
]
