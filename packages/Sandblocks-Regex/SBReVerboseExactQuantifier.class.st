Class {
	#name : #SBReVerboseExactQuantifier,
	#superclass : #SBReVerboseBlock,
	#instVars : [
		'number'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReVerboseExactQuantifier class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:
'(count_quantifier
	(decimal_digits) @value
) @count_quantifier'>

	((aDictionary at: 'count_quantifier') childrenForQuery
		select: [:each | each type = 'decimal_digits']) size > 1
		ifTrue: [^ nil].

	^ aBlock
		value: (aDictionary at: 'count_quantifier')
		value: (self new
			number: (aDictionary at: 'value') contents asNumber)
]

{ #category : #'as yet unclassified' }
SBReVerboseExactQuantifier >> initialize [

	super initialize.
	
	self
		addMorphBack: (SBInlineBlockLabel new
			label: 'exactly: ';
			factory: self factory);
		addMorphBack: (number := SBInlineBlockText new
			regexString: '[0-9]+';
			hint: 'number';
			factory: self factory)
]

{ #category : #'as yet unclassified' }
SBReVerboseExactQuantifier >> number [

	^ number contents ifEmpty: [0] ifNotEmpty: [:value | value asNumber]
]

{ #category : #'as yet unclassified' }
SBReVerboseExactQuantifier >> number: aNumber [

	number contents: aNumber asString
]

{ #category : #'as yet unclassified' }
SBReVerboseExactQuantifier >> sourceString [

	^ '{',
		self number asString,
		'}'
]
