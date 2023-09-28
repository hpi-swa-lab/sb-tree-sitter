Extension { #name : #Matrix }

{ #category : #'*DomainCode-Diff' }
Matrix >> at0: row at0: column [

	^ self at: row + 1 at: column + 1
]

{ #category : #'*DomainCode-Diff' }
Matrix >> at0: row at0: column put: anObject [

	^ self at: row + 1 at: column + 1 put: anObject
]
