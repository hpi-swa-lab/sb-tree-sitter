Class {
	#name : #SBWingParameterDerived,
	#superclass : #SBWingParameterStatic,
	#instVars : [
		'value'
	],
	#category : #'Sandblocks-Wing'
}

{ #category : #'as yet unclassified' }
SBWingParameterDerived >> update [

	labelMorph contents: (label value: self value)
]

{ #category : #'as yet unclassified' }
SBWingParameterDerived >> value [

	^ value value
]

{ #category : #'as yet unclassified' }
SBWingParameterDerived >> value: aBlock [

	value := aBlock
]
