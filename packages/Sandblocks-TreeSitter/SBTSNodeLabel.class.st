Class {
	#name : #SBTSNodeLabel,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'label'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #accessing }
SBTSNodeLabel >> allChildrenDo: aBlock visited: aSet [

	aBlock value: self
]

{ #category : #accessing }
SBTSNodeLabel >> allElementsDo: aBlock [

	aBlock value: self
]

{ #category : #copying }
SBTSNodeLabel >> basicCopy [

	^ super basicCopy label: self label
]

{ #category : #build }
SBTSNodeLabel >> buildEmpty [

	^ {self buildMorphWith: nil slot: (SBTSSlot with: self)}
]

{ #category : #'as yet unclassified' }
SBTSNodeLabel >> buildEmptyNodes [

	^ self buildEmptyNodesWithLength: 0 class: SBTSParseNode
]

{ #category : #'as yet unclassified' }
SBTSNodeLabel >> buildEmptyNodesWithLength: aNumber class: aClass [

	| slot |
	slot := SBTSSlot with: self.
	^ {
		self needsBlockWrapper
			ifTrue: [
				SBTSParseNode
					kind: #block
					slot: (SBTSSlot with: self)
					contents: {aClass kind: #editableLabel slot: slot contents: (self label first: aNumber)}]
			ifFalse: [
				aClass
					kind: (self isEditable ifTrue: [#editableLabel] ifFalse: [#label])
					slot: slot
					contents: (self isEditable ifTrue: [self label first: aNumber] ifFalse: [self label])]}
]

{ #category : #build }
SBTSNodeLabel >> buildMorphWith: aString slot: aSlot [

	self needsBlockWrapper ifTrue: [
		^ SBTSBlock new
			addMorphBack: (SBTSLabel new
				contents: self label;
				slot: aSlot);
			slot: aSlot].
	
	^ (self isEditable ifTrue: [SBTSTextMorph] ifFalse: [SBTSLabel]) new
		contents: self label;
		slot: aSlot
]

{ #category : #query }
SBTSNodeLabel >> childrenForQuery [

	^ #()
]

{ #category : #query }
SBTSNodeLabel >> childrenForQueryDo: aBlock [

	aBlock value: self
]

{ #category : #hierarchy }
SBTSNodeLabel >> cursorPositionsDo: aClosure shallow: aBoolean blocks: aStream parent: aBlock [

	aStream atEnd ifTrue: [^ self].
	
	self isEditable
		ifTrue: [
			(self needsBlockWrapper and: [aStream peek isTSBlock and: [aStream peek slot includesParent: self]]) ifTrue: [ | block |
				block := aStream next.
				aClosure value: (SBCursorSelect new block: block).
				aClosure value: (SBCursorText new
					block: block containingSandblock;
					currentCommand: (SBTextCommand new textMorph: block firstSubmorph)).
				^ self].
			
			(aStream peek isTextMorph and: [aStream peek slot includesParent: self]) ifTrue: [ | block |
				block := aStream next.
				aClosure value: (SBCursorText new
					block: block containingSandblock;
					currentCommand: (SBTextCommand new textMorph: block))]]
		ifFalse: [
			self needsBlockWrapper
				ifTrue: [(aStream peek isTSBlock and: [aStream peek slot includesParent: self]) ifTrue: [aClosure value: (SBCursorSelect new block: aStream next)]]
				ifFalse: [(aStream peek isStringMorph and: [aStream peek slot includesParent: self]) ifTrue: [aStream next]]]
]

{ #category : #accessing }
SBTSNodeLabel >> elements [

	^ #()
]

{ #category : #testing }
SBTSNodeLabel >> hasEqualStructure: aNode [

	^ (super hasEqualStructure: aNode) and: [self label = aNode label]
]

{ #category : #testing }
SBTSNodeLabel >> isEditable [
	"mark whether this label could be a variation point and should thus be editable"

	^ SBToggledCode comment: '' active: 2 do: {[true]. [(factory isImmutableLabel: self) not]}
]

{ #category : #testing }
SBTSNodeLabel >> isTSLabel [

	^ true
]

{ #category : #accessing }
SBTSNodeLabel >> label [

	^ label
]

{ #category : #accessing }
SBTSNodeLabel >> label: aString [

	label := aString
]

{ #category : #printing }
SBTSNodeLabel >> labelPrintOn: aStream [

	aStream nextPutAll: (self label asText addAttribute: TextEmphasis italic)
]

{ #category : #accessing }
SBTSNodeLabel >> maxChildren [

	^ 0
]

{ #category : #testing }
SBTSNodeLabel >> needsBlockWrapper [

	| repeater |
	"if a label is optional, we cannot address it (e.g., for deleting) unless we wrap a block around it"
	repeater := self parentThat: #isTSRepeat.
	repeater ifNil: [^ false].
	
	repeater allChildrenDo: [:child | child isTSSymbol ifTrue: [^ false]].
	
	^ true
]

{ #category : #testing }
SBTSNodeLabel >> prefixValidFor: aString in: aSiblingsCollection [

	^ self label beginsWith: aString
]

{ #category : #printing }
SBTSNodeLabel >> printOn: aStream [

	aStream nextPut: $".
	aStream nextPutAll: (self label ifNil: ['']).
	aStream nextPut: $"
]

{ #category : #accessing }
SBTSNodeLabel >> regex [

	^ self regexString asRegex
]

{ #category : #'as yet unclassified' }
SBTSNodeLabel >> regexString [

	^ (self factory escapeStringForRegex: self label)
		copyReplaceAll: ':'
		with: '\:'
]

{ #category : #parsing }
SBTSNodeLabel >> resultsFor: aParser [

	| labelStream oldPosition typedLength |
	labelStream := self label readStream.
	oldPosition := aParser position.
	
	(aParser peek isCharacter not and: [(aParser peek isTextMorph or: [aParser peek isStringMorph]) and: [self label = aParser peek contentsForEdit]]) ifTrue: [ | block |
		block := aParser next.
		aParser skipExtras.
		^ {
			aParser basicAddBlocks: {SBTSParseNode kind: #blockEmbed slot: (block slot trimNodesToTypeOf: self) contents: block}}].
	
	[aParser atEnd or: [(aParser peek isMorph and: [labelStream position > 0]) or: [labelStream atEnd]]] whileFalse: [
		labelStream next = aParser next ifFalse: [
			aParser position: oldPosition.
			^ {}]].
	typedLength := aParser position - oldPosition.
	
	SBToggledCode
		comment: ''
		active: 0
		do: {[(labelStream atEnd or: [aParser atEnd]) ifFalse: [^ {}]]}.
	
	aParser skipExtras.
	^ {aParser addBlock: (self buildEmptyNodesWithLength: typedLength class: SBTSParseNode) first}
]

{ #category : #parsing }
SBTSNodeLabel >> resultsForBlocks: aParser [

	| success |
	success := [:range |
		{
			aParser addBlock: ((self buildEmptyNodesWithLength: self label size class: SBTSFileParseNode) first range: range)}].
	
	(aParser peekForLabel: self label) ifTrue: [ | range |
		range := aParser currentRange.
		(aParser justEnteredAlias not or: [self parent notNil and: [self parent isTSAlias not or: [self parent named]]]) ifTrue: [aParser nextSibling].
		^ success value: range].
	
	(aParser justEnteredAlias and: [aParser peekText = self label]) ifTrue: [
		aParser justEnteredAlias: false.
		^ success value: aParser currentRange].
	
	aParser peekText = self label ifTrue: [^ success value: aParser currentRange].
	
	aParser peekUncapturedText = self label ifTrue: [
		aParser uncapturedText.
		^ success value: aParser currentRange].
	
	^ {}
]

{ #category : #parsing }
SBTSNodeLabel >> takeNodesFrom: aParser [

	^ (aParser atEnd not and: [aParser peek = self label])
		ifTrue: [
			aParser next.
			{aParser copy addSlot: self}]
		ifFalse: [{}]
]

{ #category : #hierarchy }
SBTSNodeLabel >> traverseBlocks: aStream do: aBlock [

	self needsBlockWrapper
		ifTrue: [(aStream peek isTSBlock and: [aStream peek slot includesParent: self]) ifTrue: [aBlock value: aStream next]]
		ifFalse: [((self isEditable ifTrue: [aStream peek isTextMorph] ifFalse: [aStream peek isStringMorph]) and: [aStream peek slot includesParent: self]) ifTrue: [aBlock value: aStream next]]
]

{ #category : #accessing }
SBTSNodeLabel >> type [

	^ '"', (self label, '"')
]

{ #category : #testing }
SBTSNodeLabel >> validFor: aString in: aSiblingsCollection [

	^ self label = aString
]

{ #category : #printing }
SBTSNodeLabel >> writeSourceOn: aStream indent: aNumber [

	aStream nextPutAll: self label
]
