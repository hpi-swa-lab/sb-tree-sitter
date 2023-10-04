Class {
	#name : #DCEmptyStatement,
	#superclass : #DCUnknown,
	#instVars : [
		'after'
	],
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCEmptyStatement >> adaptInput: input in: source at: cursorIndex textMorph: textMorph event: anEvent [

	| text |
	text := super adaptInput: input in: source at: cursorIndex textMorph: textMorph event: anEvent.
	^ (self language isStatementTerminatorBetween and: [self after])
		ifTrue: [self language statementTerminator, text]
		ifFalse: [text, self language statementTerminator]
]

{ #category : #'as yet unclassified' }
DCEmptyStatement >> after [

	^ after ifNil: [false]
]

{ #category : #'as yet unclassified' }
DCEmptyStatement >> after: aBoolean [

	after := aBoolean
]
