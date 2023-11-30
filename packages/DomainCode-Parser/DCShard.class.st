Class {
	#name : #DCShard,
	#superclass : #SBBlock,
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCShard >> initialize [

	super initialize.
	
	self
		layoutPolicy: TableLayout new;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap
]

{ #category : #'as yet unclassified' }
DCShard >> printOn: aStream [

	aStream nextPutAll: 'Shard('.
	aStream print: self source.
	aStream nextPut: $)
]

{ #category : #'as yet unclassified' }
DCShard >> source [

	^ self hasSubmorphs ifTrue: [self firstSubmorph] ifFalse: [nil]
]

{ #category : #'as yet unclassified' }
DCShard >> update: aBlock [

	self hasSubmorphs
		ifFalse: [self addMorph: aBlock]
		ifTrue: [aBlock = self source ifFalse: [self source replaceBy: aBlock]]
]
