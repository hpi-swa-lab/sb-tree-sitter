Class {
	#name : #SBJsRequestToolPostExample,
	#superclass : #SBJsRequestToolExample,
	#instVars : [
		'body'
	],
	#classInstVars : [
		'body'
	],
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsRequestToolPostExample >> body [
	^body
]

{ #category : #'as yet unclassified' }
SBJsRequestToolPostExample >> code: aCode url: aUrl headers: aHeaders body: aBody params: aParams [
	| msg |
	method := #post.
	code := aCode.
	url := aUrl.
	headerMap := aHeaders. 
	params := aParams.
	body := aBody.
	
	msg := ('Code: ', code, '\URL: ', url, '\Method: ', method asString asUppercase, '\Headers: ', self headersToString, '\Params: ', self paramsToString, '\Body ', self body asString) withCRs.
	
	self balloonText: msg
]

{ #category : #'as yet unclassified' }
SBJsRequestToolPostExample >> initialize [
	super initialize.
]

{ #category : #'as yet unclassified' }
SBJsRequestToolPostExample >> promptChangeValue [
	| examples fetch index |
	fetch := (self owner owner owner).
	examples :=  ((fetch examples at: (url, method)) at: code).
	index := UIManager default chooseFrom: examples.
	index > 0
		ifTrue: [ | example |
			example := examples at: index.
			fetch recreateFromVariables: example headers params: example params body: example body]
		ifFalse: [fetch recreateFromMorphs]
]
