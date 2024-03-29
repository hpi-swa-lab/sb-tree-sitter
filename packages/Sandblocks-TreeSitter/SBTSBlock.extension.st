Extension { #name : #SBTSBlock }

{ #category : #'*Sandblocks-TreeSitter-LanguageClient' }
SBTSBlock >> chooseFrom: aCollection [

	^ aCollection size
		caseOf: {
			[0] -> [0].
			[1] -> [1]}
		otherwise: [UIManager default chooseFrom: aCollection]
]

{ #category : #'*Sandblocks-TreeSitter-LanguageClient' }
SBTSBlock >> codeAction [
	<action>

	self semantics
		codeActionsFor: self
		choosing: [:codeActions | self chooseFrom: codeActions]
		blocking: true
]

{ #category : #'*Sandblocks-TreeSitter-LanguageClient' }
SBTSBlock >> gotoDefinition [
	<action>

	self semantics
		definitionsOf: self
		choosing: [:definitions | self chooseFrom: definitions]
		do: [:definition | definition select]
		blocking: true
]
