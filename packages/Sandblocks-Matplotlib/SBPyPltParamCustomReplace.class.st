"
Base class of all keyword argument replacements that have a custom replacement.
"
Class {
	#name : #SBPyPltParamCustomReplace,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Matplotlib'
}

{ #category : #classification }
SBPyPltParamCustomReplace >> palettes [

	^{}
]

{ #category : #classification }
SBPyPltParamCustomReplace >> type [
	^ 'keyword_argument'
]

{ #category : #copying }
SBPyPltParamCustomReplace >> writeSourceOn: aStream [
	self subclassResponsibility
]
