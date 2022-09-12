Extension { #name : #SBTSBlock }

{ #category : #'*Sandblocks-TreeSitter-Project' }
SBTSBlock >> gotoDefinition [
	<action>

	| definitions |
	definitions := OrderedCollection streamContents: [:stream |
		self semantics
			definitionsOf: self
			do: [:definition | stream nextPut: definition]
			blocking: true].
	self sandblockEditor select: definitions first
]
