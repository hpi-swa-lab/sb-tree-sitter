Class {
	#name : #DCCheckbox,
	#superclass : #DCReplacement,
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCCheckbox >> checked [

	^ self firstSubmorph value
]

{ #category : #'as yet unclassified' }
DCCheckbox >> checked: aBoolean [

	self firstSubmorph value: aBoolean
]

{ #category : #'as yet unclassified' }
DCCheckbox >> initialize [

	super initialize.
	
	self addMorphBack: SBCheckbox new
]
