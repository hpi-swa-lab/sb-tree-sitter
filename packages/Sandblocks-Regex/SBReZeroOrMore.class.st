"
A SBReOneOrMore replaces the * quantifier.
"
Class {
	#name : #SBReZeroOrMore,
	#superclass : #SBReQuantifier,
	#category : #'Sandblocks-Regex'
}

{ #category : #matchers }
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

{ #category : #initialization }
SBReZeroOrMore >> buildOn: aMorph [

	aMorph addMorphBack: (SBStringMorph new contents: 'zero or more times')
]

{ #category : #printing }
SBReZeroOrMore >> quantifierString [

	^ '*'
]

{ #category : #accessing }
SBReZeroOrMore >> type [

	^ 'zero_or_more'
]