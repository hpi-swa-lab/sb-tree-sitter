"
This is the parent class of all keyword argument replacements that have a single SBPyPltNumberWithPrefix or SBTextBubble as replacement.
"
Class {
	#name : #SBPyPltParamSimpleReplace,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltParamSimpleReplace >> palettes [

	self subclassResponsibility.
]

{ #category : #'as yet unclassified' }
SBPyPltParamSimpleReplace >> type [
	^ 'keyword_argument'
]

{ #category : #'as yet unclassified' }
SBPyPltParamSimpleReplace >> writeSourceOn: aStream [

	| isAllDigits |
	isAllDigits := self firstSubmorph contents isAllDigits.
	
	isAllDigits 
		ifTrue: [aStream nextPutAll: (self firstSubmorph prefix, self firstSubmorph contents)] 
		ifFalse: [aStream nextPutAll: (self firstSubmorph prefix, '"', self firstSubmorph contents, '"')].
]
