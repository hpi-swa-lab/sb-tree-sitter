Class {
	#name : #SBReLookaroundAssertion,
	#superclass : #SBRePatternWrapper,
	#instVars : [
		'assertionType'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReLookaroundAssertion class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:
'(lookahead_assertion
	(pattern) @pattern
) @assertion'>

	^ aBlock
		value: (aDictionary at: 'assertion')
		value: (self new pattern: (aDictionary at: 'pattern');
						assertionType: (aDictionary at: 'assertion') submorphs first submorphs second submorphs first contents)
]

{ #category : #'as yet unclassified' }
SBReLookaroundAssertion >> assertionType [

	^ assertionType object
]

{ #category : #'as yet unclassified' }
SBReLookaroundAssertion >> assertionType: aSymbolOrString [

	assertionType object: ((aSymbolOrString isKindOf: Symbol)
		ifFalse: [self assertionTypes at: aSymbolOrString ifAbsent: self assertionTypes values first]
		ifTrue: [aSymbolOrString])
]

{ #category : #'as yet unclassified' }
SBReLookaroundAssertion >> assertionTypes [

	^ OrderedDictionary newFrom: {
		'=' -> #positive_lookahead.
		'!' -> #negative_lookahead.
		'<=' -> #positive_lookbehind.
		'<!' -> #negative_lookbehind.
	}
]

{ #category : #'as yet unclassified' }
SBReLookaroundAssertion >> assertionTypesDisplayStrings [

	^ {
		'followed by'.
		'not followed by'.
		'preceeded by'.
		'not preceded by'.
	}
]

{ #category : #'as yet unclassified' }
SBReLookaroundAssertion >> initialize [

	super initialize.
	
	self
		addMorphBack: (assertionType := SBReComboBox new
			values: self assertionTypes values;
			labels: self assertionTypesDisplayStrings;
			placeholderText: 'select assertion type...');
		addMorphBack: self pattern
]

{ #category : #'as yet unclassified' }
SBReLookaroundAssertion >> sourceString [

	^ self assertionType notNil
		ifTrue: ['(?{1}{2})'
			format: {
				self assertionTypes keyAtValue: self assertionType .
				self pattern sourceString}]
		ifFalse: ['']
	
]

{ #category : #'as yet unclassified' }
SBReLookaroundAssertion >> type [

	^ 'lookahead_assertion'
]
