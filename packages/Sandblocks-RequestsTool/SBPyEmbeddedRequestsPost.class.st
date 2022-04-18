Class {
	#name : #SBPyEmbeddedRequestsPost,
	#superclass : #SBPyEmbeddedRequests,
	#category : #'Sandblocks-RequestsTool'
}

{ #category : #'as yet unclassified' }
SBPyEmbeddedRequestsPost >> url: aString headers: aHeaders data: aData [
	"Constructs a lean designed SBJsFetch object"
	super url: aString method: #post headers: aHeaders data: aData
]

{ #category : #'as yet unclassified' }
SBPyEmbeddedRequestsPost >> writeSourceOn: aStream [
	"TODO"
]
