Class {
	#name : #DCText,
	#superclass : #SBMultilineOwnTextMorph,
	#instVars : [
		'range',
		'highlight',
		'field'
	],
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCText >> alias [

	^ nil
]

{ #category : #'as yet unclassified' }
DCText >> compatibleWithType: aSymbol [

	^ false
]

{ #category : #'as yet unclassified' }
DCText >> effectiveContents [

	^ self contents
]

{ #category : #'as yet unclassified' }
DCText >> field [

	^ field
]

{ #category : #'as yet unclassified' }
DCText >> field: aString [

	field := aString
]

{ #category : #'as yet unclassified' }
DCText >> firstSourceCharacter [

	^ self contents size > 0 ifTrue: [self contents first] ifFalse: [nil]
]

{ #category : #'as yet unclassified' }
DCText >> foregroundColor [

	^ self containingSandblock colorPolicy foregroundColorForBlock: self
]

{ #category : #'as yet unclassified' }
DCText >> highlight [

	^ highlight ifNil: [self slot updateAllHighlightsFor: self]
]

{ #category : #'as yet unclassified' }
DCText >> highlight: aString [

	highlight := aString.
	paragraph := nil.
	self layoutChanged
]

{ #category : #'as yet unclassified' }
DCText >> initialize [

	super initialize.
	
	range := SBTSRange
		start: (SBTSPosition line: 0 character: 0)
		end: (SBTSPosition line: 0 character: 0)
]

{ #category : #'as yet unclassified' }
DCText >> isTSMorph [

	^ true
]

{ #category : #'as yet unclassified' }
DCText >> language [

	^ self containingSandblock language
]

{ #category : #'as yet unclassified' }
DCText >> ownerWithForegroundColor [

	^ self highlight = #'_sb_none'
		ifTrue: [self owner ifNotNil: [:o | o ownerWithForegroundColor]]
		ifFalse: [self]
]

{ #category : #'as yet unclassified' }
DCText >> preferredColorIn: aColorPolicy [

	^ self slot preferredColorIn: aColorPolicy for: self highlight
]

{ #category : #'as yet unclassified' }
DCText >> printOn: aStream [

	aStream nextPutAll: ('"{1}"' format: {self contents})
]

{ #category : #'as yet unclassified' }
DCText >> range [

	^ range
]

{ #category : #'as yet unclassified' }
DCText >> range: aRange [

	range := aRange
]

{ #category : #'as yet unclassified' }
DCText >> shownColor [

	^ self containingSandblock shownColor
]

{ #category : #'as yet unclassified' }
DCText >> slot [

	^ DCMockSlot new for: self
]

{ #category : #'as yet unclassified' }
DCText >> writeSourceOn: aStream indent: aNumber forCompare: aBoolean [

	aStream hasLineInfo ifTrue: [range start line: aStream currentLine character: aStream currentIndexInLine].
	aStream nextPutAll: ((aBoolean and: [self contents isEmpty and: [self canBeEmpty not]])
		ifTrue: [String value: 0]
		ifFalse: [self contents]).
	aStream hasLineInfo ifTrue: [range end line: aStream currentLine character: aStream currentIndexInLine]
]
