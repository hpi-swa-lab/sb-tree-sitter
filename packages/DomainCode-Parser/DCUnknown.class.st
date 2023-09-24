Class {
	#name : #DCUnknown,
	#superclass : #DCBlock,
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCUnknown >> initialize [

	super initialize.
	
	self type: #empty.
	
	self addMorphBack: (DCText new
		contents: '';
		range: SBTSRange null)
]

{ #category : #'as yet unclassified' }
DCUnknown >> prefersNoBorder [

	^ true
]
