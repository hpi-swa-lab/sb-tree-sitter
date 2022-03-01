"
Replaces GET request from the Python requests package.
"
Class {
	#name : #SBPyEmbeddedRequestsGet,
	#superclass : #SBPyEmbeddedRequests,
	#category : #'Sandblocks-Python'
}

{ #category : #'initialize-release' }
SBPyEmbeddedRequestsGet >> url: aString headers: aHeaders data: aData [
	"Constructs a lean designed SBJsFetch object"
	self url: aString method: #get headers: aHeaders data: aData
]

{ #category : #'initialize-release' }
SBPyEmbeddedRequestsGet >> writeSourceOn: aStream [
	"Transform into Python source code"
	aStream nextPutAll: 'requests.get("';
		nextPutAll: url asString, self collectParamsString , '"';
		nextPutAll: self headersToWritableString;
		nextPutAll:  ')'.

]
