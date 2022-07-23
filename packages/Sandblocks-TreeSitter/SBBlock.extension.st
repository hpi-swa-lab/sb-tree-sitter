Extension { #name : #SBBlock }

{ #category : #'*Sandblocks-TreeSitter-VR' }
SBBlock >> vrId [

	^ self valueOfProperty: #vrId ifAbsentPut: [| id |
		id := SBVREditor current getNextId.
		SBVREditor current registerMorph: self atVrId: id.
		id]
]
