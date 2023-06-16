Class {
	#name : #SBWingParameterStatic,
	#superclass : #SBWingParameter,
	#instVars : [
		'labelMorph',
		'label'
	],
	#category : #'Sandblocks-Wing'
}

{ #category : #'as yet unclassified' }
SBWingParameterStatic >> initialize [

	super initialize.
	self addMorphBack: (labelMorph := SBStringMorph new)
]

{ #category : #'as yet unclassified' }
SBWingParameterStatic >> label: aBlock [

	label := aBlock
]

{ #category : #'as yet unclassified' }
SBWingParameterStatic >> update [

	labelMorph contents: label value
]
