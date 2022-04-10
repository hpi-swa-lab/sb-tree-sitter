Class {
	#name : #SBTSReplacementBlock,
	#superclass : #SBTSBlock,
	#instVars : [
		'bindings',
		'updaters'
	],
	#category : #'Sandblocks-TreeSitter-Replacements'
}

{ #category : #'as yet unclassified' }
SBTSReplacementBlock class >> match: aBlock against: aTSQuery [

	aTSQuery executeAgainst: aBlock capturesDo: [:captures :success |
		success ifTrue: [ | block |
			block := self new
				bindings: captures block: aBlock;
				build.
			^ SBReplaceCommand new target: block root replacer: block]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock class >> match: aBlock against: aTSQuery buildSelector: aSymbol [

	aTSQuery executeAgainst: aBlock capturesDo: [:captures :success |
		success ifTrue: [ | block |
			block := self new
				bindings: captures block: aBlock;
				perform: aSymbol.
			^ SBReplaceCommand new target: block root replacer: block]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> bindings [

	^ bindings
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> bindings: aBindingsObject block: aBlock [

	bindings := aBindingsObject.
	(bindings includesKey: 'root') ifFalse: [bindings at: 'root' put: aBlock].
	self slot: self root slot
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> build [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> children [

	^ #()
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> copyBlock [

	^ self veryDeepCopy
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> createBinding: aBuilderClosure contents: aNameString [

	^ self
		createBinding: [:c | aBuilderClosure value contents: (c at: aNameString) contents]
		update: [:c :m | (c at: aNameString) contents: m contents]
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> createBinding: aBuilderClosure update: anUpdateClosure [

	| block |
	block := aBuilderClosure value: bindings.
	updaters add: block -> anUpdateClosure.
	^ block
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> createBindingBlock: aNameString [

	^ self createBinding: [:c | (self bindings at: aNameString) copyBlock] update: [:c :m | | block |
		block := m copyBlock.
		(c at: aNameString) owner ifNotNil: [(c at: aNameString) replaceBy: block].
		c at: aNameString put: block]
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> cursorPositionsDo: aBlock shallow: aBoolean [

	aBlock value: (SBCursorSelect new block: self)
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> initialize [

	super initialize.
	
	updaters := OrderedCollection new.
	
	self
		changeTableLayout;
		listDirection: #leftToRight;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> layoutCommands [

	^ SBAlgebraCommand morph data: self
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> root [

	^ self bindings at: 'root'
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> writeSourceOn: aStream indent: aNumber forCompare: aBoolean [

	updaters do: [:pair | pair value value: bindings value: pair key].
	self root writeSourceOn: aStream indent: aNumber forCompare: aBoolean
]
