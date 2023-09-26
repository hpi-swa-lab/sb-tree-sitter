Extension { #name : #FSReference }

{ #category : #'*DomainCode-Core' }
FSReference >> domainReferencesDo: aClosure [

	self isDirectory ifTrue: [self children do: aClosure]
]
