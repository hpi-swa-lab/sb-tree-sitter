Class {
	#name : #SBPyEmbeddedRequestsPost,
	#superclass : #SBPyEmbeddedRequests,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyEmbeddedRequestsPost >> addExampleSection [
	
	showExamples ifTrue: [
		 | map tmpUrl |
		
			self addMorphBack: (SBRow new
				cellGap: cellGapConstant;
				addMorphBack: (SBStringMorph new contents: 'Examples');
				addMorphBack: (SBRow new cellGap: cellGapConstant)).
				
			exampleMorph := self submorphs sixth.
			"TODO, improve tmpUrl workaround"
			(url startsWith: 'http://') ifTrue: [tmpUrl := url] ifFalse: [tmpUrl := 'http://localhost:8080', url].
			
			map := Examples at: tmpUrl, method asString ifAbsent: [].
			map ifNotNil: [ map keysDo: [:key | exampleMorph submorphs second addMorphBack: (map at: key) first]]]
]

{ #category : #'as yet unclassified' }
SBPyEmbeddedRequestsPost >> url: aString headers: aHeaders data: aData [
	"Constructs a lean designed SBJsFetch object"
	super url: aString method: #post headers: aHeaders data: aData
]
