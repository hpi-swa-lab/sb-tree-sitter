Extension { #name : #SBTSBlock }

{ #category : #'*Sandblocks-TreeSitter-Project' }
SBTSBlock >> gotoDefinition [
	<action>

	self semantics
		definitionsOf: self
		choosing: [:definitions |
			definitions size
				caseOf: {
					[0] -> [0].
					[1] -> [1]}
				otherwise: [UIManager default chooseFrom: definitions]]
		do: [:definition | definition select]
		blocking: true
]
