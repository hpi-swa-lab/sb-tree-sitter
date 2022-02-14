Class {
	#name : #SBReVerboseCharacterClassEscape,
	#superclass : #SBReVerboseBlock,
	#instVars : [
		'characterClass'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReVerboseCharacterClassEscape class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:
'(character_class_escape) @class'>

	^ aBlock 
		value: (aDictionary at: 'class')
		value: (self new
			characterClass: (aDictionary at: 'class') contents)
]

{ #category : #'as yet unclassified' }
SBReVerboseCharacterClassEscape >> characterClass [

	^ characterClass object
]

{ #category : #'as yet unclassified' }
SBReVerboseCharacterClassEscape >> characterClass: aSymbolOrString [

	characterClass object: ((aSymbolOrString isKindOf: Symbol)
		ifFalse: [self characterClasses at: aSymbolOrString ifAbsent: self characterClasses values first]
		ifTrue: [aSymbolOrString])
]

{ #category : #'as yet unclassified' }
SBReVerboseCharacterClassEscape >> characterClasses [

	^ Dictionary newFrom: {
		'\d' -> #digit.
		'\s' -> #whitespace.
		'\w' -> #word_character.
	}
]

{ #category : #'as yet unclassified' }
SBReVerboseCharacterClassEscape >> characterClassesDisplayStrings [

	^ Dictionary newFrom: {
		#digit -> 'digit'.
		#whitespace ->'whitespace'.
		#word_character -> 'word character'.
	}
]

{ #category : #'as yet unclassified' }
SBReVerboseCharacterClassEscape >> initialize [

	super initialize.
	
	self addMorphBack: (characterClass := SBComboBox new
		values: self characterClasses values;
		labels: self characterClassesDisplayStrings values;
		placeholderText: 'select class...')
]

{ #category : #'as yet unclassified' }
SBReVerboseCharacterClassEscape >> sourceString [

	^ '.'
]

{ #category : #'as yet unclassified' }
SBReVerboseCharacterClassEscape >> type [

	^ 'character_class_escape'
]
