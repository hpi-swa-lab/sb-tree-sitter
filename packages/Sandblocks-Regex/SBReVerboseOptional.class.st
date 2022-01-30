Class {
	#name : #SBReVerboseOptional,
	#superclass : #SBReVerboseBlock,
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
SBReVerboseOptional >> initialize [

	super initialize.

	self addMorphBack: (SBInlineBlockLabel new label: 'optional'; factory: self factory)
]

{ #category : #'as yet unclassified' }
SBReVerboseOptional >> sourceString [

	^ '?'
]

{ #category : #'as yet unclassified' }
SBReVerboseOptional >> type [

	^ 'optional'
]
