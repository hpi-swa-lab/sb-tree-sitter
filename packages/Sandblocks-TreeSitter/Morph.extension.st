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
