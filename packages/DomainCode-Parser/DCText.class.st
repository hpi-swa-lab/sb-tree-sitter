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

{ #category : #hierarchy }
DCText >> allParentsUpTo: aBlock [

	^ {self parent}, (self parent allParentsUpTo: aBlock)
]

{ #category : #'as yet unclassified' }
DCText >> childrenDo: aBlock [
]

{ #category : #'as yet unclassified' }
DCText >> clearDiffCache [
]

{ #category : #'as yet unclassified' }
DCText >> compatibleWithType: aSymbol [

	^ false
]

{ #category : #'as yet unclassified' }
DCText >> doubleClick: anEvent [

	self parent doubleClick: anEvent
]

{ #category : #'as yet unclassified' }
DCText >> effectiveContents [

	^ self contents
]

{ #category : #'as yet unclassified' }
DCText >> emphasis [

	^ #derive
]

{ #category : #'as yet unclassified' }
DCText >> ensureLayouted [

	self owner ensureLayouted
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

{ #category : #hierarchy }
DCText >> hasAnyParent: aBlock [

	self parent = aBlock ifTrue: [^ true].
	^ self parent hasAnyParent: aBlock
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
	
	range := SBTSRange null
]

{ #category : #'as yet unclassified' }
DCText >> is: aCollectionOrSymbol [

	^ false
]

{ #category : #'as yet unclassified' }
DCText >> isExpression [

	^ false
]

{ #category : #'as yet unclassified' }
DCText >> isExtra [
	"TODO: use language isExtra: instead"

	^ self treeLabel notEmpty and: [self treeLabel allSatisfy: [:x | x isSeparator]]
]

{ #category : #'as yet unclassified' }
DCText >> isReplacement [

	^ false
]

{ #category : #'as yet unclassified' }
DCText >> isRootBlock [

	^ false
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
DCText >> parent [

	^ self owner
]

{ #category : #'as yet unclassified' }
DCText >> parentNode [

	^ self owner
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
DCText >> printTreeOn: aStream indent: aNumber [

	aNumber timesRepeat: [aStream tab].
	aStream nextPutAll: '"'.
	aStream nextPutAll: self contents.
	aStream nextPutAll: '"'
]

{ #category : #'as yet unclassified' }
DCText >> range [

	^ range isNull ifTrue: [self owner range] ifFalse: [range]
]

{ #category : #'as yet unclassified' }
DCText >> range: aRange [

	range := aRange
]

{ #category : #'as yet unclassified' }
DCText >> replacedParent [

	^ nil
]

{ #category : #'as yet unclassified' }
DCText >> rootBlock [

	^ self owner rootBlock
]

{ #category : #'as yet unclassified' }
DCText >> shallowCopyBlock [

	^ self class new
		range: range;
		contents: contents;
		highlight: highlight;
		field: field
]

{ #category : #'as yet unclassified' }
DCText >> shownColor [

	^ self containingSandblock shownColor
]

{ #category : #hierarchy }
DCText >> siblingIndex [

	| i |
	i := 1.
	self parent childrenDo: [:c |
		c = self ifTrue: [^ i].
		i := i + 1].
	^ 0
]

{ #category : #'as yet unclassified' }
DCText >> slot [

	^ DCMockSlot new for: self
]

{ #category : #'as yet unclassified' }
DCText >> statementWithTerminatorRange [

	^ self range
]

{ #category : #'as yet unclassified' }
DCText >> treeHash [

	^ self treeHashCount: {0}
]

{ #category : #'as yet unclassified' }
DCText >> treeHashCount: aPtr [

	^ ((self contents hash bitXor: 'LABEL_ENTER' hash) bitXor: aPtr first * 2 + 1) bitXor: 'LABEL_LEAVE' hash
]

{ #category : #'as yet unclassified' }
DCText >> treeLabel [

	^ self contents
]

{ #category : #'as yet unclassified' }
DCText >> type [

	^ ''
]

{ #category : #'as yet unclassified' }
DCText >> writeSourceOn: aStream indent: aNumber forCompare: aBoolean [

	aStream hasLineInfo ifTrue: [
		range start
			line: aStream currentLine
			character: aStream currentIndexInLine
			index: aStream position].
	aStream nextPutAll: ((aBoolean and: [self contents isEmpty and: [self canBeEmpty not]])
		ifTrue: [String value: 0]
		ifFalse: [self contents]).
	aStream hasLineInfo ifTrue: [range end line: aStream currentLine character: aStream currentIndexInLine index: aStream position]
]
