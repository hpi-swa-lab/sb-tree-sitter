"
A hard copy of SbStNumberWithPrefix to change the context to Python.
"
Class {
	#name : #SBPyNumberWithPrefix,
	#superclass : #SBStNumber,
	#instVars : [
		'prefix'
	],
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyNumberWithPrefix >> castToUnknownWhenEmpty [

	^ false
]

{ #category : #'as yet unclassified' }
SBPyNumberWithPrefix >> isPyPltPlotParam [
	"indicates that this is a parameter of matplotlib's ax.plot() method."
	^ true
]

{ #category : #'as yet unclassified' }
SBPyNumberWithPrefix >> isSmalltalk [
	
	^ false
]

{ #category : #'as yet unclassified' }
SBPyNumberWithPrefix >> keyStroke: anEvent [

	self acceptInputEvent: anEvent
]

{ #category : #'as yet unclassified' }
SBPyNumberWithPrefix >> prefix: aString [

	prefix := aString
]

{ #category : #'as yet unclassified' }
SBPyNumberWithPrefix >> symbols [

	^ {prefix. nil}
]
