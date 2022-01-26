Class {
	#name : #SBTSNodeBase,
	#superclass : #SBBlock,
	#instVars : [
		'alias',
		'field',
		'factory',
		'parser',
		'isConcrete'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #hierarchy }
SBTSNodeBase >> addChild: aNode [

	self assert: self isConcrete.
	self assert: aNode isConcrete.
	self assert: self submorphCount + 1 <= self maxChildren.
	
	self addMorphBack: aNode.
	parser := aNode parser
]

{ #category : #accessing }
SBTSNodeBase >> alias [

	^ alias
]

{ #category : #accessing }
SBTSNodeBase >> alias: aString [

	alias := aString
]

{ #category : #hierarchy }
SBTSNodeBase >> allSuperTypesDo: aBlock [

	self owner ifNotNil: [:o | o allSuperTypesDo: aBlock]
]

{ #category : #copying }
SBTSNodeBase >> basicCopy [

	^ self class new
		field: field;
		alias: alias;
		factory: factory;
		parser: parser;
		isConcrete: isConcrete
]

{ #category : #hierarchy }
SBTSNodeBase >> child [

	^ self firstSubmorph
]

{ #category : #copying }
SBTSNodeBase >> copy [

	self assert: self isConcrete.
	^ self basicCopy addAllMorphs: (self submorphs collect: [:s | s copy])
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

	^ field
]

{ #category : #accessing }
SBTSNodeBase >> field: aString [

	field := aString
]

{ #category : #initialization }
SBTSNodeBase >> initialize [

	super initialize.
	
	isConcrete := false
]

{ #category : #accessing }
SBTSNodeBase >> isConcrete [

	^ isConcrete
]

{ #category : #accessing }
SBTSNodeBase >> isConcrete: aBoolean [

	isConcrete := aBoolean
]

{ #category : #hierarchy }
SBTSNodeBase >> lastChild [

	^ self lastSubmorph
]

{ #category : #copying }
SBTSNodeBase >> makeConcrete [

	self assert: self isConcrete not.
	
	^ self basicCopy
		isConcrete: true;
		yourself
]

{ #category : #copying }
SBTSNodeBase >> makeTemplate [

	^ self basicCopy
		isConcrete: false;
		yourself
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

{ #category : #parsing }
SBTSNodeBase >> resultsFor: aParser [

	^ self subclassResponsibility
]
