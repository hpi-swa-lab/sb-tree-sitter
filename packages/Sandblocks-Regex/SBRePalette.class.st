Class {
	#name : #SBRePalette,
	#superclass : #SBTSPalette,
	#category : #'Sandblocks-Regex'
}

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
SBRePalette class >> buildOn: aBuilder [

	self addAllRules: self rules to: aBuilder
]

{ #category : #'as yet unclassified' }
SBRePalette class >> factory [

	^ SBRegex
]

{ #category : #'as yet unclassified' }
SBRePalette class >> language [

	^ self factory language
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
