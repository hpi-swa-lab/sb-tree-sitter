Extension { #name : #SBReplaceMultipleCommand }

{ #category : #'*Sandblocks-TreeSitter-VR' }
SBReplaceMultipleCommand >> vrDo [

	SBVREditor current godotProvider removeBlockWithId: target vrId.
	
	replacers reverseDo: [:morph |
		SBVREditor current godotProvider insertNewBlock: morph exportStructure asJsonString
			at: targetOldIndex
			inBlockWithId: targetOldOwner vrId]
]
