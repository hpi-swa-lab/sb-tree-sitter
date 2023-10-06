Class {
	#name : #DCEmbedContainer,
	#superclass : #DCBlock,
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCEmbedContainer >> printOn [

	
]

{ #category : #'as yet unclassified' }
DCEmbedContainer >> printOn: aStream [

	aStream nextPutAll: 'EmbedContainer('.
	aStream print: source.
	aStream nextPut: $)
]

{ #category : #'as yet unclassified' }
DCEmbedContainer >> resolveSource [

	^ self source resolveSource
]

{ #category : #'as yet unclassified' }
DCEmbedContainer >> source [

	^ self firstSubmorph
]

{ #category : #'as yet unclassified' }
DCEmbedContainer >> source: aBlock [

	self addMorphBack: aBlock
]

{ #category : #'as yet unclassified' }
DCEmbedContainer >> type [

	^ ''
]

{ #category : #'as yet unclassified' }
DCEmbedContainer >> updateWith: aBlock [

	source = aBlock ifFalse: [
		source replacedParent source: aBlock.
		source replacedParent: nil.
		source owner = self ifTrue: [source delete].
		self source: aBlock]
]
