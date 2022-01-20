Class {
	#name : #SBJsRequestToolGetExample,
	#superclass : #SBJsRequestToolExample,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsRequestToolGetExample >> code: aCode url: aUrl headers: aHeaders params: aParams [

	| msg |
	method := #get.
	code := aCode.
	url := aUrl.
	headerMap := aHeaders.
	params := (aParams).
	
	msg := ('Code: ', code, '\URL: ', url, '\Method: ', method asString asUppercase, '\Headers: ', self headersToString, '\Params: ', self paramsToString) withCRs.
	
	self balloonText: msg
]

{ #category : #'as yet unclassified' }
SBJsRequestToolGetExample >> initialize [
	super initialize.
	method := #get.
]

{ #category : #'as yet unclassified' }
SBJsRequestToolGetExample >> promptChangeValue [
	| examples fetch index |
	fetch := (self owner owner owner).
	examples :=  ((fetch Examples at: (url, method)) at: code).
	index := UIManager default chooseFrom: examples.
	index > 0
		ifTrue: [ | example |
			example := examples at: index.
			fetch recreateFromVariables: example headers params: example params body: nil]
		ifFalse: [fetch recreateFromMorphs]
]
