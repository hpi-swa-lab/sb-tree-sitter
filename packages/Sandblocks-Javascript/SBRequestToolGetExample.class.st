"
SBButton which stores information for a GET request so that it can be recreated out of the button.
"
Class {
	#name : #SBRequestToolGetExample,
	#superclass : #SBRequestToolExample,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'initialize-release' }
SBRequestToolGetExample >> code: aCode url: aUrl headers: aHeaders params: aParams [

	| msg |
	method := #get.
	code := aCode.
	url := aUrl.
	headerMap := aHeaders.
	params := (aParams).
	
	msg := ('Code: {1}\URL: {2}...' format: {code. url}) withCRs.
	
	self balloonText: msg
]

{ #category : #'initialize-release' }
SBRequestToolGetExample >> initialize [
	super initialize.
	method := #get.
]

{ #category : #'initialize-release' }
SBRequestToolGetExample >> promptChangeValue [
	| examples fetch index |
	fetch := (self owner owner owner).
	examples :=  ((fetch examples at: (url, method)) at: code).
	index := UIManager default chooseFrom: examples.
	index > 0
		ifTrue: [ | example |
			example := examples at: index.
			fetch recreateFromVariables: example headers params: example params body: nil]
		ifFalse: [fetch recreateFromMorphs]
]
