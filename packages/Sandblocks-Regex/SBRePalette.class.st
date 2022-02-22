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

	| block |
	block := SBInlineBlockSymbol new
		type: aString
		factory: self factory instance
		block: (self factory build: aString).
	aBuilder addBlock: aString as: block
]

{ #category : #categories }
SBRePalette class >> assertions [

	^ {
		[SBReLookaroundAssertion new].
		[SBReSimpleReplacement startAssertion].
		[SBReSimpleReplacement endAssertion].
	}
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

	^ {
		[SBReVerboseSimpleReplacement anyCharacter].
		[SBReCharacterClassEscape new].
	}
]

{ #category : #'as yet unclassified' }
SBRePalette class >> factory [

	^ SBRegex
]

{ #category : #categories }
SBRePalette class >> groups [

	^ {
		[SBReNamedCapturingGroup new].
		[SBInlineBlockSymbol new
			type: 'anonymous_capturing_group'
			factory: self factory instance
			block: (self factory build: 'anonymous_capturing_group')].
	}
]

{ #category : #'as yet unclassified' }
SBRePalette class >> language [

	^ self factory language
]

{ #category : #categories }
SBRePalette class >> quantifier [

	^ {
		[SBReOptional new].
		[SBReZeroOrMore new].
		[SBReOneOrMore new].
		[SBReExactQuantifier new].
		[SBReQuantifierRange new].
	}
]

{ #category : #categories }
SBRePalette class >> rules [
	
	^ self factory grammarJsonObject rules keys
]

{ #category : #categories }
SBRePalette class >> tools [

	^ {
		[SBReComment new].
		[SBReEvaluator new].
	}
]
