"
A SBReCharacterClassEscape replaces a character class escape.

Character class escapes represent a set of multiple acceptable characters, for example \d for all digits (0 to 9) or \s for all whitespaces.

To help the user, this is a selection that allows selecting the type of character class by a descriptive name instead of by syntax.
"
Class {
	#name : #SBReCharacterClassEscape,
	#superclass : #SBReBlock,
	#instVars : [
		'characterClass'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #matchers }
SBReCharacterClassEscape class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:
'(character_class_escape) @class'>

	^ aBlock 
		value: (aDictionary at: 'class')
		value: (self new selectCharacterClass: (aDictionary at: 'class') contents)
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

{ #category : #initialization }
SBReCharacterClassEscape >> initialize [

	super initialize.
	
	self addMorphBack: (characterClass := SBReSyntaxSelect new
		placeholderText: 'select character class';
		values: self characterClasses)
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
