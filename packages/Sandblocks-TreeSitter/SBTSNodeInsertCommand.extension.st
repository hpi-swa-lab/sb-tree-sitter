Extension { #name : #SBTSNodeInsertCommand }

{ #category : #'*Sandblocks-TreeSitter-VR' }
SBTSNodeInsertCommand >> vrDo [

	morphs reverseDo: [:morph |
		SBVREditor current godotProvider insertNewBlock: morph exportStructure asJsonString
			at: index
			inBlockWithId: container vrId]
]
