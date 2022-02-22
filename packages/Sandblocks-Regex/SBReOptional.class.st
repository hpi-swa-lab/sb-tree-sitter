Class {
	#name : #SBReOptional,
	#superclass : #SBReQuantifier,
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReOptional class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:
'(optional
	"?"
	"?"? @lazy
) @optional'>

	^ aBlock
		value: (aDictionary at: 'optional')
		value: (self new
			lazy: (aDictionary includesKey: 'lazy'))
]

{ #category : #'as yet unclassified' }
SBReOptional >> buildOn: aSBRow [

	aSBRow addMorphBack: (SBInlineBlockLabel new label: 'optional'; factory: self factory)
]

{ #category : #'as yet unclassified' }
SBReOptional >> buildSelf [

	self addMorphBack: (SBInlineBlockLabel new label: 'optional'; factory: self factory)
]

{ #category : #'as yet unclassified' }
SBReOptional >> quantifierString [

	^ '?'
]

{ #category : #'as yet unclassified' }
SBReOptional >> type [

	^ 'optional'
]
