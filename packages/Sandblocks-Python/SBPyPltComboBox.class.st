"
Changes parent such that the selection is based on a row, not a string. This enables the use of complex morphs in the dialog.
"
Class {
	#name : #SBPyPltComboBox,
	#superclass : #SBComboBox,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltComboBox >> display: anObject [
"overrides to display text within row"

	anObject ifNil: [^ self display: anObject].
	
	^ anObject firstSubmorph contents.
]
