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
		success ifTrue: [ | block restore |
			block := self new bindings: captures block: aBlock.
			restore := SBRestoreCommand new
				morphs: captures values commonOwner: block root;
				notePositions;
				yourself.
			(block perform: aSymbol) ifNotNil: [:b | | replaceCmd |
				replaceCmd := SBReplaceCommand new target: b root replacer: b.
				^ SBCombinedCommand newWith: {restore}, (b root owner ifNotNil: [{replaceCmd}] ifNil: [{SBDoItCommand new do: [b]}])]]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> asCode: converter [
	<convert>

	converter do: [self updateDuring: [self root copyBlock]]
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
SBTSReplacementBlock >> createBinding: aBuilderClosure contents: aNameString index: aNumber [

	^ self
		createBinding: [:c | aBuilderClosure value contents: ((c at: aNameString) textMorphs at: aNumber) contents]
		update: [:c :m | ((c at: aNameString) textMorphs at: aNumber) contents: m contents]
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> createBinding: aBuilderClosure object: aNameString [

	^ self
		createBinding: [:c | aBuilderClosure value object: (c at: aNameString) contents]
		update: [:c :m | (c at: aNameString) contents: m object]
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> createBinding: aBuilderClosure optional: aString insert: aClosure [

	^ self
		createBinding: [:c | aBuilderClosure value value: (c at: aString ifPresent: [true] ifAbsent: [false])]
		update: [:c :m |
			m value
				ifTrue: [
					c at: aString ifAbsent: [ | block |
						block := ((aClosure value: c) command
							do;
							morphs) first.
						c at: aString put: block]]
				ifFalse: [
					c at: aString ifPresent: [:block |
						block delete.
						c removeKey: aString]]]
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

	^ self
		createBinding: [:c | | block container |
			container := SBTSReplacedBlockContainer new.
			block := self bindings at: aNameString.
			block replaceBy: (SBTSReplacementPlaceholder new
				setProperty: #tsReplacementPlaceholder toValue: container;
				yourself).
			container
				addMorph: block;
				yourself]
		update: [:c :m |
			SBToggledCode
				comment: ''
				active: 0
				do: {[self replaceBound: aNameString with: m firstSubmorph]}]
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> cursorPositionsDo: aBlock shallow: aBoolean [

	self basicCursorPositionsDo: aBlock shallow: aBoolean
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> foregroundColor [

	^ self root foregroundColor
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
SBTSReplacementBlock >> isTSReplacement [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> layoutCommands [

	^ SBAlgebraCommand morph data: self
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> ownerWithColor [

	^ self root highlight = #'_sb_none'
		ifTrue: [self owner ifNotNil: [:o | o ownerWithColor]]
		ifFalse: [self]
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> replaceBound: aString with: aBlock [

	| new |
	new := aBlock copy
		adaptSlotFor: (bindings at: aString) slot
		ifFailed: [self assert: false description: 'adapting block slot'].
	aBlock slot: new slot.
	(bindings at: aString) owner ifNotNil: [(bindings at: aString) replaceBy: aBlock].
	bindings at: aString put: aBlock
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> root [

	^ self bindings at: 'root'
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> updateDuring: aBlock [

	| restore |
	restore := OrderedCollection new.
	self root allMorphsDo: [:m |
		m valueOfProperty: #tsReplacementPlaceholder ifPresentDo: [:original | | block |
			block := original firstSubmorph.
			m swapWith: block.
			restore add: m -> block]].
	updaters do: [:pair | pair value value: bindings value: pair key].
	^ aBlock ensure: [restore do: [:pair | pair value swapWith: pair key]]
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> wantsExtraSpace [

	^ false
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> writeSourceOn: aStream indent: aNumber forCompare: aBoolean [

	self updateDuring: [self root writeSourceOn: aStream indent: aNumber forCompare: aBoolean]
]
