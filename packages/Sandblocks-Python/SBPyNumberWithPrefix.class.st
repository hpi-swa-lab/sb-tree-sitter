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

	| aValidNumber |
	
	rangeMin ifNil: [
			aString
				ifNil: [super contents: '0']
				ifNotNil: [super contents: aString asInteger asString].
			^ self.
		].
	
	aValidNumber := (aString asNumber min: rangeMax) max: rangeMin.

	aString
		ifNil: [super contents: '0']
		ifNotNil: [super contents: aValidNumber asInteger asString].
]

{ #category : #flagging }
SBPyNumberWithPrefix >> initialize [

	super initialize.
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

{ #category : #'as yet unclassified' }
SBPyNumberWithPrefix >> rangeFrom: aNumber1 to: aNumber2 [

	self assert: [aNumber1 notNil and: aNumber2 notNil].
	self assert: [aNumber1 <= aNumber2].

	rangeMin := aNumber1.
	rangeMax := aNumber2.
]

{ #category : #'as yet unclassified' }
SBPyNumberWithPrefix >> rangeMax [

	^ rangeMax
]

{ #category : #'as yet unclassified' }
SBPyNumberWithPrefix >> rangeMin [

	^ rangeMin
]

{ #category : #flagging }
SBPyNumberWithPrefix >> stopEditing: aCommand [
	super stopEditing: aCommand.
	self triggerEvent: #edited
]

{ #category : #flagging }
SBPyNumberWithPrefix >> writeSourceOn: aStream [
	aStream nextPutAll: (self prefix, self contents).
]
