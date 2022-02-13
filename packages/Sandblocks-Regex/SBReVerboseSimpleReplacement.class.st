Class {
	#name : #SBReVerboseSimpleReplacement,
	#superclass : #SBReVerboseBlock,
	#instVars : [
		'assertionType',
		'label',
		'block'
	],
	#classInstVars : [
		'block'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReVerboseSimpleReplacement class >> matchRegexAnyCharacter: aDictionary do: aBlock [
	<lang: #regex match:
'(any_character) @any'>
 
	^ aBlock
		value: (aDictionary at: 'any')
		value: (self new
			replace: (aDictionary at: 'any') with: 'any')
]

{ #category : #'as yet unclassified' }
SBReVerboseSimpleReplacement >> initialize [

	super initialize.
	
	self addMorphBack: (label := SBInlineBlockLabel new
		factory: self factory)
]

{ #category : #'as yet unclassified' }
SBReVerboseSimpleReplacement >> replace: aBlock with: aString [

	block := aBlock buildCopy.
	label label: aString
]

{ #category : #'as yet unclassified' }
SBReVerboseSimpleReplacement >> sourceString [

	^ block sourceString
]

{ #category : #'as yet unclassified' }
SBReVerboseSimpleReplacement >> type [

	^ block type
]
