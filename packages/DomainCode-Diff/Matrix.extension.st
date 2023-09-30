Extension { #name : #Matrix }

{ #category : #'*DomainCode-Diff' }
Matrix >> at0: row at0: column [

	^ contents at: row * ncols + (column + 1)
]

{ #category : #'*DomainCode-Diff' }
Matrix >> at0: row at0: column put: anObject [

	^ contents at: row * ncols + (column + 1) put: anObject
]

{ #category : #'*DomainCode-Diff' }
Matrix >> atFast: row at: column [

	^ contents at: row - 1 * ncols + column
]

{ #category : #'*DomainCode-Diff' }
Matrix >> atFast: row at: column put: anObject [

	^ contents at: row - 1 * ncols + column put: anObject
]
