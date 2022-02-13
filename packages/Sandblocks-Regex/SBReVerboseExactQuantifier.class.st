Class {
	#name : #SBReVerboseExactQuantifier,
	#superclass : #SBReVerboseQuantifier,
	#instVars : [
		'number'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReVerboseExactQuantifier class >> isRange: aDictionary [

	^ ((aDictionary at: 'count_quantifier') childrenForQuery
		select: [:each | each type = 'decimal_digits']) size > 1
]

{ #category : #'as yet unclassified' }
SBReVerboseExactQuantifier class >> isZero: aDictionary [

	^ (aDictionary at: 'value') contents asNumber = 0
]

{ #category : #'as yet unclassified' }
SBReVerboseExactQuantifier class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:
'(count_quantifier
	(decimal_digits) @value
) @count_quantifier'>

	"Don't replace if the quantify is 0. {0} is used in the encoding of a comment. The comment would not be replaced because the quantifier was replaced first."
	((self isZero: aDictionary) or: [self isRange: aDictionary]) ifTrue: [^ nil].

	^ aBlock
		value: (aDictionary at: 'count_quantifier')
		value: (self new
			number: (aDictionary at: 'value') contents asNumber)
]

{ #category : #'as yet unclassified' }
SBReVerboseExactQuantifier >> buildOn: aSBRow [

	aSBRow
		addMorphBack: (SBInlineBlockLabel new
			label: 'exactly: ';
			factory: self factory);
		addMorphBack: (number := SBReNumberInput new
			hint: 'number';
			minimum: 0)
]

{ #category : #'as yet unclassified' }
SBReVerboseExactQuantifier >> buildSelf [

	self
		addMorphBack: (SBInlineBlockLabel new
			label: 'exactly: ';
			factory: self factory);
		addMorphBack: (number := SBReNumberInput new
			hint: 'number';
			minimum: 0)
]

{ #category : #'as yet unclassified' }
SBReVerboseExactQuantifier >> number [

	^ number value ifNil: [0]
]

{ #category : #'as yet unclassified' }
SBReVerboseExactQuantifier >> number: aNumber [

	number contents: aNumber asString
]

{ #category : #'as yet unclassified' }
SBReVerboseExactQuantifier >> quantifierString [

	^ '{',
		self number asString,
		'}'
]

{ #category : #'as yet unclassified' }
SBReVerboseExactQuantifier >> type [

	^ 'count_quantifier'
]
