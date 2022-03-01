"
A SBReExactQuantifier replaces the {n} quantifier. This is a subset of the {n[,[m]]} syntax for regular expressions and only covers an exact number. For a range, see SBReQuantifierRange.
"
Class {
	#name : #SBReExactQuantifier,
	#superclass : #SBReQuantifier,
	#instVars : [
		'number'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #tests }
SBReExactQuantifier class >> isRange: aDictionary [

	^ ((aDictionary at: 'count_quantifier') childrenForQuery
		select: [:each | each type = 'decimal_digits']) size > 1
]

{ #category : #tests }
SBReExactQuantifier class >> isZero: aDictionary [

	^ (aDictionary at: 'value') contents asNumber = 0
]

{ #category : #matchers }
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

{ #category : #initialization }
SBReExactQuantifier >> buildOn: aMorph [

	aMorph
		addMorphBack: (SBStringMorph new
			contents: 'exactly:');
		addMorphBack: (number := SBReNumberInput new
			hint: 'number';
			minimum: 0)
]

{ #category : #accessing }
SBReExactQuantifier >> number [

	^ number value ifNil: [0]
]

{ #category : #accessing }
SBReExactQuantifier >> number: aNumber [

	number contents: aNumber asString
]

{ #category : #printing }
SBReExactQuantifier >> quantifierString [

	^ '{',
		self number asString,
		'}'
]

{ #category : #accessing }
SBReExactQuantifier >> type [

	^ 'count_quantifier'
]
