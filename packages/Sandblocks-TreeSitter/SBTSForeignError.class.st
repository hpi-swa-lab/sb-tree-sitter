Class {
	#name : #SBTSForeignError,
	#superclass : #Error,
	#instVars : [
		'contents',
		'source'
	],
	#category : #'Sandblocks-TreeSitter'
}

{ #category : #'as yet unclassified' }
SBTSForeignError >> contents [

	^ contents
]

{ #category : #'as yet unclassified' }
SBTSForeignError >> contents: aString [

	contents := aString
]

{ #category : #'as yet unclassified' }
SBTSForeignError >> defaultAction [

	Project current uiManager
		edit: self contents
		label: ('[Error from: {1}]' format: {self source}).
	^ ''
]

{ #category : #'as yet unclassified' }
SBTSForeignError >> source [

	^ source
]

{ #category : #'as yet unclassified' }
SBTSForeignError >> source: aString [

	source := aString
]
