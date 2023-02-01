Class {
	#name : #SBTSQueryPositionConstraint,
	#superclass : #SBTSQueryNode,
	#instVars : [
		'constraint',
		'element'
	],
	#category : #'Sandblocks-TreeSitter-Query'
}

{ #category : #'as yet unclassified' }
SBTSQueryPositionConstraint >> constraint [

	^ constraint
]

{ #category : #'as yet unclassified' }
SBTSQueryPositionConstraint >> constraint: aSymbol [

	constraint := aSymbol
]

{ #category : #'as yet unclassified' }
SBTSQueryPositionConstraint >> element [

	^ element
]

{ #category : #'as yet unclassified' }
SBTSQueryPositionConstraint >> element: anObject [

	element := anObject
]

{ #category : #'as yet unclassified' }
SBTSQueryPositionConstraint >> evaluateAgainst: aBlock captures: aDictionary [

	^ self element evaluateAgainst: aBlock captures: aDictionary
]

{ #category : #'as yet unclassified' }
SBTSQueryPositionConstraint >> isOptional [

	^ self element isOptional
]

{ #category : #'as yet unclassified' }
SBTSQueryPositionConstraint >> predicatesOn: stream [

	self element predicatesOn: stream
]

{ #category : #'as yet unclassified' }
SBTSQueryPositionConstraint >> wrapsNext [

	^ constraint = #first
]

{ #category : #'as yet unclassified' }
SBTSQueryPositionConstraint >> wrapsPrevious [

	^ constraint = #last
]
