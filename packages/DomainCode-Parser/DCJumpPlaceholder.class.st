Class {
	#name : #DCJumpPlaceholder,
	#superclass : #DCReplacement,
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCJumpPlaceholder >> initialize [

	super initialize.
	
	self addMorphBack: DCText new
]

{ #category : #'as yet unclassified' }
DCJumpPlaceholder >> keyStroke: anEvent [

	(anEvent keyCharacter isPrintable and: [anEvent commandKeyPressed not]) ifTrue: [
		self source infoForEditDo: [:source :textMorph :cursorIndex |
			self source replaceWith: (self source
				adaptInput: anEvent keyCharacter asString
				in: source
				at: cursorIndex
				textMorph: textMorph
				event: anEvent)]].
	self batchedChangeStep
]

{ #category : #'as yet unclassified' }
DCJumpPlaceholder >> pasteReplace [
	<action>

	self infoForEditDo: [:source :textMorph :cursorIndex | | str |
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
