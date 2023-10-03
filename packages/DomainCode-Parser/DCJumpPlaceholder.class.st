Class {
	#name : #DCJumpPlaceholder,
	#superclass : #DCReplacement,
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCJumpPlaceholder >> initialize [

	super initialize.
	
	self addMorphBack: DCText new
]

{ #category : #'as yet unclassified' }
DCJumpPlaceholder >> valid [

	^ false
]
