"
Replaces POST request from the Python requests package.
"
Class {
	#name : #SBPyEmbeddedRequestsPost,
	#superclass : #SBPyEmbeddedRequests,
	#category : #'Sandblocks-Python'
}

{ #category : #'initialize-release' }
SBPyEmbeddedRequestsPost >> bodyToJsonString [
	self body ifNil: [^String empty].
	^', json=', self body
]

{ #category : #'initialize-release' }
SBPyEmbeddedRequestsPost >> url: aString headers: aHeaders data: aData [
	"Constructs a lean designed SBJsFetch object"
	self url: aString method: #post headers: aHeaders data: aData
]

{ #category : #'initialize-release' }
SBPyEmbeddedRequestsPost >> writeSourceOn: aStream [
	"Transform into Python source code"
	aStream nextPutAll: 'requests.post("';
		nextPutAll: url asString, self collectParamsString , '"';
		nextPutAll: self bodyToJsonString;
		nextPutAll: self headersToWritableString;
		nextPutAll:  ')'.

]
