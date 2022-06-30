Extension { #name : #SBEditorOpenMorphCommand }

{ #category : #'*Sandblocks-TreeSitter-VR' }
SBEditorOpenMorphCommand >> vrDo [

	editor godotProvider doOpenEditorMorphCommand: morph exportStructure asJsonString
]
