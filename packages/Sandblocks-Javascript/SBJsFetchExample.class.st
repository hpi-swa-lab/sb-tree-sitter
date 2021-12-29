Class {
	#name : #SBJsFetchExample,
	#superclass : #SBButton,
	#instVars : [
		'code',
		'url',
		'method',
		'headerMap',
		'index',
		'params'
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
SBJsFetchExample >> headersToString [
	| out |
	out := String new.
	headerMap keysDo: [: key | out := out, key, ' : ', (headerMap at: key), ' '].
	^out.
]

{ #category : #'as yet unclassified' }
SBJsFetchExample >> initialize [
	super initialize.
]

{ #category : #'as yet unclassified' }
SBJsFetchExample >> params [
	^params.
]

{ #category : #'as yet unclassified' }
SBJsFetchExample >> paramsToString [
	| out |
	out := String new.
	params keysDo: [:key |out := out,( (params at: key) key), ' : ', ((params at: key) value), ' '].
	^out.
]

{ #category : #'as yet unclassified' }
SBJsFetchExample >> promptChangeValue [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBJsFetchExample >> url [
 ^url.
]
