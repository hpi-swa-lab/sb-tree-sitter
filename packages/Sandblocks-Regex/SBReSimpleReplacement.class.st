"
A SBReSimpleReplacement replaces any block with a simple textual description to make the syntax more readable.

To replace a aBlock with a aString, use the replace: aBlock with: aString method.

Predefined replacements and the corresponding replacement rules are available on the class side.
"
Class {
	#name : #SBReSimpleReplacement,
	#superclass : #SBReBlock,
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

{ #category : #'instance creation' }
SBReSimpleReplacement class >> anyCharacter [

	^ self type: 'any_character' as: 'any'
]

{ #category : #'instance creation' }
SBReSimpleReplacement class >> endAssertion [

	^ self type: 'end_assertion' as: 'end'
]

{ #category : #matchers }
SBReSimpleReplacement class >> matchRegexAnyCharacter: aDictionary do: aBlock [
	<lang: #regex match:
'(any_character) @any'>
 
	^ aBlock
		value: (aDictionary at: 'any')
		value: self anyCharacter
]

{ #category : #matchers }
SBReSimpleReplacement class >> matchRegexEndAssertion: aDictionary do: aBlock [
	<lang: #regex match:
'(end_assertion) @end'>
 
	^ aBlock
		value: (aDictionary at: 'end')
		value: self endAssertion
]

{ #category : #matchers }
SBReSimpleReplacement class >> matchRegexStartAssertion: aDictionary do: aBlock [
	<lang: #regex match:
'(start_assertion) @start'>
 
	^ aBlock
		value: (aDictionary at: 'start')
		value: self startAssertion
]

{ #category : #'instance creation' }
SBReSimpleReplacement class >> startAssertion [

	^ self type: 'start_assertion' as: 'start'
]

{ #category : #'instance creation' }
SBReSimpleReplacement class >> type: aTypeString as: aString [

	^ self new
		replace: (SBInlineBlockSymbol new
			type: aTypeString
			factory: self factory
			block: (SBRegex build: aTypeString))
		with: aString
]

{ #category : #initialization }
SBReSimpleReplacement >> initialize [

	super initialize.
	
	self addMorphBack: (label := SBInlineBlockLabel new
		factory: self factory)
]

{ #category : #initialization }
SBReSimpleReplacement >> replace: aBlock with: aString [

	block := aBlock buildCopy.
	label label: aString
]

{ #category : #printing }
SBReSimpleReplacement >> sourceString [

	^ block sourceString
]

{ #category : #accessing }
SBReSimpleReplacement >> type [

	^ block type
]
