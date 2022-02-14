"
Replaces get routes in express.js applications.
"
Class {
	#name : #SBJsEmbeddedExpressGet,
	#superclass : #SBJsEmbeddedExpress,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsEmbeddedExpressGet >> url: aString headers: aHeaders data: aData [
	"Constructs a lean designed SBJsFetch object"
	super url: aString method: #get headers: aHeaders data: aData
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedExpressGet >> writeSourceOn: aStream [ 
	"Transforms into JS source code"
	
	aStream nextPutAll: 'app.get("'.
	aStream nextPutAll: url asString, '"', ','.
	aStream nextPutAll: self sourceMorph sourceString.
	aStream nextPutAll:  ')'.
]
