"
This is the parent class of all keyword argument replacements that use a SBPyPltComboBox replacement.
"
Class {
	#name : #SBPyPltParamCBReplace,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltParamCBReplace >> palettes [

	self subclassResponsibility.
]

{ #category : #'as yet unclassified' }
SBPyPltParamCBReplace >> type [
	^ 'keyword_argument'
]

{ #category : #'as yet unclassified' }
SBPyPltParamCBReplace >> writeSourceOn: aStream [

	aStream nextPutAll: (self firstSubmorph prefix, '"', self firstSubmorph contents, '"')
]
