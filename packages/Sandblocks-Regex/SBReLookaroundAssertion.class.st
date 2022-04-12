"
A SBReLookaroundAssertion replaces a lookaround assertions and offers the four types of lookaround assertions in a dropdown menu with their proper names. This way, a user does not need to remember the exact syntax for each type of assertion.

TODO:
There seems to be a bug with parsing lookbehind assertions:

	SBRegex parse: '(?<=1)'
"
Class {
	#name : #SBReLookaroundAssertion,
	#superclass : #SBTSReplacementBlock,
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
SBReLookaroundAssertion >> assertionTypes [

	^ {
		'=' -> 'followed by'.
		'!' -> 'not followed by'.
		'<=' -> 'preceded by'.
		'<!' -> 'not preceded by'.
	}
]

{ #category : #accessing }
SBReLookaroundAssertion >> build [
	<lang: #regex match: '(lookahead_assertion
	(pattern) @pattern
) @assertion'>

	self addMorphBack: (self
		createBinding: [:c |
			SBSelect new
				placeholderText: 'select assertion type...';
				entries: self assertionTypes;
				object: (c at: 'assertion') textMorphs second contents]
		update: [:c :m | (c at: 'assertion') textMorphs second contents: m object]).
	self addMorphBack: (self createBindingBlock: 'pattern')
]
