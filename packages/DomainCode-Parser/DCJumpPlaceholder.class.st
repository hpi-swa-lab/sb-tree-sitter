Class {
	#name : #DCJumpPlaceholder,
	#superclass : #DCReplacement,
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCJumpPlaceholder >> initialize [

	super initialize.
	
	self addMorphBack: SBMultilineOwnTextMorph new
]

{ #category : #'as yet unclassified' }
DCJumpPlaceholder >> keyStroke: anEvent [

	(anEvent keyCharacter isPrintable and: [anEvent commandKeyPressed not]) ifTrue: [
		self source infoForEditDo: [:source :textMorph :cursorIndex | | text |
			text := self source
				adaptInput: anEvent keyCharacter asString
				in: source
				at: cursorIndex
				textMorph: textMorph
				event: anEvent.
			DCBlock
				replace: self source range
				in: source
				with: text
				do: (self source applyBlockWithCursor: self source range start index + (text indexOf: anEvent keyCharacter))]].
	self batchedChangeStep
]

{ #category : #'as yet unclassified' }
DCJumpPlaceholder >> pasteReplace [
	<action>

	self source pasteReplace
]

{ #category : #'as yet unclassified' }
DCJumpPlaceholder >> type [

	^ #identifier
]

{ #category : #'as yet unclassified' }
DCJumpPlaceholder >> valid [

	^ false
]
