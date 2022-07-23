Extension { #name : #SBTextCommand }

{ #category : #'*Sandblocks-TreeSitter-VR' }
SBTextCommand >> vrDo [

	self assert: oldMorph = newMorph.
	SBVREditor current godotProvider setTextBlockContent: newText
		onTextBlockWithId: textMorph vrId.
]
