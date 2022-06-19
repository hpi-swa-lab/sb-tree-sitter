Class {
	#name : #SBTSNodeLabel,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'label'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #accessing }
SBTSNodeLabel >> allChildrenDo: aBlock [

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

	| slot |
	slot := SBTSSlot with: self.
	^ {
		self needsBlockWrapper
			ifTrue: [
				SBTSParseNode
					kind: #block
					slot: (SBTSSlot with: self)
					contents: {SBTSParseNode kind: #label slot: slot contents: self label}]
			ifFalse: [
				SBTSParseNode
					kind: (self isEditable ifTrue: [#text] ifFalse: [#label])
					slot: slot
					contents: self label]}
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

	self isEditable
		ifTrue: [
			(self needsBlockWrapper and: [aStream peek isTSBlock and: [aStream peek slot includesParent: self]]) ifTrue: [aClosure value: (SBCursorSelect new block: aStream next)].
			
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

	^ SBToggledCode comment: '' active: 2 do: {[false]. [(factory isImmutableLabel: self) not]}
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
SBTSNodeLabel >> prefixValidFor: aString [

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

	| labelStream oldPosition |
	labelStream := self label readStream.
	oldPosition := aParser position.
	
	(aParser peek isCharacter not and: [((aParser peek isTextMorph or: [aParser peek isStringMorph]) and: [self label = aParser peek contents])]) ifTrue: [ | block |
		block := aParser next.
		^ {aParser basicAddBlocks: {SBTSParseNode kind: #blockEmbed slot: (block slot trimNodesToTypeOf: self) contents: block}}].
	
	[aParser atEnd or: [(aParser peek isMorph and: [labelStream position > 0]) or: [labelStream atEnd]]] whileFalse: [
		labelStream next = aParser next ifFalse: [
			aParser position: oldPosition.
			^ {}]].
	
	SBToggledCode
		comment: ''
		active: 0
		do: {[(labelStream atEnd or: [aParser atEnd]) ifFalse: [^ {}]]}.
	
	[aParser peek = $ ] whileTrue: [aParser next].
	^ {aParser addBlock: self buildEmptyNodes first}
]

{ #category : #parsing }
SBTSNodeLabel >> resultsForBlocks: aParser [

	^ (aParser atEnd not and: [aParser peekIsNamed not and: [aParser peekType = self label]])
		ifTrue: [ | block |
			aParser nextSibling.
			block := (self isEditable ifTrue: [SBTSTextMorph] ifFalse: [SBTSLabel]) new
				contents: self label;
				slot: (SBTSSlot with: self).
			self needsBlockWrapper ifTrue: [
				block := SBTSBlock new
					addMorphBack: block;
					slot: block slot].
			{aParser addBlock: block}]
		ifFalse: [{}]
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
SBTSNodeLabel >> validFor: aString [

	^ self label = aString
]

{ #category : #printing }
SBTSNodeLabel >> writeSourceOn: aStream indent: aNumber [

	aStream nextPutAll: self label
]
