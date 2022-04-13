"
A SBReOneOrMore replaces the ? quantifier.
"
Class {
	#name : #SBReOptional,
	#superclass : #SBReQuantifier,
	#category : #'Sandblocks-Regex'
}

{ #category : #initialization }
SBReOptional >> build [
	<lang: #regex match: '(optional
	"?"
	"?"? @lazy
) @optional'>

	
	self
		addMorphBack: (SBStringMorph new contents: 'optional');
		buildLazyToggle
]
