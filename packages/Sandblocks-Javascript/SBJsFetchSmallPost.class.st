Class {
	#name : #SBJsFetchSmallPost,
	#superclass : #SBJsFetchSmall,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsFetchSmallPost >> promptAddPayload [	
	| fetch index |
	fetch := (self owner owner owner).
	index := UIManager default chooseFrom: (self values).
	index > 0
		ifTrue: [
			index caseOf: {
				[ 1 ] -> [ self addHeaderAction ].
				[ 2 ] -> [ self addParamAction ].
				[ 3 ] -> [ self addBodySection: '...' ]
			}].
]

{ #category : #'as yet unclassified' }
SBJsFetchSmallPost >> url: aString headers: aHeaders data: aData [
	"Constructs a lean designed SBJsFetch object"
	super url: aString method: #post headers: aHeaders data: aData
]

{ #category : #'as yet unclassified' }
SBJsFetchSmallPost >> values [
	^ #(Header Param Body)
]
