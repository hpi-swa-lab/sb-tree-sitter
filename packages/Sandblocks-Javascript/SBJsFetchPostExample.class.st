Class {
	#name : #SBJsFetchPostExample,
	#superclass : #SBJsFetchExample,
	#instVars : [
		'body'
	],
	#classInstVars : [
		'body',
		'code',
		'headersMap',
		'url'
	],
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsFetchPostExample >> code: aCode url: aUrl headers: aHeaders body: aBody [
	method := #post.
	code := aCode.
	url := aUrl.
	"Deep Copy is required here, otherwise the header will reference to the existing map which gets updated in subsequent requests."
	headerMap := aHeaders deepCopy. 
	body := aBody.
]

{ #category : #'as yet unclassified' }
SBJsFetchPostExample >> initialize [
	super initialize.
]
