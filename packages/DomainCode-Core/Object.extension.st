Extension { #name : #Object }

{ #category : #'*DomainCode-Core' }
Object >> addProp: anObject [

	DCQuery addProperty: anObject to: self
]

{ #category : #'*DomainCode-Core' }
Object >> domainParent [

	^ self subclassResponsibility
]

{ #category : #'*DomainCode-Core' }
Object >> domainReferencesDo: aClosure [

	
]

{ #category : #'*DomainCode-Core' }
Object >> domainRoot [

	^ self domainParent ifNil: [self] ifNotNil: [:p | p domainRoot]
]

{ #category : #'*DomainCode-Core' }
Object >> hasProp: anObject [

	^ DCQuery does: self haveProperty: anObject
]

{ #category : #'*DomainCode-Core' }
Object >> query: aClosure do: anotherClosure [

	^ DCQuery match: aClosure with: self do: anotherClosure
]

{ #category : #'*DomainCode-Core' }
Object >> queryFirst: aClosure ifFound: anotherClosure ifNone: aThirdClosure [

	DCQuery match: aClosure with: self do: [:match | ^ anotherClosure value: match].
	^ aThirdClosure value
]
