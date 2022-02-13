Class {
	#name : #SBReVerboseZeroOrMore,
	#superclass : #SBReVerboseQuantifier,
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReVerboseZeroOrMore class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:
'(zero_or_more
	"?"? @lazy
) @zero_or_more'>

	^ aBlock
		value: (aDictionary at: 'zero_or_more')
		value: (self new
			lazy: (aDictionary includesKey: 'lazy'))
]

{ #category : #'as yet unclassified' }
SBReVerboseZeroOrMore >> buildOn: aSBRow [

	aSBRow addMorphBack: (SBInlineBlockLabel new label: 'zero or more times'; factory: self factory)
]

{ #category : #'as yet unclassified' }
SBReVerboseZeroOrMore >> buildSelf [

	self addMorphBack: (SBInlineBlockLabel new label: 'zero or more times'; factory: self factory)
]

{ #category : #'as yet unclassified' }
SBReVerboseZeroOrMore >> quantifierString [

	^ '*'
]

{ #category : #'as yet unclassified' }
SBReVerboseZeroOrMore >> type [

	^ 'zero_or_more'
]
