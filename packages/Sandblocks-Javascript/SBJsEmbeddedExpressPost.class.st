"
Replaces post routes in express.js applications.
"
Class {
	#name : #SBJsEmbeddedExpressPost,
	#superclass : #SBJsEmbeddedExpress,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsEmbeddedExpressPost >> addExampleSection [
	
	showExamples ifTrue: [
		 | map tmpUrl |
		
			self addMorphBack: (SBRow new
				cellGap: cellGapConstant;
				addMorphBack: (SBStringMorph new contents: 'Examples');
				addMorphBack: (SBRow new cellGap: cellGapConstant)).
				
			exampleMorph := self submorphs sixth.
			"TODO, improve tmpUrl workaround"
			tmpUrl := 'http://localhost:8080', url.
			
			map := Examples at: tmpUrl, method asString ifAbsent: [].
			map ifNotNil: [ map keysDo: [:key | exampleMorph submorphs second addMorphBack: (map at: key) first]]]
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedExpressPost >> promptAddPayload [	
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
SBJsEmbeddedExpressPost >> url: aString headers: aHeaders data: aData [
	"Constructs a lean designed SBJsFetch object"
	aData ifNil: [super url: aString method: #post headers: aHeaders data: '{}'].
	aData ifNotNil: [super url: aString method: #post headers: aHeaders data: aData].
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedExpressPost >> values [
	^ #(Header Param Body)
]
