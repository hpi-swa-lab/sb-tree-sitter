"
A SBReOneOrMore replaces the ? quantifier.
"
Class {
	#name : #SBReOptional,
	#superclass : #SBReQuantifier,
	#category : #'Sandblocks-Regex'
}

{ #category : #matchers }
SBReOptional class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:
'(optional
	"?"
	"?"? @lazy
) @optional'>

	^ aBlock
		value: (aDictionary at: 'optional')
		value: (self new
			lazy: (aDictionary includesKey: 'lazy'))
]

{ #category : #initialization }
SBReOptional >> buildOn: aMorph [

	aMorph addMorphBack: (SBStringMorph new contents: 'optional')
]

{ #category : #printing }
SBReOptional >> quantifierString [

	^ '?'
]

{ #category : #accessing }
SBReOptional >> type [

	^ 'optional'
]
