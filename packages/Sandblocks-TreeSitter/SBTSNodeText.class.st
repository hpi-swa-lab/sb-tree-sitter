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

{ #category : #copying }
SBTSNodeText >> basicCopy [

	^ super basicCopy
		regexString: self regexString;
		contents: self contents
]

{ #category : #'as yet unclassified' }
SBTSNodeText >> buildEmpty [

	^ {self buildMorphWith: '' slot: (SBTSSlot new addNode: self)}
]

{ #category : #build }
SBTSNodeText >> buildMorphWith: aString slot: aSlot [

	^ SBTSTextMorph new
		contents: aString;
		slot: aSlot
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
SBTSNodeText >> cursorPositionsDo: aClosure shallow: aBoolean blocks: aCollection parent: aBlock [

	aCollection
		detect: [:block | block isTextMorph and: [block slot includesParent: self]]
		ifFound: [:b |
			b containingSandblock startInputCommand ifNotNil: [:command |
				aClosure value: (SBCursorText new
					block: b containingSandblock;
					currentCommand: command)]]
		ifNone: []
]

{ #category : #accessing }
SBTSNodeText >> maxChildren [

	^ 0
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
	self example: [SBTSNodeText new] args: [{'ab.'}] label: 'example'.
	regexString := aString.
	regex := aString asRegex.
	
	"extract all leading elements of the regex that are just plain characters -- used for early feedback during matching"
	link := regex instVarNamed: #matcher.
	plainPrefix := String streamContents: [:s |
		[(link isKindOf: RxmMarker) or: [link isKindOf: RxmSubstring]] whileTrue: [
			(link isKindOf: RxmSubstring) ifTrue: [s nextPutAll: (link instVarNamed: #sampleStream) contents].
			link := link next]]
]

{ #category : #parsing }
SBTSNodeText >> resultsFor: aParser [

	| start remaining |
	" word-rule? "
	self flag: #todo.
	
	start := aParser position.
	(self regex matchesStreamPrefix: aParser stream) ifTrue: [
		^ {
			aParser copy addBlock: (SBTSTextMorph new
				slot: (SBTSSlot new addNode: self);
				contents: (aParser stream originalContents copyFrom: start + 1 to: aParser position))}].
	
	remaining := aParser stream upToEnd.
	(plainPrefix beginsWith: remaining) ifTrue: [
		^ {
			aParser copy addBlock: (SBTSTextMorph new
				slot: (SBTSSlot new addNode: self);
				contents: plainPrefix)}].
	
	aParser stream position: start.
	^ #noMatch
]

{ #category : #parsing }
SBTSNodeText >> takeNodesFrom: aParser [

	(aParser atEnd or: [aParser peek isString not]) ifTrue: [^ (regex matches: '') ifTrue: [{aParser copy}] ifFalse: [#noMatch]].
	^ (self regex matches: aParser peek)
		ifTrue: [
			aParser next.
			{aParser copy addSlot: self}]
		ifFalse: [#noMatch]
]

{ #category : #'as yet unclassified' }
SBTSNodeText >> validFor: aString [

	^ regex matches: aString
]

{ #category : #printing }
SBTSNodeText >> writeSourceOn: aStream indent: aNumber [

	aStream nextPutAll: self contents
]
