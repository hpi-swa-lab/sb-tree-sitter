"
Number input block with extensions for specifying range and number type
"
Class {
	#name : #SBPyNumberWithPrefix,
	#superclass : #SBStNumberWithPrefix,
	#instVars : [
		'rangeMin',
		'rangeMax',
		'floatSteps',
		'suffix'
	],
	#category : #'Sandblocks-Matplotlib'
}

{ #category : #flagging }
SBPyNumberWithPrefix >> contents: aString [

	aString ifNil: [super contents: '0'] ifNotNil: [ | valid |
		valid := rangeMin
			ifNil: [aString asNumber]
			ifNotNil: [aString asNumber clampLow: rangeMin high: rangeMax].
		super contents: (floatSteps
			ifTrue: [valid asFloat printShowingMaxDecimalPlaces: 3]
			ifFalse: [valid asInteger asString])]
]

{ #category : #testing }
SBPyNumberWithPrefix >> floatSteps [
"by default, only integer values are supported"
	floatSteps := true.
]

{ #category : #'initialize-release' }
SBPyNumberWithPrefix >> initialize [

	super initialize.
	
	floatSteps := false.
]

{ #category : #flagging }
SBPyNumberWithPrefix >> isSmalltalk [
	
	^ false
]

{ #category : #flagging }
SBPyNumberWithPrefix >> language [

	^ #python
]

{ #category : #testing }
SBPyNumberWithPrefix >> mouseMove: anEvent [

	| delta |
	isDown ifTrue: [
		delta := floatSteps 
				ifTrue: [(anEvent position - lastMousePosition) x * 0.01] 
				ifFalse: [(anEvent position - lastMousePosition) x].
		self flag: #todo.
		"preserve formatting like base"
		self contents: (self parsedContents + delta) asString.
		lastMousePosition := anEvent position.
		self batchedChangeStep]
]

{ #category : #flagging }
SBPyNumberWithPrefix >> preferredColorIn: aColorPolicy [

	^ aColorPolicy default
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
"called after the number has changed"
	super stopEditing: aCommand.
	self triggerEvent: #edited
]

{ #category : #'as yet unclassified' }
SBPyNumberWithPrefix >> suffix: aString [

	suffix := aString
]

{ #category : #'as yet unclassified' }
SBPyNumberWithPrefix >> symbols [

	^ {prefix. suffix}
]

{ #category : #flagging }
SBPyNumberWithPrefix >> writeSourceOn: aStream [
	aStream nextPutAll: (self prefix, self contents).
]
