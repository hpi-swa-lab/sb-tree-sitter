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
	^ self addSeparator: text
]

{ #category : #'as yet unclassified' }
DCEmptyStatement >> addSeparator: aString [

	^ self insertSeparatorAfter
		ifTrue: [aString, self language statementTerminator]
		ifFalse: [self language statementTerminator, aString]
]

{ #category : #'as yet unclassified' }
DCEmptyStatement >> after [

	^ after ifNil: [false]
]

{ #category : #'as yet unclassified' }
DCEmptyStatement >> insert: aString [

	super insert: (self addSeparator: aString)
]

{ #category : #'as yet unclassified' }
DCEmptyStatement >> insertSeparatorAfter [

	^ self language isStatementTerminatorBetween not or: [after ifNil: [true]]
]

{ #category : #'as yet unclassified' }
DCEmptyStatement >> insertSeparatorAfter: aBoolean [

	after := aBoolean
]

{ #category : #'as yet unclassified' }
DCEmptyStatement >> pasteReplace [
	<action>

	self tryApplyChange: [:source :textMorph :cursorIndex | | str |
		str := Clipboard clipboardText string.
		str := self insertSeparatorAfter
			ifTrue: [str, self language statementTerminator]
			ifFalse: [self language statementTerminator, str].
		
		self
			insert: str
			in: source
			at: cursorIndex + 1
			do: [:new :edit | self applyEdit: edit source: new cursorAt: cursorIndex + str size]]
]

{ #category : #'as yet unclassified' }
DCEmptyStatement >> type [

	^ #empty
]
