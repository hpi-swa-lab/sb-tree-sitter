Class {
	#name : #SBTSReplacementBlock,
	#superclass : #SBTSBlock,
	#instVars : [
		'bindings',
		'updaters',
		'repeatInfo'
	],
	#category : #'Sandblocks-TreeSitter-Replacements'
}

{ #category : #'as yet unclassified' }
SBTSReplacementBlock class >> buildFor: aLanguage with: aDictionary [

	| replace |
	replace := Dictionary newFrom: aDictionary.
	^ (Pragma allNamed: #lang:match:sample: in: self), (Pragma allNamed: #lang:match:sample:keyword: in: self)
		detect: [:pragma | pragma arguments first = aLanguage language]
		ifFound: [:pragma | | replacement |
			replacement := aLanguage parseExpression: pragma arguments third.
			replace keysAndValuesDo: [:name :object | self replacePart: object name: name in: replacement].
			replace at: 'wrap' ifPresent: [:wrap | replacement := replacement adaptSlotFor: wrap slot].
			replacement applyReplacement: self]
		ifNone: [self error: ('No implementation for replacement of class {1} in this language' format: {self name})]
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock class >> keywordReplacementsDo: aBlock [

	self allSubclassesDo: [:class |
		Pragma
			withPragmasIn: class
			do: [:pragma | pragma keyword = #lang:match:sample:keyword: ifTrue: [aBlock value: pragma]]]
]

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

	aBlock isTSReplacement ifTrue: [^ nil].
	aTSQuery executeAgainst: aBlock capturesDo: [:captures :success |
		success ifTrue: [ | block restore |
			block := self new bindings: captures block: aBlock.
			restore := SBTSRestoreCommand new
				source: aBlock;
				target: block.
			(block perform: aSymbol) ifNotNil: [:b | | replaceCmd |
				b postBuild.
				replaceCmd := SBReplaceCommand new target: b replaceRoot replacer: b.
				^ SBCombinedCommand newWith: {restore}, (b replaceRoot owner ifNotNil: [{replaceCmd}] ifNil: [{SBDoItCommand new do: [b]}])]]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock class >> replacePart: anObject name: aString in: aBlock [

	anObject isString ifTrue: [
		^ aBlock
			queryNode: ('(_) ="__{1}__" @' format: {aString})
			ifFound: [:e | e contents: anObject]
			ifNone: [
				aBlock
					queryNode: ('(_) ="''__{1}__''" @' format: {aString})
					ifFound: [:e | e contents: ('''{1}''' format: {anObject})]
					ifNone: []]].
	anObject isSandblock ifTrue: [ | target |
		target := (aBlock queryNode: ('(_) ="__{1}__" @' format: {aString})) containingSandblock.
		^ target replaceBlock: (anObject adaptSlotFor: target slot)].
	self assert: false
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> applyReplacements [
	<action>

	self asCode
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> asCode [
	<action>

	self asCode: (SBConvert new
		objectInterface: self objectInterface;
		success: [:object | self sandblockEditor do: (SBReplaceCommand new target: self replacer: object)])
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> asCode: converter [
	<convert>

	converter do: [self updateDuring: [self root copyBlock]]
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> bindBlock: aBlock [

	| container |
	aBlock = self root ifTrue: [ | placeholder |
		placeholder := Morph new.
		self setProperty: #rootReplacePlaceholder toValue: placeholder.
		self root replaceBy: placeholder.
		^ aBlock].
	
	container := SBTSReplacedBlockContainer new block: aBlock.
	aBlock replaceBy: (SBTSReplacementPlaceholder new replaces: container).
	^ container
		addMorph: aBlock;
		yourself
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

	^ self createBinding: [:c | self bindBlock: (self bindings at: aNameString)] update: [:c :m |
		SBToggledCode
			comment: ''
			active: 0
			do: {[self replaceBound: aNameString with: m firstSubmorph]}]
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> createBindingNestedBlock: aBlock [

	| block |
	block := self createBinding: [:c | self bindBlock: aBlock] update: [:c :m | ].
	"make sure our block is found in the bindings because these are used to know what to restore"
	bindings at: block put: aBlock.
	^ block
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> createRepeatBindingFor: aString childQuery: anotherString new: aThirdString build: aBlock [

	self assert: repeatInfo isNil description: 'Currently only supports one repeated binding'.
	
	repeatInfo := {anotherString. aBlock. aThirdString. aString}.
	
	(bindings at: aString) childSandblocks do: [:closure | self addMorphBack: (aBlock value: (self bindBlock: (closure queryNode: anotherString)))]
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> createStatic: aBlock contents: aNameString [

	^ aBlock value: (bindings at: aNameString) contents
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> cursorPositionsDo: aBlock shallow: aBoolean [

	self basicCursorPositionsDo: aBlock shallow: aBoolean
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> drawBackgroundOn: aCanvas [

	| policy |
	policy := self colorPolicy.
	^ aCanvas
		frameAndFillRoundRect: self bounds
		radius: policy cornerRadius
		fillStyle: self drawnColor
		borderWidth: (policy borderWidthForBlock: self)
		borderColor: (policy borderColorForBlock: self)
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> fixedNumberOfChildren [

	^ repeatInfo isNil
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> foregroundColor [

	^ self root owner ifNotNil: [self root foregroundColor] ifNil: [super foregroundColor]
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
SBTSReplacementBlock >> insertCommandRequest: aMorph near: aBlock before: aBoolean [
	" the user tries to add a block to us, do we want to do something now? "

	self fixedNumberOfChildren ifTrue: [^ nil].
	^ SBRelInsertCommand new
		near: aBlock before: aBoolean in: self morph: aMorph;
		yourself
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
SBTSReplacementBlock >> newEmptyChildNear: aBlock before: aBoolean [

	| add |
	repeatInfo ifNil: [^ nil].
	
	add := self language parseWithPlaceholders: repeatInfo third.
	
	(bindings at: repeatInfo fourth) lastInsertPosition command
		morphs: {add};
		do.
	
	^ repeatInfo second value: (self bindBlock: (add queryNode: repeatInfo first))
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> ownerWithForegroundColor [

	^ self root highlight = #'_sb_none'
		ifTrue: [self owner ifNotNil: [:o | o ownerWithForegroundColor]]
		ifFalse: [self]
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> postBuild [
	"hook called after the language-specific build has finished"

	
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
SBTSReplacementBlock >> replaceRoot [

	^ self valueOfProperty: #rootReplacePlaceholder ifAbsent: [self root]
]

{ #category : #'as yet unclassified' }
SBTSReplacementBlock >> restore [

	^ bindings values
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
		m class = SBTSReplacementPlaceholder ifTrue: [ | block |
			block := m replaces firstSubmorph.
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
