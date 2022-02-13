Class {
	#name : #SBReVerboseOptional,
	#superclass : #SBReVerboseQuantifier,
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReVerboseOptional class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:
'(optional) @optional'>

	^ aBlock
		value: (aDictionary at: 'optional')
		value: (self new)
]

{ #category : #'as yet unclassified' }
SBReVerboseOptional >> buildOn: aSBRow [

	aSBRow addMorphBack: (SBInlineBlockLabel new label: 'optional'; factory: self factory)
]

{ #category : #'as yet unclassified' }
SBReVerboseOptional >> buildSelf [

	self addMorphBack: (SBInlineBlockLabel new label: 'optional'; factory: self factory)
]

{ #category : #'as yet unclassified' }
SBReVerboseOptional >> quantifierString [

	^ '?'
]

{ #category : #'as yet unclassified' }
SBReVerboseOptional >> type [

	^ 'optional'
]
