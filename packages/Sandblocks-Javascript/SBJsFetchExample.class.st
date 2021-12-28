Class {
	#name : #SBJsFetchExample,
	#superclass : #SBButton,
	#instVars : [
		'code',
		'url',
		'method',
		'headerMap',
		'index'
	],
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsFetchExample >> code [
 ^code.
]

{ #category : #'as yet unclassified' }
SBJsFetchExample >> headers [
 	^headerMap.
]

{ #category : #'as yet unclassified' }
SBJsFetchExample >> initialize [
	super initialize.
]

{ #category : #'as yet unclassified' }
SBJsFetchExample >> promptChangeValue [
	| examples fetch index |
	fetch := (self owner owner owner).
	examples :=  ((fetch Examples at: (url, method)) at: code).
	index := UIManager default chooseFrom: examples.
	index > 0
		ifTrue: [ | example |
			example := examples at: index.
			fetch recreateFromVariables: example headers params: example params]
		ifFalse: [fetch recreateFromMorphs]
]

{ #category : #'as yet unclassified' }
SBJsFetchExample >> url [
 ^url.
]
