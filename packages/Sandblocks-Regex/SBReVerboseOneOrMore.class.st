Class {
	#name : #SBReVerboseOneOrMore,
	#superclass : #SBReVerboseBlock,
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReVerboseOneOrMore class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:
'(one_or_more) @one_or_more'>

	^ aBlock
		value: (aDictionary at: 'one_or_more')
		value: (self new)
]

{ #category : #'as yet unclassified' }
SBReVerboseOneOrMore >> initialize [

	super initialize.

	self addMorphBack: (SBInlineBlockLabel new label: 'at least one time'; factory: self factory)
]

{ #category : #'as yet unclassified' }
SBReVerboseOneOrMore >> sourceString [

	^ '+'
]

{ #category : #'as yet unclassified' }
SBReVerboseOneOrMore >> type [

	^ 'one_or_more'
]
