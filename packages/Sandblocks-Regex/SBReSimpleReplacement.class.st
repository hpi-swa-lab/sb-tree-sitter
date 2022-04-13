"
A SBReSimpleReplacement replaces any block with a simple textual description to make the syntax more readable.

To replace a aBlock with a aString, use the replace: aBlock with: aString method.

Predefined replacements and the corresponding replacement rules are available on the class side.
"
Class {
	#name : #SBReSimpleReplacement,
	#superclass : #SBTSReplacementBlock,
	#classInstVars : [
		'block'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #initialize }
SBReSimpleReplacement >> buildAnyCharacter [
	<lang: #regex match: '(any_character)'>

	self addMorphBack: (SBStringMorph new contents: 'any')
]

{ #category : #initialize }
SBReSimpleReplacement >> buildEndAssertion [
	<lang: #regex match: '(end_assertion)'>

	self addMorphBack: (SBStringMorph new contents: 'end')
]

{ #category : #initialize }
SBReSimpleReplacement >> buildStartAssertion [
	<lang: #regex match: '(start_assertion)'>

	self addMorphBack: (SBStringMorph new contents: 'start')
]
