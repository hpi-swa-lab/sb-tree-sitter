"
A hard copy of SbStNumberWithPrefix to change the context to Python.
"
Class {
	#name : #SBPyNumberWithPrefix,
	#superclass : #SBStNumberWithPrefix,
	#instVars : [
		'isPyPltPlotParam',
		'rangeMin',
		'rangeMax'
	],
	#category : #'Sandblocks-Python'
}

{ #category : #flagging }
SBPyNumberWithPrefix >> contents: aString [
"This is called whenever the content of this object has changed."

	| aValidNumber |
	
	rangeMin ifNil: [
		aString ifNil: [super contents: '0'] ifNotNil: [super contents: aString asInteger asString].
		^ self.
	].
	
	"aValidNumber is enforced to be in the range"
	aValidNumber := (aString asNumber min: rangeMax) max: rangeMin.

	aString
		ifNil: [super contents: '0']
		ifNotNil: [super contents: aValidNumber asInteger asString].
]

{ #category : #flagging }
SBPyNumberWithPrefix >> isSmalltalk [
	
	^ false
]

{ #category : #flagging }
SBPyNumberWithPrefix >> language [

	^ #python
]

{ #category : #accessing }
SBPyNumberWithPrefix >> prefix [
	^ prefix
]

{ #category : #'initialize-release' }
SBPyNumberWithPrefix >> rangeFrom: aNumber1 to: aNumber2 [

	self assert: [aNumber1 notNil and: aNumber2 notNil].
	self assert: [aNumber1 <= aNumber2].

	rangeMin := aNumber1.
	rangeMax := aNumber2.
]

{ #category : #accessing }
SBPyNumberWithPrefix >> rangeMax [

	^ rangeMax
]

{ #category : #accessing }
SBPyNumberWithPrefix >> rangeMin [

	^ rangeMin
]

{ #category : #flagging }
SBPyNumberWithPrefix >> stopEditing: aCommand [
"this is called after the number has changed"
	super stopEditing: aCommand.
	self triggerEvent: #edited
]

{ #category : #flagging }
SBPyNumberWithPrefix >> writeSourceOn: aStream [
	aStream nextPutAll: (self prefix, self contents).
]
