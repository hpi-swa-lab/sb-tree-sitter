Class {
	#name : #SBReVerboseQuantifierRange,
	#superclass : #SBReVerboseQuantifier,
	#instVars : [
		'minimum',
		'maximum'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReVerboseQuantifierRange class >> matchRegex: aDictionary do: aBlock [
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

{ #category : #'as yet unclassified' }
SBReVerboseQuantifierRange >> buildOn: aSBRow [

	aSBRow
		addMorphBack: (SBInlineBlockLabel new
			label: 'at least:';
			factory: self factory);
		addMorphBack: (minimum := SBReNumberInput new
			hint: 'min';
			minimum: 0;
			onChange: [:value |
				maximum minimum: value]);
		addMorphBack: (SBInlineBlockLabel new
			label: 'at most:';
			factory: self factory);
		addMorphBack: (maximum := SBReNumberInput new
			hint: 'max';
			minimum: 0;
			onChange: [:value |
				minimum maximum: value])
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifierRange >> buildSelf [
	
	self
		addMorphBack: (SBInlineBlockLabel new
			label: 'at least: ';
			factory: self factory);
		addMorphBack: (minimum := SBReNumberInput new
			hint: 'minimum';
			minimum: 0;
			onChange: [:value |
				maximum minimum: value]);
		addMorphBack: (SBInlineBlockLabel new
			label: 'at most: ';
			factory: self factory);
		addMorphBack: (maximum := SBReNumberInput new
			hint: 'maximum';
			minimum: 0;
			onChange: [:value |
				minimum maximum: value])
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifierRange >> maximum [

	^ maximum value ifNil: [0]
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifierRange >> maximum: aNumber [

	maximum value: aNumber
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifierRange >> minimum [

	^ minimum value ifNil: [0]
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifierRange >> minimum: aNumber [

	minimum value: aNumber
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifierRange >> quantifierString [

	^ '{',
		self minimum asString,
		',',
		self maximum asString,
		'}'
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifierRange >> type [

	^ 'count_quantifier'
]
