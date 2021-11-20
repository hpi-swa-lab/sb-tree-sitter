Class {
	#name : #SBTSQueryField,
	#superclass : #SBTSQueryNode,
	#instVars : [
		'element',
		'contents'
	],
	#category : #'Sandblocks-TreeSitter-Query'
}

{ #category : #'as yet unclassified' }
SBTSQueryField >> contents [

	^ contents
]

{ #category : #'as yet unclassified' }
SBTSQueryField >> contents: aString [

	contents := aString
]

{ #category : #'as yet unclassified' }
SBTSQueryField >> element [

	^ element
]

{ #category : #'as yet unclassified' }
SBTSQueryField >> element: anObject [

	element := anObject
]

{ #category : #'as yet unclassified' }
SBTSQueryField >> evaluateAgainst: aBlock captures: aDictionary [

	self assert: aBlock field = self field.
	^ self element evaluateAgainst: aBlock captures: aDictionary
]

{ #category : #'as yet unclassified' }
SBTSQueryField >> field [

	^ self contents allButLast
]

{ #category : #'as yet unclassified' }
SBTSQueryField >> isOptional [

	^ self element isOptional
]

{ #category : #'as yet unclassified' }
SBTSQueryField >> predicatesOn: stream [

	self element predicatesOn: stream
]

{ #category : #'as yet unclassified' }
SBTSQueryField >> requiresField [

	^ self field
]

{ #category : #'as yet unclassified' }
SBTSQueryField >> wrapsNext [

	^ true
]
