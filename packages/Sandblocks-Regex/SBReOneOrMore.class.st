Class {
	#name : #SBReOneOrMore,
	#superclass : #SBReQuantifier,
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReOneOrMore class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:'
(one_or_more
	"?"? @lazy
) @one_or_more'>

	^ aBlock
		value: (aDictionary at: 'one_or_more')
		value: (self new
			lazy: (aDictionary includesKey: 'lazy'))
]

{ #category : #'as yet unclassified' }
SBReOneOrMore >> buildOn: aSBRow [

	aSBRow addMorphBack: (SBInlineBlockLabel new
		label: 'at least one time';
		factory: self factory)
]

{ #category : #'as yet unclassified' }
SBReOneOrMore >> buildSelf [

	self addMorphBack: (SBInlineBlockLabel new label: 'at least one time'; factory: self factory)
]

{ #category : #'as yet unclassified' }
SBReOneOrMore >> quantifierString [

	^ '+'
]

{ #category : #'as yet unclassified' }
SBReOneOrMore >> type [

	^ 'one_or_more'
]
