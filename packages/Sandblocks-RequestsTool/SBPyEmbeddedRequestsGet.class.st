Class {
	#name : #SBPyEmbeddedRequestsGet,
	#superclass : #SBPyEmbeddedRequests,
	#category : #'Sandblocks-RequestsTool'
}

{ #category : #'as yet unclassified' }
SBPyEmbeddedRequestsGet >> url: aString headers: aHeaders data: aData [
	"Constructs a lean designed SBJsFetch object"
	super url: aString method: #get headers: aHeaders data: aData
]

{ #category : #'as yet unclassified' }
SBPyEmbeddedRequestsGet >> writeSourceOn: aStream [
	"TODO"
]
