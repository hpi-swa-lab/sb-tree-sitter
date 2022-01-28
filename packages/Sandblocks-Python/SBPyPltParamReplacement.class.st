"
The parent class of all keyword argument replacements.
"
Class {
	#name : #SBPyPltParamReplacement,
	#superclass : #SBInlineBlockReplace,
	#instVars : [
		'source'
	],
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltParamReplacement >> palettes [

	^ {SBPyPltPalettePlot}
]

{ #category : #'as yet unclassified' }
SBPyPltParamReplacement >> source: aString [ 
"save source code of this replacement"

	source := aString
]

{ #category : #'as yet unclassified' }
SBPyPltParamReplacement >> writeSourceOn: aStream [
	aStream nextPutAll: source
]
