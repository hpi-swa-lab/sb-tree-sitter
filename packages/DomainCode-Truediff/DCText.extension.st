Extension { #name : #DCText }

{ #category : #'*DomainCode-TrueDiff' }
DCText >> assigned [

	^ self valueOfProperty: #assigned
]

{ #category : #'*DomainCode-TrueDiff' }
DCText >> assigned: aBlock [

	self setProperty: #assigned toValue: aBlock
]

{ #category : #'*DomainCode-TrueDiff' }
DCText >> isLiterallyEqual: aNode [

	^ self literalHash = aNode literalHash
]

{ #category : #'*DomainCode-TrueDiff' }
DCText >> literalHash [

	^ self contents hash
]

{ #category : #'*DomainCode-TrueDiff' }
DCText >> literalMatch [

	^ self valueOfProperty: #literalMatch ifAbsent: [false]
]

{ #category : #'*DomainCode-TrueDiff' }
DCText >> literalMatch: aBoolean [

	self setProperty: #literalMatch toValue: aBoolean
]

{ #category : #'*DomainCode-TrueDiff' }
DCText >> share [

	^ self valueOfProperty: #share
]

{ #category : #'*DomainCode-TrueDiff' }
DCText >> share: aShare [

	self assert: (aShare class = DCSubtreeShare or: [aShare isNil]).
	self setProperty: #share toValue: aShare
]

{ #category : #'*DomainCode-TrueDiff' }
DCText >> structureHash [

	" arbitrary non-null number to identity the existence of this node "
	^ 7
]

{ #category : #'*DomainCode-TrueDiff' }
DCText >> unassignTree [

	self assigned assigned: nil.
	self assigned: nil
]

{ #category : #'*DomainCode-TrueDiff' }
DCText >> uri [

	^ self
]
