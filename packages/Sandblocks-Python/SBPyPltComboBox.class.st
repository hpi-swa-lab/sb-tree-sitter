"
This class changes its parent class such that the content of the chosen option is shown instead of the content. It adapts to the python palette context.
"
Class {
	#name : #SBPyPltComboBox,
	#superclass : #SBComboBox,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltComboBox >> display: anObject [
"overrides super method to display content of first possible selection item."

	| sBStringMorphs |
	
	anObject isMorph ifTrue: [
			sBStringMorphs := anObject submorphs select: [ :aMorph | aMorph className =  'SBStringMorph' ].
			(sBStringMorphs size > 0) ifTrue: [^ sBStringMorphs first contents]
		] ifFalse: [^ super display: anObject]
]
