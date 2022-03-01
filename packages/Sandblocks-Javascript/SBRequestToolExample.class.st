"
Subclass of SBButton which additionally stores information of a request. E.g., which method was used, the data which was send with the request, the response code etc.
"
Class {
	#name : #SBRequestToolExample,
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

{ #category : #accessing }
SBRequestToolExample >> code [
 ^code.
]

{ #category : #accessing }
SBRequestToolExample >> headers [
 	^headerMap.
]

{ #category : #'initialize-release' }
SBRequestToolExample >> headersToString [
	| out |
	out := String new.
	headerMap keysDo: [: key | out := out, key, ' : ', (headerMap at: key), ' '].
	^out.
]

{ #category : #'initialize-release' }
SBRequestToolExample >> initialize [
	super initialize.
]

{ #category : #accessing }
SBRequestToolExample >> params [
	^params.
]

{ #category : #'initialize-release' }
SBRequestToolExample >> paramsToString [
	| out |
	out := String new.
	params keysDo: [:key |out := out,( (params at: key) key), ' : ', ((params at: key) value), ' '].
	^out.
]

{ #category : #'initialize-release' }
SBRequestToolExample >> promptChangeValue [
	self subclassResponsibility
]

{ #category : #accessing }
SBRequestToolExample >> url [
 ^url.
]
