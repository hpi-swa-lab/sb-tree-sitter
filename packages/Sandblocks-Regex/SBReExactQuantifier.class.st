Class {
	#name : #SBReExactQuantifier,
	#superclass : #SBReQuantifier,
	#instVars : [
		'number'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReExactQuantifier class >> isRange: aDictionary [

	^ ((aDictionary at: 'count_quantifier') childrenForQuery
		select: [:each | each type = 'decimal_digits']) size > 1
]

{ #category : #'as yet unclassified' }
SBReExactQuantifier class >> isZero: aDictionary [

	^ (aDictionary at: 'value') contents asNumber = 0
]

{ #category : #'as yet unclassified' }
SBReExactQuantifier class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:
'(count_quantifier
	(decimal_digits) @value
	"?"? @lazy
) @count_quantifier'>

	"Don't replace if the quantify is 0. {0} is used in the encoding of a comment. The comment would not be replaced because the quantifier was replaced first."
	((self isZero: aDictionary) or: [self isRange: aDictionary]) ifTrue: [^ nil].

	^ aBlock
		value: (aDictionary at: 'count_quantifier')
		value: (self new
			number: (aDictionary at: 'value') contents asNumber;
			lazy: (aDictionary includesKey: 'lazy'))
]

{ #category : #'as yet unclassified' }
SBReExactQuantifier >> buildOn: aSBRow [

	aSBRow
		addMorphBack: (SBInlineBlockLabel new
			label: 'exactly:';
			factory: self factory);
		addMorphBack: (number := SBReNumberInput new
			hint: 'number';
			minimum: 0)
]

{ #category : #'as yet unclassified' }
SBReExactQuantifier >> buildSelf [

	self
		addMorphBack: (SBInlineBlockLabel new
			label: 'exactly: ';
			factory: self factory);
		addMorphBack: (number := SBReNumberInput new
			hint: 'number';
			minimum: 0)
]

{ #category : #'as yet unclassified' }
SBReExactQuantifier >> number [

	^ number value ifNil: [0]
]

{ #category : #'as yet unclassified' }
SBReExactQuantifier >> number: aNumber [

	number contents: aNumber asString
]

{ #category : #'as yet unclassified' }
SBReExactQuantifier >> quantifierString [

	^ '{',
		self number asString,
		'}'
]

{ #category : #'as yet unclassified' }
SBReExactQuantifier >> type [

	^ 'count_quantifier'
]
