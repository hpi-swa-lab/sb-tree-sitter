"
Replaces post routes in express.js applications.
"
Class {
	#name : #SBJsEmbeddedExpressPost,
	#superclass : #SBJsEmbeddedExpress,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsEmbeddedExpressPost >> url: aString headers: aHeaders data: aData [
	"Constructs a lean designed SBJsFetch object"
	aData ifNil: [super url: aString method: #post headers: aHeaders data: '{}'].
	aData ifNotNil: [super url: aString method: #post headers: aHeaders data: aData].
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedExpressPost >> writeSourceOn: aStream [ 
	"Transforms into JS source code"
	
	aStream nextPutAll: 'app.post("'.
	aStream nextPutAll: url asString, '"', ','.
	aStream nextPutAll: self sourceMorph sourceString.
	aStream nextPutAll:  ')'.
]
