Class {
	#name : #SBJsEmbeddedFetchPost,
	#superclass : #SBJsEmbeddedFetch,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsEmbeddedFetchPost >> addExampleSection [
	
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
SBJsEmbeddedFetchPost >> url: aString headers: aHeaders data: aData [
	"Constructs a lean designed SBJsFetch object"
	super url: aString method: #post headers: aHeaders data: aData
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedFetchPost >> writeSourceOn: aStream [ 
	"Transforms into JS source code"
	aStream nextPutAll: 'fetch('''.
	aStream nextPutAll: url asString, self collectParamsString, '''', ','.
	aStream nextPutAll: '{'.
	aStream nextPutAll: 'method: "POST"', ','.
	headers ifNotEmpty: [
		aStream nextPutAll: 'headers: {'.
		aStream nextPutAll: self headersToWritableString..
		aStream nextPutAll: '}', ','].
	data ifNotNil: [
		aStream nextPutAll: 'body:'.
		aStream nextPutAll: data asString].
	
	aStream nextPutAll:  '});'.

]
