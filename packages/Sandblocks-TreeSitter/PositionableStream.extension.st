Extension { #name : #PositionableStream }

{ #category : #'*Sandblocks-TreeSitter' }
PositionableStream >> peekDuring: aBlock [

	| old res |
	old := self position.
	res := aBlock value.
	self position: old.
	^ res
]
