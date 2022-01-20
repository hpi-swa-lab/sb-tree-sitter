Class {
	#name : #SBJsEmbeddedFetchGet,
	#superclass : #SBJsEmbeddedFetch,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsEmbeddedFetchGet >> promptAddPayload [	
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
SBJsEmbeddedFetchGet >> url: aString headers: aHeaders data: aData [
	"Constructs a lean designed SBJsFetch object"
	super url: aString method: #get headers: aHeaders data: aData
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedFetchGet >> values [
	^ #(Header Param)
]
