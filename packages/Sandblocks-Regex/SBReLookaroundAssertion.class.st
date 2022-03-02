"
A SBReLookaroundAssertion replaces a lookaround assertions and offers the four types of lookaround assertions in a dropdown menu with their proper names. This way, a user does not need to remember the exact syntax for each type of assertion.

TODO:
There seems to be a bug with parsing lookbehind assertions:

	SBRegex parse: '(?<=1)'
"
Class {
	#name : #SBReLookaroundAssertion,
	#superclass : #SBRePatternWrapper,
	#instVars : [
		'assertionType'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #matchers }
SBReLookaroundAssertion class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:
'(lookahead_assertion
	(pattern) @pattern
) @assertion'>

	^ aBlock
		value: (aDictionary at: 'assertion')
		value: (self new pattern: (aDictionary at: 'pattern');
						selectAssertionType: (aDictionary at: 'assertion') submorphs first submorphs second submorphs first contents)
]

{ #category : #accessing }
SBReLookaroundAssertion >> assertionType [

	^ assertionType
]

{ #category : #accessing }
SBReLookaroundAssertion >> assertionTypes [

	^ {
		'=' -> 'followed by'.
		'!' -> 'not followed by'.
		'<=' -> 'preceded by'.
		'<!' -> 'not preceded by'.
	}
]

{ #category : #initialization }
SBReLookaroundAssertion >> initialize [

	super initialize.
	
	self
		addMorphBack: (assertionType := SBReSyntaxSelect new
			placeholderText: 'select assertion type...';
			values: self assertionTypes);
		addMorphBack: self pattern
]

{ #category : #accessing }
SBReLookaroundAssertion >> selectAssertionType: aString [

	self assertionType syntax: aString
]

{ #category : #printing }
SBReLookaroundAssertion >> sourceString [

	^ self assertionType syntax
		ifNotNil: ['(?{1}{2})'
			format: {
				self assertionType syntax.
				self pattern sourceString}]
		ifNil: ['']
	
]

{ #category : #accessing }
SBReLookaroundAssertion >> type [

	^ 'lookahead_assertion'
]
