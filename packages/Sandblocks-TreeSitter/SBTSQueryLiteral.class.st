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

	(aBlock isTSMorph and: [aBlock slot firstNode isTSLabel and: [aBlock slot firstNode label = (self contents copyFrom: 2 to: self contents size - 1)]]) ifTrue: [^ aBlock].

	self flag: #todo. "remove once we drop support for inlineblocks"
	^ ((aBlock isKindOf: SBInlineBlockLabel) and: [aBlock label = (self contents copyFrom: 2 to: self contents size - 1)])
		ifTrue: [aBlock]
		ifFalse: [nil]
]

{ #category : #'as yet unclassified' }
SBTSQueryLiteral >> predicatesOn: stream [

	
]
