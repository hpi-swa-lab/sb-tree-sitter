Class {
	#name : #DCJumpPlaceholder,
	#superclass : #DCReplacement,
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCJumpPlaceholder >> adaptInput: input in: source at: cursorIndex textMorph: textMorph event: anEvent [

	(super adaptInput: input in: source at: cursorIndex textMorph: textMorph event: anEvent) ifNotEmpty: [:newInput |
		self
			replace: self range
			in: source
			with: newInput
			do: [:new :edit | self applyEdit: edit source: new cursorAt: cursorIndex + 1]].
	^ ''
]

{ #category : #'as yet unclassified' }
DCJumpPlaceholder >> initialize [

	super initialize.
	
	self addMorphBack: DCText new
]

{ #category : #'as yet unclassified' }
DCJumpPlaceholder >> isJumpPoint [

	^ true
]

{ #category : #'as yet unclassified' }
DCJumpPlaceholder >> pasteReplace [
	<action>

	self tryApplyChange: [:source :textMorph :cursorIndex | | str |
		str := Clipboard clipboardText string.
		
		self
			replace: self range
			in: source
			with: str
			do: [:new :edit | self applyEdit: edit source: new cursorAt: cursorIndex + str size]]
]

{ #category : #'as yet unclassified' }
DCJumpPlaceholder >> type [

	^ #identifier
]

{ #category : #'as yet unclassified' }
DCJumpPlaceholder >> valid [

	^ false
]
