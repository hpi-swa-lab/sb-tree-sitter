Class {
	#name : #SBReZeroOrMore,
	#superclass : #SBReQuantifier,
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReZeroOrMore class >> matchRegex: aDictionary do: aBlock [
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
SBReZeroOrMore >> buildOn: aSBRow [

	aSBRow addMorphBack: (SBInlineBlockLabel new label: 'zero or more times'; factory: self factory)
]

{ #category : #'as yet unclassified' }
SBReZeroOrMore >> buildSelf [

	self addMorphBack: (SBInlineBlockLabel new label: 'zero or more times'; factory: self factory)
]

{ #category : #'as yet unclassified' }
SBReZeroOrMore >> quantifierString [

	^ '*'
]

{ #category : #'as yet unclassified' }
SBReZeroOrMore >> type [

	^ 'zero_or_more'
]
