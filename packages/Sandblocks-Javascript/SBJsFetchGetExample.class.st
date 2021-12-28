Class {
	#name : #SBJsFetchGetExample,
	#superclass : #SBJsFetchExample,
	#instVars : [
		'params'
	],
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsFetchGetExample >> code: aCode url: aUrl headers: aHeaders params: aParams [

	| msg |
	method := #get.
	code := aCode.
	url := aUrl.
	headerMap := aHeaders.
	params := (aParams).
	
	msg := ('Code: ', code, '\URL: ', url, '\Method: ', method asString asUppercase, '\Headers: ', self headersToString, '\Params: ', self paramsToString) withCRs.
	
	self balloonText: msg
]

{ #category : #'as yet unclassified' }
SBJsFetchGetExample >> headers [
	^headerMap.
]

{ #category : #'as yet unclassified' }
SBJsFetchGetExample >> headersToString [
	| out |
	out := String new.
	headerMap keysDo: [: key | out := out, key, ' : ', (headerMap at: key), ' '].
	^out.
]

{ #category : #'as yet unclassified' }
SBJsFetchGetExample >> initialize [
	super initialize.
	method := #get.
]

{ #category : #'as yet unclassified' }
SBJsFetchGetExample >> params [
	^params.
]

{ #category : #'as yet unclassified' }
SBJsFetchGetExample >> paramsToString [
	| out |
	out := String new.
	params keysDo: [:key |out := out,( (params at: key) key), ' : ', ((params at: key) value), ' '].
	^out.
]
