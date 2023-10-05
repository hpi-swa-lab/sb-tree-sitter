Class {
	#name : #DCEmbedMarker,
	#superclass : #Morph,
	#instVars : [
		'source'
	],
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCEmbedMarker >> isReplacement [

	^ true
]

{ #category : #'as yet unclassified' }
DCEmbedMarker >> source [

	^ source
]

{ #category : #'as yet unclassified' }
DCEmbedMarker >> source: aBlock [

	source := aBlock
]
