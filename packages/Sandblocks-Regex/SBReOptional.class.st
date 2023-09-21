"
A SBReOneOrMore replaces the ? quantifier.
"
Class {
	#name : #SBReOptional,
	#superclass : #SBReQuantifier,
	#category : #'Sandblocks-Regex'
}

{ #category : #matchers }
SBReOptional class >> newEmpty [

	^ (SBRegex unknownFor: 'optional') applyReplacement
]

{ #category : #initialization }
SBReOptional >> build [
	<lang: #regex match: '(optional
	"?"? @lazy
) @optional' sample: 'a?'>

	self
		addMorphBack: (SBStringMorph new contents: 'optional');
		buildLazyToggle
]
