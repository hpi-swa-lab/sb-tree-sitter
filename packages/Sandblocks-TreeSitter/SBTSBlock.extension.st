Extension { #name : #SBTSBlock }

{ #category : #'*Sandblocks-TreeSitter-Project' }
SBTSBlock >> gotoDefinition [
	<action>

	self semantics
		definitionsOf: self
		choosing: [:definitions | UIManager default chooseFrom: definitions]
		do: [:definition | definition select]
		blocking: true
]
