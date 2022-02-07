"
Base class of all keyword argument replacements that have a custom replacement.
"
Class {
	#name : #SBPyPltParamCustomReplace,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltParamCustomReplace >> palettes [

	^{}
]

{ #category : #'as yet unclassified' }
SBPyPltParamCustomReplace >> type [
	^ 'keyword_argument'
]

{ #category : #'as yet unclassified' }
SBPyPltParamCustomReplace >> writeSourceOn: aStream [
	self subclassResponsibility
]
