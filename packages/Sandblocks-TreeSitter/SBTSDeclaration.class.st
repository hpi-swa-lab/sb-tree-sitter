Class {
	#name : #SBTSDeclaration,
	#superclass : #SBSuggestionItem,
	#instVars : [
		'block'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSDeclaration class >> block: aBlock label: aString [

	^ self new
		selector: aBlock contents label: aString;
		block: aBlock;
		yourself
]

{ #category : #'as yet unclassified' }
SBTSDeclaration class >> block: aBlock selector: aString label: anotherString [

	^ self new
		selector: aString label: anotherString;
		block: aBlock;
		yourself
]

{ #category : #'as yet unclassified' }
SBTSDeclaration >> block [

	^ block
]

{ #category : #'as yet unclassified' }
SBTSDeclaration >> block: aBlock [

	block := aBlock
]
