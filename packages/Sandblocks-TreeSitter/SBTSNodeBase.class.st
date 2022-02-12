Class {
	#name : #SBTSNodeBase,
	#superclass : #SBBlock,
	#instVars : [
		'field',
		'factory',
		'parser',
		'isConcrete'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #accessing }
SBTSNodeBase >> access [

	^ SBTSFieldAccessor new element: self
]

{ #category : #hierarchy }
SBTSNodeBase >> addChild: aNode [

	self assert: self isConcrete.
	self assert: aNode isConcrete.
	self assert: self submorphCount + 1 <= self maxChildren.
	
	self addMorphBack: aNode.
	parser := aNode parser
]

{ #category : #hierarchy }
SBTSNodeBase >> allSuperTypesDo: aBlock [

	self owner ifNotNil: [:o | o allSuperTypesDo: aBlock]
]

{ #category : #copying }
SBTSNodeBase >> basicCopy [

	^ self class new
		field: field;
		factory: factory;
		parser: parser;
		isConcrete: isConcrete
]

{ #category : #accessing }
SBTSNodeBase >> basicField [

	^ field
]

{ #category : #hierarchy }
SBTSNodeBase >> child [

	^ self firstSubmorph
]

{ #category : #hierarchy }
SBTSNodeBase >> childSymbolsDo: aBlock includeInlined: aBoolean [

	self submorphsDo: [:morph |
		morph isTSNode ifTrue: [
			(morph isTSSymbol and: [aBoolean or: [morph inline not]])
				ifTrue: [aBlock value: morph]
				ifFalse: [morph childSymbolsDo: aBlock includeInlined: aBoolean]]]
]

{ #category : #query }
SBTSNodeBase >> childrenForQuery [

	^ Array streamContents: [:s | self submorphsDo: [:m | m isTSNode ifTrue: [m childrenForQueryDo: [:child | s nextPut: child]]]]
]

{ #category : #testing }
SBTSNodeBase >> compatibleWithType: aSymbol [

	^ factory type: self type compatibleWith: aSymbol
]

{ #category : #hierarchy }
SBTSNodeBase >> containingSymbol [

	self owner ifNil: [^ nil].
	^ self owner isTSNode ifTrue: [self owner containingSymbol] ifFalse: [nil]
]

{ #category : #copying }
SBTSNodeBase >> copy [

	self assert: self isConcrete.
	^ self basicCopy addAllMorphs: (self submorphs collect: [:s | s copy])
]

{ #category : #accessing }
SBTSNodeBase >> currentTextMorph [

	self submorphsDo: [:m | (m isTSNode and: [m inline]) ifTrue: [m currentTextMorph ifNotNil: [:t | ^ t]]].
	^ nil
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

{ #category : #hierarchy }
SBTSNodeBase >> firstVisibleType [

	^ (self type notNil and: [self inline not])
		ifTrue: [self type]
		ifFalse: [
			(self hasSubmorphs and: [self firstSubmorph isTSNode])
				ifTrue: [self firstSubmorph firstVisibleType]
				ifFalse: [nil]]
]

{ #category : #initialization }
SBTSNodeBase >> initialize [

	super initialize.
	
	isConcrete := false
]

{ #category : #testing }
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

{ #category : #testing }
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

	^ self lastSubmorph
]

{ #category : #layout }
SBTSNodeBase >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: {self firstSubmorph layoutCommands}
]

{ #category : #copying }
SBTSNodeBase >> makeConcrete [

	self assert: self isConcrete not.
	
	^ self basicCopy
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
