"
SBButton which stores information for a POST request so that it can be recreated out of the button.
"
Class {
	#name : #SBRequestToolPostExample,
	#superclass : #SBRequestToolExample,
	#instVars : [
		'body'
	],
	#classInstVars : [
		'body'
	],
	#category : #'Sandblocks-Javascript'
}

{ #category : #accessing }
SBRequestToolPostExample >> body [
	^body
]

{ #category : #'initialize-release' }
SBRequestToolPostExample >> code: aCode url: aUrl headers: aHeaders body: aBody params: aParams [
	| msg |
	method := #post.
	code := aCode.
	url := aUrl.
	headerMap := aHeaders. 
	params := aParams.
	body := aBody.
	
	msg := ('Code: {1}\URL: {2}\Method: {3}\Headers: {4}\Params: {5}\Body: {6}' format: {code. url. method asString asUppercase. self headersToString. self paramsToString. self body asString}) withCRs.
	
	self balloonText: msg
]

{ #category : #'initialize-release' }
SBRequestToolPostExample >> initialize [
	super initialize.
]

{ #category : #'initialize-release' }
SBRequestToolPostExample >> promptChangeValue [
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
