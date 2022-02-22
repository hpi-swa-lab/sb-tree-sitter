Class {
	#name : #SBReCharacterClassEscape,
	#superclass : #SBReBlock,
	#instVars : [
		'characterClass'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReCharacterClassEscape class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:
'(character_class_escape) @class'>

	^ aBlock 
		value: (aDictionary at: 'class')
		value: (self new
			characterClass: (aDictionary at: 'class') contents)
]

{ #category : #'as yet unclassified' }
SBReCharacterClassEscape >> characterClass [

	^ characterClass object
]

{ #category : #'as yet unclassified' }
SBReCharacterClassEscape >> characterClass: aSymbolOrString [

	characterClass object: ((aSymbolOrString isKindOf: Symbol)
		ifFalse: [self characterClasses at: aSymbolOrString ifAbsent: self characterClasses values first]
		ifTrue: [aSymbolOrString])
]

{ #category : #'as yet unclassified' }
SBReCharacterClassEscape >> characterClasses [

	^ OrderedDictionary newFrom: {
		'\d' -> #digit.
		'\D' -> #not_digit.
		'\s' -> #whitespace.
		'S' -> #not_whitespace.
		'\w' -> #word_character.
		'\W' -> #not_word_character.
	}
]

{ #category : #'as yet unclassified' }
SBReCharacterClassEscape >> characterClassesDisplayStrings [

	^ {
		'digit'.
		'not a digit'.
		'whitespace'.
		'not a whitespace'.
		'word character'.
		'not a word character'.
	}
]

{ #category : #'as yet unclassified' }
SBReCharacterClassEscape >> initialize [

	super initialize.
	
	self addMorphBack: (characterClass := SBReComboBox new
		values: self characterClasses values;
		labels: self characterClassesDisplayStrings;
		placeholderText: 'select class...')
]

{ #category : #'as yet unclassified' }
SBReCharacterClassEscape >> sourceString [

	^ self characterClasses keyAtValue: self characterClass ifAbsent: ''
]

{ #category : #'as yet unclassified' }
SBReCharacterClassEscape >> type [

	^ 'character_class_escape'
]
