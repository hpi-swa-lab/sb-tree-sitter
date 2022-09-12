Extension { #name : #SBTSBlock }

{ #category : #'*Sandblocks-TreeSitter-Project' }
SBTSBlock >> gotoDefinition [
	<action>

	self semantics
		definitionsOf: self
		do: [:definitions | definitions ifNotEmpty: [self sandblockEditor select: definitions first]]
]
