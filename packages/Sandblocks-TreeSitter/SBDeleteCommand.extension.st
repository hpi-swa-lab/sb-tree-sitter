Extension { #name : #SBDeleteCommand }

{ #category : #'*Sandblocks-TreeSitter-VR' }
SBDeleteCommand >> vrDo [

	SBVREditor current godotProvider removeBlockWithId: target vrId.
]

{ #category : #'*Sandblocks-TreeSitter-VR' }
SBDeleteCommand >> vrUndo [

	| vrNode |
	vrNode := target sandblockEditor treeRegistry treeFor: oldOwner.
	vrNode getParent addChild: vrNode afterIndex: oldIndex.
	vrNode relayout
]
