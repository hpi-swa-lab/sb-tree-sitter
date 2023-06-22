Class {
	#name : #SBWingParameterNumber,
	#superclass : #SBWingParameterEditable,
	#instVars : [
		'textField'
	],
	#category : #'Sandblocks-Wing'
}

{ #category : #'as yet unclassified' }
SBWingParameterNumber >> initial: aNumber [

	super initial: aNumber.
	aNumber isFloat ifTrue: [self useFloat].
	textField value: aNumber
]

{ #category : #'as yet unclassified' }
SBWingParameterNumber >> initialize [

	super initialize.
	
	self addMorphBack: (textField := SBPyNumberWithPrefix new)
]

{ #category : #'as yet unclassified' }
SBWingParameterNumber >> suffix: aString [

	textField suffix: aString
]

{ #category : #'as yet unclassified' }
SBWingParameterNumber >> updateAll [

	self owner updateAll
]

{ #category : #'as yet unclassified' }
SBWingParameterNumber >> useFloat [

	textField floatSteps
]

{ #category : #'as yet unclassified' }
SBWingParameterNumber >> value [

	^ textField value
]
