"
A SBReExactQuantifier replaces the {n,m} quantifier. This is a subset of the {n[,[m]]} syntax for regular expressions and only covers an range. For a an exact number, see SBReQuantifierRange or use {n,n}.

The {n,} and {,n} variations are currently not supported by the regex grammar.
"
Class {
	#name : #SBReQuantifierRange,
	#superclass : #SBReQuantifier,
	#instVars : [
		'minimum',
		'maximum'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #accessing }
SBReQuantifierRange >> build [
	<lang: #regex match: '(count_quantifier
	(decimal_digits) @minimum
	(decimal_digits) @maximum
	"?"? @lazy
) @count_quantifier'>

	self
		addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: 'at least:');
			addMorphBack: (minimum := self
				createBinding: [
					SBReNumberInput new
						hint: 'min';
						minimum: 0]
				contents: 'minimum'));
		addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: 'at most:');
			addMorphBack: (maximum := self
				createBinding: [
					SBReNumberInput new
						hint: 'max';
						minimum: 0]
				contents: 'maximum'));
		buildLazyToggle.
	
	minimum onChange: [:value | maximum minimum: value].
	maximum onChange: [:value | minimum maximum: value]
]
