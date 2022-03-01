"
A SBReExactQuantifier replaces the {n,m} quantifier. This is a subset of the {n[,[m]]} syntax for regular expressions and only covers an range. For a an exact number, see SBReQuantifierRange or use {n,n}.

The {n,} and {,n} variations are currently not supported by the regex grammar.
"
Class {
	#name : #SBReQuantifierRange,
	#superclass : #SBReQuantifier,
	#instVars : [
		'minimum',
		'maximum'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #matchers }
SBReQuantifierRange class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:
'(count_quantifier
	(decimal_digits) @minimum
	(decimal_digits) @maximum
	"?"? @lazy
) @count_quantifier'>

	^ aBlock
		value: (aDictionary at: 'count_quantifier')
		value: (self new
			minimum: (aDictionary at: 'minimum') contents asNumber;
			maximum: (aDictionary at: 'maximum') contents asNumber;
			lazy: (aDictionary includesKey: 'lazy'))
]

{ #category : #initialization }
SBReQuantifierRange >> buildOn: aMorph [

	aMorph
		addMorphBack: (SBStringMorph new
			contents: 'at least:');
		addMorphBack: (minimum := SBReNumberInput new
			hint: 'min';
			minimum: 0;
			onChange: [:value |
				maximum minimum: value]);
		addMorphBack: (SBStringMorph new
			contents: 'at most:');
		addMorphBack: (maximum := SBReNumberInput new
			hint: 'max';
			minimum: 0;
			onChange: [:value |
				minimum maximum: value])
]

{ #category : #accessing }
SBReQuantifierRange >> maximum [

	^ maximum value ifNil: [0]
]

{ #category : #accessing }
SBReQuantifierRange >> maximum: aNumber [

	maximum value: aNumber
]

{ #category : #accessing }
SBReQuantifierRange >> minimum [

	^ minimum value ifNil: [0]
]

{ #category : #accessing }
SBReQuantifierRange >> minimum: aNumber [

	minimum value: aNumber
]

{ #category : #printing }
SBReQuantifierRange >> quantifierString [

	^ '{',
		self minimum asString,
		',',
		self maximum asString,
		'}'
]

{ #category : #accessing }
SBReQuantifierRange >> type [

	^ 'count_quantifier'
]
