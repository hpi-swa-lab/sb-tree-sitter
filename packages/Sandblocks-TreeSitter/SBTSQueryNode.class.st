Class {
	#name : #SBTSQueryNode,
	#superclass : #Object,
	#category : #'Sandblocks-TreeSitter-Query'
}

{ #category : #'as yet unclassified' }
SBTSQueryNode >> evaluateAgainst: aBlock captures: aDictionary [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBTSQueryNode >> isOptional [

	^ false
]

{ #category : #'as yet unclassified' }
SBTSQueryNode >> predicatesOn: stream [

	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBTSQueryNode >> requiresField [

	^ nil
]

{ #category : #'as yet unclassified' }
SBTSQueryNode >> wrapsNext [

	^ false
]

{ #category : #'as yet unclassified' }
SBTSQueryNode >> wrapsPrevious [

	^ false
]
