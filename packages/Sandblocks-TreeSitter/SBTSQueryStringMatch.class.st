Class {
	#name : #SBTSQueryStringMatch,
	#superclass : #SBTSQueryNode,
	#instVars : [
		'contents',
		'element'
	],
	#category : #'Sandblocks-TreeSitter-Query'
}

{ #category : #'as yet unclassified' }
SBTSQueryStringMatch >> contents [

	^ contents
]

{ #category : #'as yet unclassified' }
SBTSQueryStringMatch >> contents: aString [

	contents := aString
]

{ #category : #'as yet unclassified' }
SBTSQueryStringMatch >> element [

	^ element
]

{ #category : #'as yet unclassified' }
SBTSQueryStringMatch >> element: anObject [

	element := anObject
]

{ #category : #'as yet unclassified' }
SBTSQueryStringMatch >> evaluateAgainst: aBlock captures: aDictionary [

	| block |
	block := self element evaluateAgainst: aBlock captures: aDictionary.
	block ifNil: [^ nil].
	block contents = (self contents allButFirst: 2) allButLast ifFalse: [^ nil].
	^ block
]

{ #category : #'as yet unclassified' }
SBTSQueryStringMatch >> isOptional [

	^ self element isOptional
]

{ #category : #'as yet unclassified' }
SBTSQueryStringMatch >> predicatesOn: stream [

	
]

{ #category : #'as yet unclassified' }
SBTSQueryStringMatch >> requiresField [

	^ self element requiresField
]

{ #category : #'as yet unclassified' }
SBTSQueryStringMatch >> wrapsPrevious [

	^ true
]
