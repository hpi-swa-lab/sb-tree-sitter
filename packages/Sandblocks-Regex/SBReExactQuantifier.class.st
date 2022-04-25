"
A SBReExactQuantifier replaces the {n} quantifier. This is a subset of the {n[,[m]]} syntax for regular expressions and only covers an exact number. For a range, see SBReQuantifierRange.
"
Class {
	#name : #SBReExactQuantifier,
	#superclass : #SBReQuantifier,
	#category : #'Sandblocks-Regex'
}

{ #category : #tests }
SBReExactQuantifier class >> isRange: aDictionary [

	^ ((aDictionary at: 'root') childrenForQuery select: [:each | each slot lastNode type = 'decimal_digits']) size > 1
]

{ #category : #tests }
SBReExactQuantifier class >> isZero: aDictionary [

	^ (aDictionary at: 'value') contents
		ifNotEmpty: [:c | c asNumber = 0]
		ifEmpty: [false]
]

{ #category : #matchers }
SBReExactQuantifier class >> newEmpty [

	^ (SBRegex unknownFor: 'count_quantifier') applyReplacement
]

{ #category : #initialization }
SBReExactQuantifier >> build [
	"Don't replace if the quantify is 0. {0} is used in the encoding of a comment. The comment would not be replaced because the quantifier was replaced first."
	<lang: #regex match: '(count_quantifier
	(decimal_digits) @value
	"?"? @lazy
)'>

	((self class isZero: bindings) or: [self class isRange: bindings]) ifTrue: [^ nil].
	
	self
		addMorphBack: (SBStringMorph new contents: 'exactly:');
		addMorphBack: (self
			createBinding: [
				SBReNumberInput new
					hint: 'number';
					minimum: 0]
			contents: 'value');
		buildLazyToggle
]
