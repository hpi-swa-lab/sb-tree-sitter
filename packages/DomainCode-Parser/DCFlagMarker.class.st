Class {
	#name : #DCFlagMarker,
	#superclass : #DCReplacement,
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCFlagMarker >> initialize [

	super initialize.
	
	self
		addMorphBack: SBIcon iconFlag;
		layoutInset: 4
]
