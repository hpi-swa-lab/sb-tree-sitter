Extension { #name : #CompiledMethod }

{ #category : #'*DomainCode-Core' }
CompiledMethod >> openDC: convert [
	<convert>
	<convertPriority: 11>

	convert do: [DCSmalltalkMethod for: self]
]
