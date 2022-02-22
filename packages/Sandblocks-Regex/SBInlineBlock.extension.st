Extension { #name : #SBInlineBlock }

{ #category : #'*Sandblocks-Regex' }
SBInlineBlock >> wrapWithComment [
	<action>

	self language = #regex ifTrue: [
		^ self sandblockEditor do: (SBReplaceCommand new
			target: self
			replacer: (SBReComment new
				pattern: self buildCopy))]
]

{ #category : #'*Sandblocks-Regex' }
SBInlineBlock >> wrapWithExecutor [
	<action>

	self language = #regex ifTrue: [
		^ self sandblockEditor do: (SBReplaceCommand new
			target: self
			replacer: (SBReEvaluator new
				pattern: self buildCopy))]
]
