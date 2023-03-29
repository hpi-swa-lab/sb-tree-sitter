Extension { #name : #JsonObject }

{ #category : #'*Sandblocks-Json-converting' }
JsonObject >> asJsonSource: converter [
	<convert>

	converter do: [SBJson collapseAll: (SBJson parse: self asJsonString)]
]
