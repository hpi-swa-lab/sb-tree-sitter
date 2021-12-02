Class {
	#name : #SBTSQueryLiteral,
	#superclass : #SBTSQueryNode,
	#instVars : [
		'contents'
	],
	#category : #'Sandblocks-TreeSitter-Query'
}

{ #category : #'as yet unclassified' }
SBTSQueryLiteral >> contents [

	^ contents
]

{ #category : #'as yet unclassified' }
SBTSQueryLiteral >> contents: aString [

	contents := aString
]

{ #category : #'as yet unclassified' }
SBTSQueryLiteral >> evaluateAgainst: aBlock captures: aDictionary [

	^ ((aBlock isKindOf: SBInlineBlockLabel) and: [aBlock label = (self contents copyFrom: 2 to: self contents size - 1)])
		ifTrue: [aBlock]
		ifFalse: [nil]
]

{ #category : #'as yet unclassified' }
SBTSQueryLiteral >> predicatesOn: stream [

	
]
