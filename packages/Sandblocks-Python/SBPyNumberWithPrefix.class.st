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
"	self halt."
"	aValidNumber := aString asInteger min: rangeMax; max: rangeMin."

	aString
		ifNil: [super contents: '0']
		ifNotNil: [super contents: aString asInteger asString].
]

{ #category : #flagging }
SBPyNumberWithPrefix >> isSmalltalk [
	
	^ false
]

{ #category : #flagging }
SBPyNumberWithPrefix >> language [

	^ #python
]

{ #category : #'as yet unclassified' }
SBPyNumberWithPrefix >> rangeFrom: aNumber1 to: aNumber2 [

	aNumber1 assert: [:num | num isNil not].
	aNumber2 assert: [:num | num isNil not].	
	aNumber1 assert: [:num | num <= aNumber2].

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
