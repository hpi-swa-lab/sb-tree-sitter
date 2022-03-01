"
Replaces GET routes in ExpressJS applications.
"
Class {
	#name : #SBJsEmbeddedExpressGet,
	#superclass : #SBJsEmbeddedExpress,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'initialize-release' }
SBJsEmbeddedExpressGet >> url: aString headers: aHeaders data: aData [
	"Constructs a lean designed SBJsFetch object"
	self url: aString method: #get headers: aHeaders data: aData
]

{ #category : #'initialize-release' }
SBJsEmbeddedExpressGet >> writeSourceOn: aStream [ 
	"Transforms into JS source code"
	
	aStream nextPutAll: 'app.get("'.
	aStream nextPutAll: url asString, '"', ','.
	aStream nextPutAll: self sourceMorph sourceString.
	aStream nextPutAll:  ')'.
]
