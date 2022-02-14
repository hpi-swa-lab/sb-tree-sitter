Extension { #name : #Morph }

{ #category : #'*Sandblocks-TreeSitter' }
Morph >> containingInlineBlock [

	^ self owner ifNotNil: [:o | o containingInlineBlock]
]

{ #category : #'*Sandblocks-TreeSitter' }
Morph >> isTSNode [

	^ false
]
