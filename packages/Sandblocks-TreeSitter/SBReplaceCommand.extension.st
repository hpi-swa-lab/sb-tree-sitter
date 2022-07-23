Extension { #name : #SBReplaceCommand }

{ #category : #'*Sandblocks-TreeSitter-VR' }
SBReplaceCommand >> vrDo [

	SBVREditor current godotProvider removeBlockWithId: target vrId.

	SBVREditor current godotProvider insertNewBlock: replacer exportStructure asJsonString
		at: targetOldIndex
		inBlockWithId: targetOldOwner vrId
]
