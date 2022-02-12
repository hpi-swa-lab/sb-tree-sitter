Class {
	#name : #SBTSQueryCapture,
	#superclass : #SBTSQueryNode,
	#instVars : [
		'contents',
		'element'
	],
	#category : #'Sandblocks-TreeSitter-Query'
}

{ #category : #'as yet unclassified' }
SBTSQueryCapture >> contents [

	^ contents
]

{ #category : #'as yet unclassified' }
SBTSQueryCapture >> contents: aString [

	contents := aString
]

{ #category : #'as yet unclassified' }
SBTSQueryCapture >> element [

	^ element
]

{ #category : #'as yet unclassified' }
SBTSQueryCapture >> element: anObject [

	element := anObject
]

{ #category : #'as yet unclassified' }
SBTSQueryCapture >> evaluateAgainst: aBlock captures: aDictionary [

	| block |
	block := self element evaluateAgainst: aBlock captures: aDictionary.
	block ifNil: [^ nil].
	
	aDictionary at: self contents allButFirst put: block.
	^ block
]

{ #category : #'as yet unclassified' }
SBTSQueryCapture >> isOptional [

	^ self element isOptional
]

{ #category : #'as yet unclassified' }
SBTSQueryCapture >> predicatesOn: stream [

	self element predicatesOn: stream
]

{ #category : #'as yet unclassified' }
SBTSQueryCapture >> requiresField [

	^ self element requiresField
]

{ #category : #'as yet unclassified' }
SBTSQueryCapture >> wrapsPrevious [

	^ true
]
