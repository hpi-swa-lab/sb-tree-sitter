Class {
	#name : #DCEmptyStatement,
	#superclass : #DCUnknown,
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCEmptyStatement >> adaptInput: input in: source at: cursorIndex textMorph: textMorph event: anEvent [

	^ (super adaptInput: input in: source at: cursorIndex textMorph: textMorph event: anEvent), self language statementTerminator
]
