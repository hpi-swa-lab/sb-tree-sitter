Class {
	#name : #SBTSNodeSymbol,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'type'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeSymbol >> printOn: aStream [

	aStream nextPutAll: type
]

{ #category : #'as yet unclassified' }
SBTSNodeSymbol >> type [

	^ type
]

{ #category : #'as yet unclassified' }
SBTSNodeSymbol >> type: aString factory: aFactory [

	type := aString.
	factory := aFactory
]
