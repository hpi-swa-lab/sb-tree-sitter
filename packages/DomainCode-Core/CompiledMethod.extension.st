Extension { #name : #CompiledMethod }

{ #category : #'*DomainCode-Core' }
CompiledMethod >> openDC: convert [
	<convert>
	<convertPriority: 13>

	convert do: [DCSmalltalkMethod for: self]
]
