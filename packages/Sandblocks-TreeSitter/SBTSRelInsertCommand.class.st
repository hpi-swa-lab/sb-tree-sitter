Class {
	#name : #SBTSRelInsertCommand,
	#superclass : #SBRelInsertCommand,
	#instVars : [
		'element',
		'buildSuggestions'
	],
	#category : #'Sandblocks-TreeSitter'
}

{ #category : #'as yet unclassified' }
SBTSRelInsertCommand >> buildSuggestions: aClosure [

	buildSuggestions := aClosure
]

{ #category : #'as yet unclassified' }
SBTSRelInsertCommand >> canInsert: aBlock [

	^ aBlock isTSSymbol and: [(element isKindOf: SBInlineBlockChoice) and: [element alternatives anySatisfy: [:alt | alt isTSSymbol and: [alt compatibleWithType: aBlock type]]]]
]

{ #category : #'as yet unclassified' }
SBTSRelInsertCommand >> continueAfterInsert: aCharacter [

	^ (morph sourceString includes: aCharacter) not
]

{ #category : #'as yet unclassified' }
SBTSRelInsertCommand >> do [

	morph := morph ifNil: [element isTemplate ifTrue: [element instantiate] ifFalse: [element]].
	super do.
	^ morph firstBlock ifNil: [morph containingSandblock]
]

{ #category : #'as yet unclassified' }
SBTSRelInsertCommand >> element [

	^ element
]

{ #category : #'as yet unclassified' }
SBTSRelInsertCommand >> hasSamePositionAs: aCommand [

	^ (aCommand isKindOf: self class) and: [aCommand element = self element and: [super hasSamePositionAs: aCommand]]
]

{ #category : #'as yet unclassified' }
SBTSRelInsertCommand >> near: aBlock before: aBoolean in: aContainer morph: aMorph [

	element := aMorph.
	super near: aBlock before: aBoolean in: aContainer morph: nil
]

{ #category : #'as yet unclassified' }
SBTSRelInsertCommand >> suggestions [

	^ buildSuggestions ifNotNil: [buildSuggestions value: self]
]

{ #category : #'as yet unclassified' }
SBTSRelInsertCommand >> title [

	^ 'insert ', element title
]
