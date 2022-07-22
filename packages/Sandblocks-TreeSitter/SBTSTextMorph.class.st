Class {
	#name : #SBTSTextMorph,
	#superclass : #SBMultilineOwnTextMorph,
	#instVars : [
		'slot',
		'highlight'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSTextMorph >> alias [

	^ nil
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> allConnectionsDo: aBlock [

	
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
SBTSTextMorph >> contents: aString [

	super contents: aString.
	self owner ifNotNil: #clearCache
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

{ #category : #'as yet unclassified' }
SBTSTextMorph >> drawnColor [

	^ self containingSandblock drawnColor
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> emphasis [

	^ #derive
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> ensureLayouted [

	
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> exportStructure [

	^ {
		#class -> #text.
		#bounds -> (self bounds in: [:r | {r left. r top. r width. r height}]).
		#regex -> self slot firstNode regexString.
		#contents -> self contents.
		#color -> self color asHTMLColor} as: Dictionary
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

	^ self contents anySatisfy: [:c | c isAlphaNumeric]
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> keepDuringTransform [

	self contents ifEmpty: [^ false].
	self symmetricSibling ifNotNil: [:sibling |
		(SBToggledCode
			comment: ''
			active: 2
			do: {[true]. [self submorphIndex > sibling submorphIndex]}) ifTrue: [^ false]].
	^ true
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> language [

	^ self factory name
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

	super printOn: aStream.
	aStream print: contents
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
SBTSTextMorph >> submorphIndex [

	^ self owner submorphs indexOf: self
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
SBTSTextMorph >> type [

	^ self slot type
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> wantsInput [

	^ false
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> wrapOffscreen: anEditor [

	
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> writeSourceOn: aStream indent: aNumber forCompare: aBoolean [

	aStream nextPutAll: ((aBoolean and: [self contents isEmpty and: [self canBeEmpty not]])
		ifTrue: [String value: 0]
		ifFalse: [self contents])
]
