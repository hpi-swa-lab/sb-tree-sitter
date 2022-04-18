"
Number input block with extensions for specifying range and number type
"
Class {
	#name : #SBPyNumberWithPrefix,
	#superclass : #SBStNumberWithPrefix,
	#instVars : [
		'rangeMin',
		'rangeMax',
		'floatSteps'
	],
	#category : #'Sandblocks-Matplotlib'
}

{ #category : #flagging }
SBPyNumberWithPrefix >> contents: aString [
"called whenever the content of this object has changed."

	| aValidNumber |
	rangeMin ifNil: [
		aString ifNil: [super contents: '0'] ifNotNil: [super contents: aString asInteger asString].
		^ self.
	].
	
	"aValidNumber is enforced to be in the range"
	aValidNumber := (aString asNumber min: rangeMax) max: rangeMin.

	aString
		ifNil: [super contents: '0']
		ifNotNil: [super contents: (floatSteps 
			ifTrue: [aValidNumber asString from: 1 to: (aValidNumber asString size min: 4)] 
			ifFalse: [aValidNumber asInteger asString])].
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

{ #category : #flagging }
SBPyNumberWithPrefix >> writeSourceOn: aStream [
	aStream nextPutAll: (self prefix, self contents).
]
