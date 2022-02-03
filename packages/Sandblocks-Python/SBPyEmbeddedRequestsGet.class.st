Class {
	#name : #SBPyEmbeddedRequestsGet,
	#superclass : #SBPyEmbeddedRequests,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyEmbeddedRequestsGet >> url: aString headers: aHeaders data: aData [
	"Constructs a lean designed SBJsFetch object"
	super url: aString method: #get headers: aHeaders data: aData
]
