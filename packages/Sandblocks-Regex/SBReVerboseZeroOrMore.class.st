Class {
	#name : #SBReVerboseZeroOrMore,
	#superclass : #SBReVerboseBlock,
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReVerboseZeroOrMore class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:
'(zero_or_more) @zero_or_more'>

	^ aBlock
		value: (aDictionary at: 'zero_or_more')
		value: (self new)
]

{ #category : #'as yet unclassified' }
SBReVerboseZeroOrMore >> initialize [

	super initialize.

	self addMorphBack: (SBInlineBlockLabel new label: 'zero or more times'; factory: self factory)
]

{ #category : #'as yet unclassified' }
SBReVerboseZeroOrMore >> sourceString [

	^ '*'
]

{ #category : #'as yet unclassified' }
SBReVerboseZeroOrMore >> type [

	^ 'zero_or_more'
]
