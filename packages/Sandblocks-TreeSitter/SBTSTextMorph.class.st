Class {
	#name : #SBTSTextMorph,
	#superclass : #SBMultilineOwnTextMorph,
	#instVars : [
		'slot',
		'highlight',
		'fixedText',
		'range'
	],
	#category : #'Sandblocks-TreeSitter-UI'
}

{ #category : #'as yet unclassified' }
SBTSTextMorph >> alias [

	^ nil
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> allConnectionsDo: aBlock [

	
]

{ #category : #decorators }
SBTSTextMorph >> attachDecorator: aDecorator [

	self parentSandblock submorphCount = 1 ifTrue: [^ self parentSandblock attachDecorator: aDecorator].
	(self valueOfProperty: #decorators ifAbsentPut: [OrderedCollection new]) add: aDecorator.
	aDecorator attached: self.
	self changed
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> canBeEmpty [

	^ self regex matches: ''
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> childrenForQuery [
	"remove inline block compat"

	self flag: #todo.
	^ #()
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> compatibleWithType: aString [

	^ self slot compatibleWithType: aString
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> confirmFixedText [

	fixedText ifNotNil: [
		self
			contents: self fixedText;
			fixedText: nil]
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> contents [

	| fixed |
	fixed := self fixedText ifNil: [''].
	^ self contentsForEdit size < fixed size
		ifTrue: [self contentsForEdit, (fixed allButFirst: self contentsForEdit size)]
		ifFalse: [self contentsForEdit]
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> contents: aString [

	super contents: aString.
	self owner ifNotNil: #clearCache
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> contentsToDisplay [

	| fixed |
	fixed := self fixedText ifNil: [''].
	(self contents isEmpty and: [fixed isEmpty]) ifTrue: [^ super contentsToDisplay].
	
	^ self contentsForEdit size < fixed size
		ifTrue: [
			self contentsForEdit asText, ((fixed allButFirst: self contentsForEdit size) asText
				addAttribute: TextEmphasis italic;
				addAttribute: (TextColor color: (self color alpha: 0.7)))]
		ifFalse: [self contentsForEdit]
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> copyBlock [

	| copy |
	copy := self class new
		contents: self contents;
		slot: self slot;
		placeholderText: self placeholderText.
	self
		valueOfProperty: #lastConstructed
		ifPresentDo: [:val | copy setProperty: #lastConstructed toValue: true].
	^ copy
]

{ #category : #decorators }
SBTSTextMorph >> decoratorsDo: aBlock [

	self valueOfProperty: #decorators ifPresentDo: [:decorators | decorators do: aBlock]
]

{ #category : #decorators }
SBTSTextMorph >> detachDecorator: aDecorator [

	self
		valueOfProperty: #decorators
		ifPresentDo: [:decorators | decorators remove: aDecorator ifAbsent: []].
	aDecorator detached: self.
	self changed
]

{ #category : #decorators }
SBTSTextMorph >> detachDecorators: aDecoratorClass [

	self parentSandblock submorphCount = 1 ifTrue: [^ self parentSandblock detachDecorators: aDecoratorClass].
	
	self decoratorsDo: [:d | d class = aDecoratorClass ifTrue: [d detached: self]].
	self
		valueOfProperty: #decorators
		ifPresentDo: [:decorators | self setProperty: #decorators toValue: (decorators reject: [:d | d class = aDecoratorClass])].
	self changed
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> doubleClick: evt [

	self owner doubleClick: evt
]

{ #category : #drawing }
SBTSTextMorph >> drawDecoratorsOn: aCanvas during: aBlock [

	self decoratorsDo: [:d | d preDrawOn: aCanvas].
	
	aBlock value.
	
	^ self decoratorsDo: [:d | d postDrawSelfOn: aCanvas]
]

{ #category : #drawing }
SBTSTextMorph >> drawOn: aCanvas [

	self drawDecoratorsOn: aCanvas during: [super drawOn: aCanvas]
]

{ #category : #drawing }
SBTSTextMorph >> drawSubmorphsOn: aCanvas [

	super drawSubmorphsOn: aCanvas.
	
	self decoratorsDo: [:d | d postDrawOn: aCanvas]
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> drawnColor [

	^ self containingSandblock drawnColor
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> effectiveContents [

	| fixed |
	fixed := self fixedText ifNil: [''].
	^ self contents size < fixed size
		ifTrue: [self contents, (fixed allButFirst: self contents size)]
		ifFalse: [self contents]
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> emphasis [

	^ #derive
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> ensureLayouted [

	
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> factory [

	^ (self slot ifNil: [self parentSandblock slot]) factory
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> field [

	^ self slot field
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> firstSourceCharacter [

	^ self contents size > 0 ifTrue: [self contents first] ifFalse: [nil]
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> fixedText [

	^ fixedText
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> fixedText: aString [

	fixedText := aString
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> foregroundColor [

	^ self containingSandblock colorPolicy foregroundColorForBlock: self
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> highlight [

	^ highlight ifNil: [self slot updateAllHighlightsFor: self]
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> highlight: aString [

	highlight := aString.
	paragraph := nil.
	self layoutChanged
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> initialize [

	super initialize.
	
	range := SBTSRange
		start: (SBTSPosition line: 0 character: 0)
		end: (SBTSPosition line: 0 character: 0).
	
	self maxWidth: 450 sbScaled
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> isComplete [

	^ self fixedText isNil or: [self contentsForEdit size = self fixedText size]
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> isTSMorph [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> isTSSymbol [
	"remove inline block compat"

	self flag: #todo.
	^ false
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> isUnknown [

	^ false
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> keepDuringDelete [

	^ ({''. '}'. ']'. ')'} includes: self contentsForEdit) not
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> keepDuringTransform [

	self contentsForEdit ifEmpty: [^ false].
	self symmetricSibling ifNotNil: [:sibling |
		(SBToggledCode
			comment: ''
			active: 1
			do: {[false]. [self submorphIndex > sibling submorphIndex]}) ifTrue: [^ false]].
	^ true
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> language [

	^ self factory name
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> lastConstructedChild [

	self valueOfProperty: #lastConstructed ifPresentDo: [:prop | ^ self].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> linearizeOn: aStream [

	aStream nextPut: self
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> ownerWithForegroundColor [

	^ self highlight = #'_sb_none'
		ifTrue: [self owner ifNotNil: [:o | o ownerWithForegroundColor]]
		ifFalse: [self]
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> preferredColorIn: aColorPolicy [

	^ self slot preferredColorIn: aColorPolicy for: self highlight
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> printLabelOn: aStream [

	aStream nextPutAll: self contents
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> printOn: aStream [

	aStream nextPutAll: 'tstext'''.
	aStream nextPutAll: (self contents ifNil: ['']).
	aStream nextPutAll: ''''
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> range [

	^ range
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> regex [

	^ self slot firstNode regex
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> repeaterGroup [
	"copied from SBTSBlock, not sure about the right semantics yet"

	self flag: #todo.
	
	self slot repeater ifNotNil: [:repeater | | myIndex mySubIndex seq start |
		myIndex := self submorphIndex.
		self flag: #todo.
		" does not consider nested repeats and nested seqs "
		seq := self slot parentThat: [:p | p isTSSeq and: [p hasParent: repeater]].
		seq ifNil: [^ {self}].
		mySubIndex := (self slot parentThat: [:p | p parent = seq]) in: [:c | c parent elements indexOf: c].
		start := myIndex - mySubIndex + 1.
		^ self owner submorphs copyFrom: start to: start + seq elements size - 1].
	^ nil
]

{ #category : #actions }
SBTSTextMorph >> select [

	self parentSandblock select
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> showPlaceholder [

	^ self contents isEmpty and: [self fixedText isNil]
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> shownColor [

	^ self containingSandblock shownColor
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> slot [

	^ slot
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> slot: aSlot [

	self assert: (aSlot isNil or: [aSlot class = SBTSSlot]).
	slot := aSlot.
	
	aSlot firstNode isTSLabel ifTrue: [self placeholderText: aSlot firstNode label]
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> sourceString [

	^ self contents
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> sourceStringForCompare [

	^ String streamContents: [:s | self writeSourceOn: s indent: 0 forCompare: true]
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> symmetricSibling [

	| pairs lookingFor label |
	self slot firstNode isTSLabel ifFalse: [^ nil].
	pairs := Dictionary newFrom: {'(' -> ')'. '[' -> ']'. '{' -> '}'. '<' -> '>'}.
	label := self slot firstNode label.
	lookingFor := pairs at: label ifAbsent: [pairs keyAtValue: label ifAbsent: [label]].
	
	self owner submorphs do: [:s | (s ~= self and: [s isTextMorph and: [s slot firstNode isTSLabel and: [s slot firstNode label = lookingFor]]]) ifTrue: [^ s]].
	
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> treeLabel [

	^ self contents
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> type [

	^ self slot type
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> wrapOffscreen: anEditor [

	
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> writeSourceOn: aStream indent: aNumber forCompare: aBoolean [

	aStream hasLineInfo ifTrue: [range start line: aStream currentLine character: aStream currentIndexInLine].
	aStream nextPutAll: ((aBoolean and: [self contents isEmpty and: [self canBeEmpty not]])
		ifTrue: [String value: 0]
		ifFalse: [self contents]).
	aStream hasLineInfo ifTrue: [range end line: aStream currentLine character: aStream currentIndexInLine]
]
