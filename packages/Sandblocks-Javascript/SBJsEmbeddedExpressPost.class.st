"
Replaces POST routes in ExpressJS applications.
"
Class {
	#name : #SBJsEmbeddedExpressPost,
	#superclass : #SBJsEmbeddedExpress,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'initialize-release' }
SBJsEmbeddedExpressPost >> url: aString headers: aHeaders data: aData [
	"Constructs a lean designed SBJsFetch object"
	aData ifNil: [self url: aString method: #post headers: aHeaders data: '{}'].
	aData ifNotNil: [self url: aString method: #post headers: aHeaders data: aData].
]

{ #category : #'initialize-release' }
SBJsEmbeddedExpressPost >> writeSourceOn: aStream [ 
	"Transforms into JS source code"
	
	aStream nextPutAll: 'app.post("'.
	aStream nextPutAll: url asString, '"', ','.
	aStream nextPutAll: self sourceMorph sourceString.
	aStream nextPutAll:  ')'.
]
