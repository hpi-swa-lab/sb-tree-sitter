Class {
	#name : #SBRePalette,
	#superclass : #SBTSPalette,
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
SBRePalette class >> assertions [

	^ {
		[SBReVerboseLookaroundAssertion new].
		[SBInlineBlockSymbol new
			type: 'start_assertion'
			factory: self factory instance
			block: (self factory build: 'start_assertion')].
		[SBInlineBlockSymbol new
			type: 'end_assertion'
			factory: self factory instance
			block: (self factory build: 'end_assertion')].
	}
]

{ #category : #'as yet unclassified' }
SBRePalette class >> buildOn: aBuilder [

	aBuilder
		addHeader: 'Regex';
		addSectionHeader: 'Quantifier';
		addText: 'Specifiy how many times an element may repeat.'.
	self addAllOf: self quantifier to: aBuilder.
	aBuilder addSectionHeader: 'Groups'.
	self addAllOf: self groups to: aBuilder.
	aBuilder addSectionHeader: 'Assertions'.
	aBuilder addText: 'Specify conditions without actually matching anything.'.
	self addAllOf: self assertions to: aBuilder.
	
	aBuilder addSectionHeader: 'Everything'.
	
	self addAllRules: self rules to: aBuilder
]

{ #category : #'as yet unclassified' }
SBRePalette class >> factory [

	^ SBRegex
]

{ #category : #'as yet unclassified' }
SBRePalette class >> groups [

	^ {
		[SBReVerboseNamedCapturingGroup new].
		[SBInlineBlockSymbol new
			type: 'anonymous_capturing_group'
			factory: self factory instance
			block: (self factory build: 'anonymous_capturing_group')].
		[SBReVerboseComment new].
	}
]

{ #category : #'as yet unclassified' }
SBRePalette class >> language [

	^ self factory language
]

{ #category : #'as yet unclassified' }
SBRePalette class >> quantifier [

	^ {
		[SBReVerboseOptional new].
		[SBReVerboseZeroOrMore new].
		[SBReVerboseOneOrMore new].
		[SBReVerboseQuantifier new].
		[SBReVerboseQuantifierRange new].
	}
]

{ #category : #'as yet unclassified' }
SBRePalette class >> rules [
	
	^ self factory grammarJsonObject rules keys
	"^ {
	'disjunction'.

	'optional'.
	'zero_or_more'.
	'one_or_more'.

	'start_assertion'.
	'end_assertion'.
	'boundary_assertion'.
	'non_boundary_assertion'.
	'lookahead_assertion'.

	'anonymous_capturing_group'.
	'named_capturing_group'.
	'non_capturing_group'.
	
	'backreference_escape'.

	'any_character'.
	'character_class'.

	'count_quantifier'.}"
]
