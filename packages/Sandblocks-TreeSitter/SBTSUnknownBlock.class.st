Class {
	#name : #SBTSUnknownBlock,
	#superclass : #SBTSBlock,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> absorbsInput: anEvent [

	^ false
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> copyBlock [

	| copy |
	copy := super copyBlock.
	copy firstSubmorph placeholderText: self firstSubmorph placeholderText.
	^ copy
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> cursorPositionsDo: aBlock shallow: aBoolean [

	aBlock value: (SBCursorSelect new block: self).
	self startInputCommand ifNotNil: [:command |
		aBlock value: (SBCursorText new
			block: self;
			currentCommand: command)]
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> initialize [

	super initialize.
	self addMorphBack: SBTSTextMorph new
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> isUnknown [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> keepDuringTransform [

	^ false
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> placeholderText: aString [

	self firstSubmorph placeholderText: (aString size < 15 ifTrue: [aString] ifFalse: [(aString first: 12), '...'])
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> prefixValidFor: aTextMorph [

	^ false
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> printOn: aStream [

	aStream nextPutAll: 'unknown '.
	super printOn: aStream
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> slot: aSlot [

	super slot: aSlot.
	self firstSubmorph slot: aSlot.
	self firstSubmorph placeholderText ifEmpty: [self placeholderText: self slot firstNode printString]
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> suggestAlways [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> suggestions [

	^ (self slot firstNode isTSChoice and: [self slot firstNode alternatives allSatisfy: #isTSLabel])
		ifTrue: [
			self slot firstNode alternatives collect: [:alt |
				SBTSBlockSuggestion new
					command: (SBReplaceMultipleCommand new target: self replacers: alt buildEmpty)
					in: self sandblockEditor]]
		ifFalse: [#()]
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> valid [

	^ false
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> wantsInput [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> writeSourceOn: aStream indent: aNumber forCompare: aBoolean [

	aBoolean ifTrue: [aStream nextPut: (Character value: 0)]
]
