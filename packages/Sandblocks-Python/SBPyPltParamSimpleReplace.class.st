"
Base class of all keyword argument replacements that have a single SBPyPltNumberWithPrefix or SBTextBubble.
"
Class {
	#name : #SBPyPltParamSimpleReplace,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltParamSimpleReplace >> palettes [
"keyword args have no palettes because they can be shown in different contexts."
	^ {}
]

{ #category : #'as yet unclassified' }
SBPyPltParamSimpleReplace >> type [
	^ 'keyword_argument'
]

{ #category : #'as yet unclassified' }
SBPyPltParamSimpleReplace >> writeSourceOn: aStream [

	| isAllDigits |
	isAllDigits := [self firstSubmorph contents asNumber isNumber] on: NumberParserError do: [false].
	
	isAllDigits 
		ifTrue: [aStream nextPutAll: (self firstSubmorph prefix, self firstSubmorph contents)] 
		ifFalse: [aStream nextPutAll: (self firstSubmorph prefix, '"', self firstSubmorph contents, '"')].
]
