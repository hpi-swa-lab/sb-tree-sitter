Extension { #name : #SBTSBlock }

{ #category : #'*Sandblocks-Regex-actions' }
SBTSBlock >> wrapWithComment [
	<action>

	self language = #regex ifTrue: [SBReComment newAround: self]
]

{ #category : #'*Sandblocks-Regex-actions' }
SBTSBlock >> wrapWithEvaluator [
	<action>

	self language = #regex ifTrue: [SBReEvaluator newAround: self]
]
