Class {
	#name : #SBJsEmbeddedFetchGet,
	#superclass : #SBJsEmbeddedFetch,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsEmbeddedFetchGet >> url: aString headers: aHeaders data: aData [
	"Constructs a lean designed SBJsFetch object"
	super url: aString method: #get headers: aHeaders data: aData
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedFetchGet >> writeSourceOn: aStream [ 
	"Transforms into JS source code"
	aStream nextPutAll: 'fetch("'.
	aStream nextPutAll: url asString, self collectParamsString , '"', ','.
	aStream nextPutAll: '{'.
	aStream nextPutAll: 'method: "GET"', ','.
	headers ifNotEmpty: [
		aStream nextPutAll: 'headers: {'.
		aStream nextPutAll: self headersToWritableString.
		aStream nextPutAll: '}', ','].
	
	aStream nextPutAll:  '})'.

]
