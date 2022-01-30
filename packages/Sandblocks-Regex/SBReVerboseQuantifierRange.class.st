Class {
	#name : #SBReVerboseQuantifierRange,
	#superclass : #SBReVerboseBlock,
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
) @count_quantifier'>

	^ aBlock
		value: (aDictionary at: 'count_quantifier')
		value: (self new
			minimum: (aDictionary at: 'minimum') contents asNumber;
			maximum: (aDictionary at: 'maximum') contents asNumber)
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifierRange >> initialize [

	super initialize.
	
	self
		addMorphBack: (SBInlineBlockLabel new
			label: 'at least: ';
			factory: self factory);
		addMorphBack: (minimum := SBInlineBlockText new
			regexString: '[0-9]+';
			hint: 'minimum';
			factory: self factory);
		addMorphBack: (SBInlineBlockLabel new
			label: 'at most: ';
			factory: self factory);
		addMorphBack: (maximum := SBInlineBlockText new
			regexString: '[0-9]+';
			hint: 'maximum';
			factory: self factory)
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifierRange >> maximum [

	^ maximum contents ifEmpty: [0] ifNotEmpty: [:value | value asNumber]
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifierRange >> maximum: aNumber [

	maximum contents: aNumber asString
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifierRange >> minimum [

	^ minimum contents ifEmpty: [0] ifNotEmpty: [:value | value asNumber]
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifierRange >> minimum: aNumber [

	minimum contents: aNumber asString
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifierRange >> sourceString [

	^ '{',
		self minimum asString,
		',',
		self maximum asString,
		'}'
]
