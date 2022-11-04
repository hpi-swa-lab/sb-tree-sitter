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
SBTSNodeText >> allChildrenDo: aBlock visited: aSet [

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

	(aStream atEnd not and: [aStream peek isTextMorph and: [aStream peek slot includesParent: self]]) ifTrue: [ | block |
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

{ #category : #printing }
SBTSNodeText >> labelPrintOn: aStream [

	aStream nextPut: $/.
	aStream nextPutAll: self regexString.
	aStream nextPut: $/
]

{ #category : #accessing }
SBTSNodeText >> maxChildren [

	^ 0
]

{ #category : #'as yet unclassified' }
SBTSNodeText >> prefixValidFor: aString in: aSiblingsCollection [

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
			((contents noneSatisfy: [:c | c isMorph]) and: [
				self flag: #fixme.
				"way too strict, we are denying any text node that has the same contents as a keyword. realistically, many languages allow using keywords in places where the corresponding construct does not make sense."
				self factory isNil or: [(self factory keywords includes: (String withAll: contents)) not]])
				ifTrue: [
					[aParser peek isCharacter and: [aParser peek isSeparator]] whileTrue: [aParser next].
					^ {
						aParser addBlock: (SBTSParseNode kind: #text slot: (SBTSSlot with: self) contents: (String withAll: contents))}]
				ifFalse: [aParser stream position: start]].
		
		remaining := aParser stream upToEnd.
		(SBToggledCode comment: '' active: 2 do: {
			[false].
			[aParser matchFullToken not and: [(remaining noneSatisfy: [:c | c isMorph]) and: [self prefixValidFor: remaining in: aParser blocks]]].
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

	| success |
	success := [:text |
		{
			aParser addBlock: (SBTSTextMorph new
				contents: text;
				slot: (SBTSSlot with: self))}].
	
	^ (aParser peekHasText and: [self characterValid: aParser peekText in: aParser blocks])
		ifTrue: [success value: aParser text]
		ifFalse: [ | uncaptured |
			uncaptured := aParser peekUncapturedText.
			uncaptured
				ifNotEmpty: [
					(self characterValid: uncaptured in: aParser blocks)
						ifTrue: [success value: aParser uncapturedText]
						ifFalse: [{}]]
				ifEmpty: [(self regex matches: '') ifTrue: [{aParser}] ifFalse: [{}]]]
]

{ #category : #'as yet unclassified' }
SBTSNodeText >> traverseBlocks: aStream do: aBlock [

	(aStream peek isTextMorph and: [aStream peek slot includesParent: self]) ifTrue: [ | block |
		block := aStream next.
		aBlock value: block]
]

{ #category : #testing }
SBTSNodeText >> validFor: aString in: aSiblingsCollection [

	^ regex matches: aString
]

{ #category : #printing }
SBTSNodeText >> writeSourceOn: aStream indent: aNumber [

	aStream nextPutAll: self contents
]
