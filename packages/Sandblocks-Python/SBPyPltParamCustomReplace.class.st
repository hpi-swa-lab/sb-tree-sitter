"
This is the parent class of all keyword argument replacements that have a custom replacement. Each child needs to implement writeSourceOn: 
"
Class {
	#name : #SBPyPltParamCustomReplace,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltParamCustomReplace >> palettes [

	self subclassResponsibility.
]

{ #category : #'as yet unclassified' }
SBPyPltParamCustomReplace >> type [
	^ 'keyword_argument'
]

{ #category : #'as yet unclassified' }
SBPyPltParamCustomReplace >> writeSourceOn: aStream [
	self subclassResponsibility
]
