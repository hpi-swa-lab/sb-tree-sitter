Class {
	#name : #DCSuggestionItem,
	#superclass : #SBSuggestionItem,
	#instVars : [
		'source'
	],
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCSuggestionItem >> selector: aString label: anotherString source: aThirdString [

	self selector: aString label: anotherString.
	source := aThirdString
]

{ #category : #'as yet unclassified' }
DCSuggestionItem >> source [

	^ source
]
