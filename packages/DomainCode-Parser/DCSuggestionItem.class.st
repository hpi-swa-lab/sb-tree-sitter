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

{ #category : #'as yet unclassified' }
DCSuggestionItem >> useSuggestionOn: aBlock in: anEditor [

	aBlock useSuggestion: self.
	self completionAction ifNotNil: [self completionAction cull: anEditor]
]
