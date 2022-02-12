Class {
	#name : #SBReVerboseQuantifier,
	#superclass : #SBReVerboseBlock,
	#instVars : [
		'number'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReVerboseQuantifier class >> matchRegex: aDictionary do: aBlock [
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
SBReVerboseQuantifier >> initialize [

	super initialize.
	
	self
		addMorphBack: (SBInlineBlockLabel new
			label: 'exactly: ';
			factory: self factory);
		addMorphBack: (number := SBReNumberInput new
			hint: 'number';
			minimum: 0)
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifier >> number [

	^ number value ifNil: [0]
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifier >> number: aNumber [

	number contents: aNumber asString
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifier >> sourceString [

	^ '{',
		self number asString,
		'}'
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifier >> type [

	^ 'count_quantifier'
]
