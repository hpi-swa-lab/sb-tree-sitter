Class {
	#name : #SBJsEmbeddedFetchPost,
	#superclass : #SBJsEmbeddedFetch,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsEmbeddedFetchPost >> url: aString headers: aHeaders data: aData [
	"Constructs a lean designed SBJsFetch object"
	super url: aString method: #post headers: aHeaders data: aData
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedFetchPost >> writeSourceOn: aStream [ 
	"Transforms into JS source code"
	aStream nextPutAll: 'fetch('''.
	aStream nextPutAll: url asString, self collectParamsString, '''', ','.
	aStream nextPutAll: '{'.
	aStream nextPutAll: 'method: "POST"', ','.
	headers ifNotEmpty: [
		aStream nextPutAll: 'headers: {'.
		aStream nextPutAll: self headersToWritableString..
		aStream nextPutAll: '}', ','].
	data ifNotNil: [
		aStream nextPutAll: 'body:'.
		aStream nextPutAll: data asString].
	
	aStream nextPutAll:  '});'.

]
