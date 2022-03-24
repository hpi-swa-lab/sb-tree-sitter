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

{ #category : #copying }
SBTSNodeLabel >> basicCopy [

	^ super basicCopy label: self label
]

{ #category : #build }
SBTSNodeLabel >> buildEmpty [

	^ {self buildMorphWith: nil slot: (SBTSSlot new addNode: self)}
]

{ #category : #build }
SBTSNodeLabel >> buildMorphWith: aString slot: aSlot [

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

{ #category : #copying }
SBTSNodeLabel >> cursorPositionsDo: aClosure shallow: aBoolean blocks: aCollection parent: aBlock [

	self isEditable ifTrue: [
		aCollection
			detect: [:block | block isTextMorph and: [block slot includesParent: self]]
			ifFound: [:b |
				b containingSandblock startInputCommand ifNotNil: [:command |
					aClosure value: (SBCursorText new
						block: b containingSandblock;
						currentCommand: command)]]
			ifNone: []]
]

{ #category : #testing }
SBTSNodeLabel >> isEditable [
	"mark whether this label could be a variation point and should thus be editable"

	^ SBToggledCode
		comment: ''
		active: 1
		do: {[false]. [(#(')' ']' '}' '>') includes: self label) not]}
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

	^ (self factory escapeStringForRegex: self label) asRegex
]

{ #category : #parsing }
SBTSNodeLabel >> resultsFor: aParser [

	| labelStream oldPosition |
	labelStream := self label readStream.
	oldPosition := aParser position.
	[aParser atEnd or: [labelStream atEnd]] whileFalse: [
		labelStream next = aParser next ifFalse: [
			aParser position: oldPosition.
			^ #noMatch]].
	^ {aParser copy addBlock: (self buildMorphWith: self label slot: (SBTSSlot new addNode: self))}
]

{ #category : #parsing }
SBTSNodeLabel >> takeNodesFrom: aParser [

	^ (aParser atEnd not and: [aParser peek = self label])
		ifTrue: [
			aParser next.
			{aParser copy addSlot: self}]
		ifFalse: [#noMatch]
]

{ #category : #testing }
SBTSNodeLabel >> validFor: aString [

	^ self label = aString
]

{ #category : #printing }
SBTSNodeLabel >> writeSourceOn: aStream indent: aNumber [

	aStream nextPutAll: self label
]
