Extension { #name : #Morph }

{ #category : #'*Sandblocks-TreeSitter' }
Morph >> allMorphsPreorderDo: aBlock [

	aBlock value: self.
	self submorphsDo: [:m | m allMorphsPreorderDo: aBlock]
]

{ #category : #'*Sandblocks-TreeSitter' }
Morph >> containingInlineBlock [

	^ self owner ifNotNil: [:o | o containingInlineBlock]
]

{ #category : #'*Sandblocks-TreeSitter' }
Morph >> firstDeepSubmorph [

	| current |
	current := self.
	[current submorphs isEmpty] whileFalse: [current := current submorphs first].
	^ current
]

{ #category : #'*Sandblocks-TreeSitter' }
Morph >> isTSBlock [

	^ false
]

{ #category : #'*Sandblocks-TreeSitter' }
Morph >> isTSMorph [

	^ false
]

{ #category : #'*Sandblocks-TreeSitter' }
Morph >> isTSNode [

	^ false
]

{ #category : #'*Sandblocks-TreeSitter' }
Morph >> recursiveSubmorphCount [

	| i |
	i := 0.
	self allMorphsDo: [:m | i := i + 1].
	^ i
]

{ #category : #'*Sandblocks-TreeSitter-VR' }
Morph >> vrId [

	^ self valueOfProperty: #vrId ifAbsentPut: [| id |
		id := SBVREditor current getNextId.
		SBVREditor current registerMorph: self atVrId: id.
		id]
]
