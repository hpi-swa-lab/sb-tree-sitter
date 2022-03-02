"
A SBReOneOrMore replaces the + quantifier.
"
Class {
	#name : #SBReOneOrMore,
	#superclass : #SBReQuantifier,
	#category : #'Sandblocks-Regex'
}

{ #category : #matchers }
SBReOneOrMore class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:'
(one_or_more
	"?"? @lazy
) @one_or_more'>

	^ aBlock
		value: (aDictionary at: 'one_or_more')
		value: (self new
			lazy: (aDictionary includesKey: 'lazy'))
]

{ #category : #initialization }
SBReOneOrMore >> buildOn: aMorph [

	aMorph addMorphBack: (SBStringMorph new
		contents: 'at least one time')
]

{ #category : #printing }
SBReOneOrMore >> quantifierString [

	^ '+'
]

{ #category : #accessing }
SBReOneOrMore >> type [

	^ 'one_or_more'
]
