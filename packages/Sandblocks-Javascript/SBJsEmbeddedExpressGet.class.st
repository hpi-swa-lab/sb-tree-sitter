"
Replaces get routes in express.js applications.
"
Class {
	#name : #SBJsEmbeddedExpressGet,
	#superclass : #SBJsEmbeddedExpress,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsEmbeddedExpressGet >> promptAddPayload [	
	| fetch index |
	fetch := (self owner owner owner).
	index := UIManager default chooseFrom: (self values).
	index > 0
		ifTrue: [
			index caseOf: {
				[ 1 ] -> [ self addHeaderAction ].
				[ 2 ] -> [ self addParamAction ]
			}].
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedExpressGet >> url: aString headers: aHeaders data: aData [
	"Constructs a lean designed SBJsFetch object"
	super url: aString method: #get headers: aHeaders data: aData
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedExpressGet >> values [
	^ #(Header Param)
]
