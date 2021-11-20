Class {
	#name : #SBTSQueryElement,
	#superclass : #SBTSQueryNode,
	#instVars : [
		'contents'
	],
	#category : #'Sandblocks-TreeSitter-Query'
}

{ #category : #'as yet unclassified' }
SBTSQueryElement >> contents [

	^ contents
]

{ #category : #'as yet unclassified' }
SBTSQueryElement >> contents: aString [

	contents := aString
]

{ #category : #'as yet unclassified' }
SBTSQueryElement >> evaluateAgainst: aBlock captures: aDictionary [
	" shouldn't arrive here "

	self assert: false
]

{ #category : #'as yet unclassified' }
SBTSQueryElement >> predicatesOn: stream [

	
]
