Class {
	#name : #SBReVerboseCharacterClass,
	#superclass : #SBReVerboseBlock,
	#instVars : [
		'number'
	],
	#classInstVars : [
		'negated'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReVerboseCharacterClass class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:
'(character_class
	"^"? @negated
	(class_range)? @class_range
	(_class_atom)? @class_atom
) @character_class'>
	
	| children class_atoms class_ranges |
	
	children := (aDictionary at: 'character_class') childrenForQuery select: [:each | each isSandblock].
	class_ranges := children select: [:each | each  type = 'class_range'].
	class_atoms := children difference: class_ranges.
	negated := aDictionary includesKey: 'negated'
	
	self halt.
	^ aBlock
		value: (aDictionary at: 'character_class')
		value: self new
]

{ #category : #'as yet unclassified' }
SBReVerboseCharacterClass >> initialize [

	super initialize.
]

{ #category : #'as yet unclassified' }
SBReVerboseCharacterClass >> sourceString [

	^ '[',
		']'
]
