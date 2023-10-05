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
	^ self insertSeparatorBefore
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

{ #category : #'as yet unclassified' }
DCEmptyStatement >> insertSeparatorBefore [

	^ self language isStatementTerminatorBetween and: [self after]
]

{ #category : #'as yet unclassified' }
DCEmptyStatement >> pasteReplace [
	<action>

	self tryApplyChange: [:source :textMorph :cursorIndex :apply | | str |
		str := Clipboard clipboardText string.
		str := self insertSeparatorBefore
			ifTrue: [str, self language statementTerminator]
			ifFalse: [self language statementTerminator, str].
		
		self
			insert: str
			in: source
			at: cursorIndex + 1
			do: [:new :edit | apply value: new value: edit value: cursorIndex + str size]]
]

{ #category : #'as yet unclassified' }
DCEmptyStatement >> type [

	^ #empty
]
