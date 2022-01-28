Class {
	#name : #SBReVerboseLookaroundAssertion,
	#superclass : #SBReVerboseBlock,
	#instVars : [
		'assertionType'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReVerboseLookaroundAssertion class >> matchRegex: aDictionary do: aBlock [
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
SBReVerboseLookaroundAssertion class >> newFor: aBlock as: aTextBlock [

	^ self new
		name: aTextBlock;
		pattern: aBlock
]

{ #category : #'as yet unclassified' }
SBReVerboseLookaroundAssertion >> assertionType [

	^ assertionType value
]

{ #category : #'as yet unclassified' }
SBReVerboseLookaroundAssertion >> assertionType: symbolOrString [

	assertionType object: ((symbolOrString isKindOf: Symbol)
		ifFalse: [self assertionTypes at: symbolOrString]
		ifTrue: [symbolOrString])
]

{ #category : #'as yet unclassified' }
SBReVerboseLookaroundAssertion >> assertionTypes [

	^ Dictionary newFrom: {
		'=' -> #positive_lookahead.
		'!' -> #negative_lookahead.
		'<=' -> #positive_lookbehind.
		'<!' -> #negative_lookbehind.
	}
]

{ #category : #'as yet unclassified' }
SBReVerboseLookaroundAssertion >> assertionTypesDisplayStrings [

	^ {
		'followed by'.
		'not followed by'.
		'preceeded by'.
		'not preceded by'.
	}
]

{ #category : #'as yet unclassified' }
SBReVerboseLookaroundAssertion >> initialize [

	super initialize.
	
	self
		addMorphBack: (assertionType := SBComboBox new
			values: self assertionTypes values;
			labels: self assertionTypesDisplayStrings);
		addMorphBack: (SBTSUnknown new
			factory: self factory;
			template: (self factory getTemplate: 'pattern'))
]

{ #category : #'as yet unclassified' }
SBReVerboseLookaroundAssertion >> pattern [

	^ self submorphs at: 2
]

{ #category : #'as yet unclassified' }
SBReVerboseLookaroundAssertion >> pattern: aBlock [

	(self submorphs at: 2) replaceBy: aBlock
]

{ #category : #'as yet unclassified' }
SBReVerboseLookaroundAssertion >> type [

	^ 'lookahead_assertion'
]

{ #category : #'as yet unclassified' }
SBReVerboseLookaroundAssertion >> writeSourceOn: aStream [

	self halt.
	aStream
		nextPutAll: '(?';
		nextPutAll: (self assertionType keyAtValue: self assertionType);
		nextPutAll: self pattern sourceString;
		nextPutAll: ')'
]
