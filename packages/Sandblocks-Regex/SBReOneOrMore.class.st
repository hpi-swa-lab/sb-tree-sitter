"
A SBReOneOrMore replaces the + quantifier.
"
Class {
	#name : #SBReOneOrMore,
	#superclass : #SBReQuantifier,
	#category : #'Sandblocks-Regex'
}

{ #category : #initialization }
SBReOneOrMore >> build [
	<lang: #regex match: '(one_or_more
	"?"? @lazy
)'>

	self
		addMorphBack: (SBStringMorph new contents: 'at least one time');
		buildLazyToggle
]
