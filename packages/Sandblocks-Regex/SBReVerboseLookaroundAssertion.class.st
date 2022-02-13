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
SBReVerboseLookaroundAssertion >> assertionType [

	^ assertionType object
]

{ #category : #'as yet unclassified' }
SBReVerboseLookaroundAssertion >> assertionType: symbolOrString [

	assertionType object: ((symbolOrString isKindOf: Symbol)
		ifFalse: [self assertionTypes at: symbolOrString ifAbsent: self assertionTypes values first]
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
			labels: self assertionTypesDisplayStrings;
			placeholderText: 'assertion type');
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

	(self submorphs at: 2) replaceBy: aBlock buildCopy
]

{ #category : #'as yet unclassified' }
SBReVerboseLookaroundAssertion >> sourceString [

	^ self assertionType notNil
		ifTrue: [
			'(?',
			(self assertionTypes keyAtValue: self assertionType),
			self pattern sourceString,
			')']
		ifFalse: [''] 
	
]

{ #category : #'as yet unclassified' }
SBReVerboseLookaroundAssertion >> type [

	^ 'lookahead_assertion'
]
