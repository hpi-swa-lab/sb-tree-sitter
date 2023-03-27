Extension { #name : #JsonObject }

{ #category : #'*Sandblocks-Json-converting' }
JsonObject >> asJsonSource: converter [
	<convert>

	converter do: [SBJson parseToplevel: self asJsonString]
]
