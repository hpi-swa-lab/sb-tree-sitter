"
A SBReCharacterClassEscape replaces a character class escape.

Character class escapes represent a set of multiple acceptable characters, for example \d for all digits (0 to 9) or \s for all whitespaces.

To help the user, this is a selection that allows selecting the type of character class by a descriptive name instead of by syntax.
"
Class {
	#name : #SBReCharacterClassEscape,
	#superclass : #SBTSReplacementBlock,
	#instVars : [
		'characterClass'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #matchers }
SBReCharacterClassEscape class >> newEmpty [

	^ (SBRegex parseExpression: '\d') applyReplacement
]

{ #category : #accessing }
SBReCharacterClassEscape >> build [
	<lang: #regex match: '(character_class_escape) @class'>

	self addMorphBack: (self
		createBinding: [
			SBSelect new
				placeholderText: 'select character class';
				entries: self characterClasses]
		object: 'class')
]

{ #category : #accessing }
SBReCharacterClassEscape >> characterClass [

	^ characterClass
]

{ #category : #accessing }
SBReCharacterClassEscape >> characterClasses [

	^ {
		'\d' -> 'digit'.
		'\D' -> 'not a digit'.
		'\s' -> 'whitespace character'.
		'\S' -> 'not a whitespace character'.
		'\w' -> 'word character'.
		'\W' -> 'not a word character'.
	}
]

{ #category : #accessing }
SBReCharacterClassEscape >> selectCharacterClass: aString [

	self characterClass syntax: aString
]

{ #category : #printing }
SBReCharacterClassEscape >> sourceString [

	^ self characterClass syntax ifNil: ['']
]

{ #category : #accessing }
SBReCharacterClassEscape >> type [

	^ 'character_class_escape'
]
