Class {
	#name : #SBReVerboseOneOrMore,
	#superclass : #SBReVerboseQuantifier,
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
SBReVerboseOneOrMore >> buildOn: aSBRow [

	aSBRow addMorphBack: (SBInlineBlockLabel new label: 'at least one time'; factory: self factory)
]

{ #category : #'as yet unclassified' }
SBReVerboseOneOrMore >> buildSelf [

	self addMorphBack: (SBInlineBlockLabel new label: 'at least one time'; factory: self factory)
]

{ #category : #'as yet unclassified' }
SBReVerboseOneOrMore >> quantifierString [

	^ '+'
]

{ #category : #'as yet unclassified' }
SBReVerboseOneOrMore >> type [

	^ 'one_or_more'
]
