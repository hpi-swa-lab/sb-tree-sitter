Class {
	#name : #SBTSNodeBase,
	#superclass : #SBBlock,
	#instVars : [
		'field',
		'factory',
		'parser',
		'isConcrete',
		'slot',
		'parent',
		'children'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #accessing }
SBTSNodeBase >> access [

	^ SBTSFieldAccessor new element: self
]

{ #category : #hierarchy }
SBTSNodeBase >> addAllChildren: aCollection [

	aCollection do: [:c | self addChild: c]
]

{ #category : #hierarchy }
SBTSNodeBase >> addChild: aNode [

	self assert: self isConcrete.
	self assert: aNode isConcrete.
	self assert: self children size + 1 <= self maxChildren.
	
	aNode parent: self.
	children add: aNode.
	parser := aNode parser
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> allChildrenDo: aBlock [

	^ self subclassResponsibility
]

{ #category : #hierarchy }
SBTSNodeBase >> allSuperTypesDo: aBlock [

	self owner ifNotNil: [:o | o allSuperTypesDo: aBlock]
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> andParentsDo: aBlock [

	| current |
	current := self.
	[aBlock value: current] doWhileTrue: [(current := current parent) notNil]
]

{ #category : #copying }
SBTSNodeBase >> basicCopy [

	| copy |
	copy := self class new
		slot: slot;
		field: field;
		factory: factory;
		parser: parser;
		isConcrete: isConcrete.
	self isConcrete ifTrue: [copy ensureLayout].
	^ copy
]

{ #category : #accessing }
SBTSNodeBase >> basicField [

	^ field
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> buildEmpty [

	^ self subclassResponsibility
]

{ #category : #hierarchy }
SBTSNodeBase >> child [

	self assert: self children size = 1.
	^ self children first
]

{ #category : #hierarchy }
SBTSNodeBase >> childSymbolsDo: aBlock includeInlined: aBoolean [

	self submorphsDo: [:morph |
		morph isTSNode ifTrue: [
			(morph isTSSymbol and: [aBoolean or: [morph inline not]])
				ifTrue: [aBlock value: morph]
				ifFalse: [morph childSymbolsDo: aBlock includeInlined: aBoolean]]]
]

{ #category : #hierarchy }
SBTSNodeBase >> children [

	^ children
]

{ #category : #query }
SBTSNodeBase >> childrenForQuery [

	^ Array streamContents: [:s | self submorphsDo: [:m | m isTSNode ifTrue: [m childrenForQueryDo: [:child | s nextPut: child]]]]
]

{ #category : #testing }
SBTSNodeBase >> compatibleWithType: aSymbol [

	^ factory type: self type compatibleWith: aSymbol
]

{ #category : #'inlining support' }
SBTSNodeBase >> containingSandblock [

	^ self inline ifTrue: [self owner ifNotNil: #containingSandblock] ifFalse: [self]
]

{ #category : #hierarchy }
SBTSNodeBase >> containingSymbol [

	self owner ifNil: [^ nil].
	^ self owner isTSNode ifTrue: [self owner containingSymbol] ifFalse: [nil]
]

{ #category : #copying }
SBTSNodeBase >> copy [

	self assert: self isConcrete.
	^ self basicCopy addAllChildren: (self children collect: [:s | s copy])
]

{ #category : #copying }
SBTSNodeBase >> copyBlock [

	^ self copy
]

{ #category : #accessing }
SBTSNodeBase >> currentTextMorph [

	self submorphsDo: [:m | (m isTSNode and: [m inline]) ifTrue: [m currentTextMorph ifNotNil: [:t | ^ t]]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> cursorPositionsDo: aClosure shallow: aBoolean blocks: aCollection parent: aBlock [

	^ self subclassResponsibility
]

{ #category : #initialization }
SBTSNodeBase >> ensureLayout [

	self layoutPolicy ifNil: [
		self
			hResizing: #shrinkWrap;
			vResizing: #shrinkWrap;
			layoutPolicy: SBAlgebraLayout new;
			listDirection: #leftToRight;
			color: Color transparent;
			cellGap: 2;
			layoutInset: 0;
			cellPositioning: #center;
			extent: 0 @ 0]
]

{ #category : #accessing }
SBTSNodeBase >> factory [

	^ factory
]

{ #category : #accessing }
SBTSNodeBase >> factory: aFactory [

	factory := aFactory
]

{ #category : #accessing }
SBTSNodeBase >> field [

	^ self basicField ifNil: [(self owner notNil and: [self owner isTSNode and: [self owner inline]]) ifTrue: [self owner field]]
]

{ #category : #accessing }
SBTSNodeBase >> field: aString [

	field := aString
]

{ #category : #'inlining support' }
SBTSNodeBase >> handlesMouseDown: anEvent [

	^ self inline not
]

{ #category : #'inlining support' }
SBTSNodeBase >> handlesMouseOver: anEvent [

	^ self inline not
]

{ #category : #initialization }
SBTSNodeBase >> initialize [

	super initialize.
	
	isConcrete := false.
	children := OrderedCollection new
]

{ #category : #'inlining support' }
SBTSNodeBase >> inline [

	^ true
]

{ #category : #accessing }
SBTSNodeBase >> isConcrete [

	^ isConcrete
]

{ #category : #accessing }
SBTSNodeBase >> isConcrete: aBoolean [

	isConcrete := aBoolean
]

{ #category : #'inlining support' }
SBTSNodeBase >> isSandblock [

	^ self inline not
]

{ #category : #statements }
SBTSNodeBase >> isStatement [

	^ self parentSandblock isTSNode and: [self parentSandblock isStatementContainer]
]

{ #category : #statements }
SBTSNodeBase >> isStatementContainer [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSLabel [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSNode [

	^ true
]

{ #category : #testing }
SBTSNodeBase >> isTSRepeat [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSSeq [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSSymbol [

	^ false
]

{ #category : #accessing }
SBTSNodeBase >> language [

	^ self factory name
]

{ #category : #hierarchy }
SBTSNodeBase >> lastChild [

	^ self children last
]

{ #category : #layout }
SBTSNodeBase >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: {self firstSubmorph layoutCommands}
]

{ #category : #'inlining support' }
SBTSNodeBase >> layoutInset [

	^ self inline ifTrue: [0] ifFalse: [super layoutInset]
]

{ #category : #copying }
SBTSNodeBase >> makeConcrete [

	self assert: self isConcrete not.
	
	^ self basicCopy
		slot: self;
		isConcrete: true;
		ensureLayout;
		yourself
]

{ #category : #copying }
SBTSNodeBase >> makeTemplate [

	^ self basicCopy
		isConcrete: false;
		yourself
]

{ #category : #query }
SBTSNodeBase >> matchesQuery: aString [

	^ SBTSQuery new execute: aString against: self capturesDo: [:b | ]
]

{ #category : #accessing }
SBTSNodeBase >> maxChildren [

	^ 1
]

{ #category : #accessing }
SBTSNodeBase >> parent [

	^ parent
]

{ #category : #accessing }
SBTSNodeBase >> parent: aNode [

	self assert: self isConcrete = aNode isConcrete.
	parent := aNode
]

{ #category : #accessing }
SBTSNodeBase >> parser [

	^ parser
]

{ #category : #accessing }
SBTSNodeBase >> parser: aParser [

	parser := aParser
]

{ #category : #printing }
SBTSNodeBase >> printElementsSeparated: aCollection on: aStream indent: aNumber [

	| first delimiter lastMatchedWordRule suffixMatchesWordRule lastString |
	first := true.
	lastMatchedWordRule := false.
	lastString := ''.
	delimiter := (self containingSymbol ifNotNil: #type)
		ifNotNil: [:parentType |
			self factory delimitedRules
				at: parentType
				ifPresent: [:delim | delim first]
				ifAbsent: ['']]
		ifNil: [''].
	suffixMatchesWordRule := [:string | (factory notNil and: [factory separatorRule notNil]) and: [(1 to: string size) anySatisfy: [:start | factory separatorRule matchesStream: (string readStream position: start - 1)]]].
	aCollection withIndexDo: [:element :index | | string |
		string := String streamContents: [:stream |
			element writeSourceOn: stream indent: ((self factory indentMatch: element)
				ifTrue: [aNumber + 1]
				ifFalse: [aNumber])].
		self isTSRepeat
			ifTrue: [
				first ifFalse: [aStream nextPutAll: delimiter].
				((index > 1 and: [(self factory hardLineBreakMatchBetween: (aCollection at: index - 1) and: element) or: [(self containingSymbol ifNotNil: #isStatementContainer ifNil: [false]) and: [(self containingSymbol parentSandblock satisfies: #(#notNil #isTSNode)) or: [first not]]]]) and: [string notEmpty]) ifTrue: [aStream crtab: aNumber]]
			ifFalse: [
				(self isTSSeq and: [index > 1 and: [self factory hardLineBreakMatchBetween: (aCollection at: index - 1) and: element]])
					ifTrue: [
						aStream crtab: ((self factory indentMatch: element)
							ifTrue: [aNumber + 1]
							ifFalse: [aNumber])]
					ifFalse: [(string notEmpty and: [lastMatchedWordRule and: [suffixMatchesWordRule value: lastString, string first]]) ifTrue: [aStream space]]].
		string ifNotEmpty: [
			lastMatchedWordRule := suffixMatchesWordRule value: string.
			lastString := string.
			aStream nextPutAll: string].
		first := false]
]

{ #category : #printing }
SBTSNodeBase >> printFull [

	^ String streamContents: [:s | self printFullOn: s depth: 0]
]

{ #category : #printing }
SBTSNodeBase >> printFullOn: aStream depth: aNumber [

	aStream nextPut: $(.
	aStream print: self.
	self submorphs do: [:m |
		(m isKindOf: SBTSNodeBase) ifTrue: [
			aStream crtab: aNumber + 1.
			m printFullOn: aStream depth: aNumber + 1]].
	aStream crtab: aNumber + 1.
	aStream nextPut: $)
]

{ #category : #printing }
SBTSNodeBase >> printSExpr [

	^ String streamContents: [:s | self printSExprOn: s depth: 0 short: false]
]

{ #category : #printing }
SBTSNodeBase >> printSExprOn: aStream depth: aNumber short: aBoolean [

	self
		childSymbolsDo: [:m |
			m printSExprOn: aStream depth: aNumber short: aBoolean.
			aStream crtab: aNumber]
		includeInlined: aBoolean not
]

{ #category : #parsing }
SBTSNodeBase >> resultsFor: aParser [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> selfOrParentsInclude: aNode [

	self andParentsDo: [:p | p = aNode ifTrue: [^ true]].
	^ false
]

{ #category : #accessing }
SBTSNodeBase >> slot [

	^ slot
]

{ #category : #accessing }
SBTSNodeBase >> slot: anObject [

	self assert: (slot isNil or: [slot isConcrete not]).
	slot := anObject
]

{ #category : #statements }
SBTSNodeBase >> statements [

	^ self isStatementContainer ifTrue: [self childSandblocks] ifFalse: [nil]
]

{ #category : #parsing }
SBTSNodeBase >> takeNodesFrom: aParser [

	^ self subclassResponsibility
]

{ #category : #accessing }
SBTSNodeBase >> type [

	^ nil
]

{ #category : #printing }
SBTSNodeBase >> writeSourceOn: aStream [

	self writeSourceOn: aStream indent: 0
]

{ #category : #printing }
SBTSNodeBase >> writeSourceOn: aStream indent: aNumber [

	^ self subclassResponsibility
]
