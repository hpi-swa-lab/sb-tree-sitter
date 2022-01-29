Class {
	#name : #SBJsRequestToolExample,
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
SBJsRequestToolExample >> code [
 ^code.
]

{ #category : #'as yet unclassified' }
SBJsRequestToolExample >> headers [
 	^headerMap.
]

{ #category : #'as yet unclassified' }
SBJsRequestToolExample >> headersToString [
	| out |
	out := String new.
	headerMap keysDo: [: key | out := out, key, ' : ', (headerMap at: key), ' '].
	^out.
]

{ #category : #'as yet unclassified' }
SBJsRequestToolExample >> initialize [
	super initialize.
]

{ #category : #'as yet unclassified' }
SBJsRequestToolExample >> params [
	^params.
]

{ #category : #'as yet unclassified' }
SBJsRequestToolExample >> paramsToString [
	| out |
	out := String new.
	params keysDo: [:key |out := out,( (params at: key) key), ' : ', ((params at: key) value), ' '].
	^out.
]

{ #category : #'as yet unclassified' }
SBJsRequestToolExample >> promptChangeValue [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBJsRequestToolExample >> url [
 ^url.
]
