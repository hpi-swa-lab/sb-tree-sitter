Class {
	#name : #SBPyEmbeddedRequestsPost,
	#superclass : #SBPyEmbeddedRequests,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyEmbeddedRequestsPost >> bodyToJsonString [
	self body ifNil: [^String empty].
	^', json=', self body
]

{ #category : #'as yet unclassified' }
SBPyEmbeddedRequestsPost >> headersToWritableString [
	|headerString|
	headerString := (headers associations collect: [:a | '"{1}":"{2}"' format: {a key. a value}]) joinSeparatedBy: ','.
	headerString ifNotEmpty: [^ ', headers={', headerString, '}'].
	^String empty.
]

{ #category : #'as yet unclassified' }
SBPyEmbeddedRequestsPost >> url: aString headers: aHeaders data: aData [
	"Constructs a lean designed SBJsFetch object"
	self url: aString method: #post headers: aHeaders data: aData
]

{ #category : #'as yet unclassified' }
SBPyEmbeddedRequestsPost >> writeSourceOn: aStream [
	"Transform into Python source code"
	aStream nextPutAll: 'requests.post("';
		nextPutAll: url asString, self collectParamsString , '"';
		nextPutAll: self bodyToJsonString;
		nextPutAll: self headersToWritableString;
		nextPutAll:  ')'.

]
