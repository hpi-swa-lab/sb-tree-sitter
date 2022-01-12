Class {
	#name : #SBTSNodeBase,
	#superclass : #Object,
	#instVars : [
		'alias',
		'field',
		'factory'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeBase >> alias [

	^ alias
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> alias: aString [

	alias := aString
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> factory [

	^ factory
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> factory: aFactory [

	factory := aFactory
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> field [

	^ field
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> field: aString [

	field := aString
]
