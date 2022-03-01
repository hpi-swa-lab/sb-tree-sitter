"
Base class for all text fields in the SBRequestTool. Subclasses implement promptChangeValue method for interaction with text fields.
"
Class {
	#name : #SBRequestToolTextBubble,
	#superclass : #SBTextBubble,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'event handling' }
SBRequestToolTextBubble >> doubleClick: evt [

	self promptChangeValue
]

{ #category : #initialization }
SBRequestToolTextBubble >> initialize [
	super initialize
]
