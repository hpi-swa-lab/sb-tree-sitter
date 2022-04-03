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
Morph >> isTSBlock [

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
