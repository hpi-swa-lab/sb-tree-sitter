"
A SBRePalette is a palette for regular expressions. The goal is to enable a user to discover all syntax elements of regular expressions easily and in the editor.

It contains custom replacements grouped by type and a list of all elements of the grammar.
"
Class {
	#name : #SBRePalette,
	#superclass : #SBTSPalette,
	#category : #'Sandblocks-Regex'
}

{ #category : #building }
SBRePalette class >> addAllOf: aCollection to: aBuilder [

		aCollection do: [:block |
			aBuilder addBlock: block value type as: block value]
]

{ #category : #private }
SBRePalette class >> addAllRules: aCollection to: aBuilder [

	aCollection do: [:rule | self addRule: rule to: aBuilder]
]

{ #category : #private }
SBRePalette class >> addRule: aString to: aBuilder [

	aBuilder addBlock: aString as: (SBRegex unknownFor: aString)
]

{ #category : #categories }
SBRePalette class >> assertions [

	^ {
		[SBReLookaroundAssertion newEmpty].
		[SBReSimpleReplacement startAssertion].
		[SBReSimpleReplacement endAssertion]}
]

{ #category : #building }
SBRePalette class >> buildAllRulesOn: aBuilder [

	aBuilder
		addSectionHeader: 'Everything';
		addText: 'All rules in their original form without replacements.'.
	self addAllRules: self rules to: aBuilder
]

{ #category : #building }
SBRePalette class >> buildAssertionsOn: aBuilder [

	aBuilder
		addSectionHeader: 'Assertions';
		addText: 'specify conditions but do not actually consume any characters.'.
	self addAllOf: self assertions to: aBuilder
]

{ #category : #building }
SBRePalette class >> buildCharacterClassesOn: aBuilder [

	aBuilder
		addSectionHeader: 'Character classes';
		addText: 'match one of many possible characters.'.
	self addAllOf: self characterClasses to: aBuilder
]

{ #category : #building }
SBRePalette class >> buildGroupsOn: aBuilder [

	aBuilder
		addSectionHeader: 'Groups';
		addText: 'capture parts of a pattern.'.
	self addAllOf: self groups to: aBuilder
]

{ #category : #building }
SBRePalette class >> buildOn: aBuilder [

	aBuilder addHeader: 'Regex'.
	self
		buildToolsOn: aBuilder;
		buildCharacterClassesOn: aBuilder;
		buildGroupsOn: aBuilder;
		buildQuantifierOn: aBuilder;
		buildAssertionsOn: aBuilder;
		buildAllRulesOn: aBuilder
]

{ #category : #building }
SBRePalette class >> buildQuantifierOn: aBuilder [

	aBuilder
		addSectionHeader: 'Quantifier';
		addText: 'specify how many times an element may repeat.'.
	self addAllOf: self quantifier to: aBuilder
]

{ #category : #building }
SBRePalette class >> buildToolsOn: aBuilder [

	aBuilder addSectionHeader: 'Tools'.
	self addAllOf: self tools to: aBuilder
]

{ #category : #categories }
SBRePalette class >> characterClasses [

	^ {[SBReSimpleReplacement anyCharacter]. [SBReCharacterClassEscape newEmpty]}
]

{ #category : #properties }
SBRePalette class >> factory [

	^ SBRegex
]

{ #category : #categories }
SBRePalette class >> groups [

	^ {[SBReNamedCapturingGroup newEmpty]. [SBRegex unknownFor: 'anonymous_capturing_group']}
]

{ #category : #properties }
SBRePalette class >> language [

	^ SBRegex
]

{ #category : #categories }
SBRePalette class >> quantifier [

	^ {
		[SBReOptional newEmpty].
		[SBReZeroOrMore newEmpty].
		[SBReOneOrMore newEmpty].
		[SBReExactQuantifier newEmpty].
		[SBReQuantifierRange newEmpty]}
]

{ #category : #categories }
SBRePalette class >> rules [

	^ self factory instance grammar rules keys select: [:type | (SBRegex instance grammar bodyNodeForRule: type ifAbsent: [nil]) notNil]
]

{ #category : #categories }
SBRePalette class >> tools [

	^ {
		[SBReComment newAround: (SBRegex unknownFor: 'term')].
		[SBReEvaluator newAround: (SBRegex unknownFor: 'term')]}
]
