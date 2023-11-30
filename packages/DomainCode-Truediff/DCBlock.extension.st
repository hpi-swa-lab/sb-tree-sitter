Extension { #name : #DCBlock }

{ #category : #'*DomainCode-TrueDiff' }
DCBlock >> assigned [

	^ self valueOfProperty: #assigned
]

{ #category : #'*DomainCode-TrueDiff' }
DCBlock >> assigned: aBlock [

	(aBlock notNil and: [self treeLabel ~= aBlock treeLabel]) ifTrue: [self halt].
	self setProperty: #assigned toValue: aBlock
]

{ #category : #'*DomainCode-TrueDiff' }
DCBlock >> isLiterallyEqual: aNode [

	^ self literalHash = aNode literalHash
]

{ #category : #'*DomainCode-TrueDiff' }
DCBlock >> literalHash [

	^ self
		valueOfProperty: #literalHash
		ifAbsentPut: [self baseChildren inject: 0 into: [:compound :node | compound + node literalHash]]
]

{ #category : #'*DomainCode-TrueDiff' }
DCBlock >> literalMatch [

	^ self valueOfProperty: #literalMatch
]

{ #category : #'*DomainCode-TrueDiff' }
DCBlock >> literalMatch: aBoolean [

	self setProperty: #literalMatch toValue: aBoolean
]

{ #category : #'*DomainCode-TrueDiff' }
DCBlock >> share [

	^ self valueOfProperty: #share
]

{ #category : #'*DomainCode-TrueDiff' }
DCBlock >> share: aShare [

	self assert: (aShare class = DCSubtreeShare or: [aShare isNil]).
	self setProperty: #share toValue: aShare
]

{ #category : #'*DomainCode-TrueDiff' }
DCBlock >> structureHash [

	^ self valueOfProperty: #structureHash ifAbsentPut: [ | writer |
		writer := #[] writeStream.
		writer nextPutAll: self type.
		self baseChildren do: [:c | writer nextLittleEndianNumber: 4 put: c structureHash].
		SecureHashAlgorithm new hashStream: writer contents readStream]
]

{ #category : #'*DomainCode-TrueDiff' }
DCBlock >> unassignTree [

	self assigned assigned: nil.
	self assigned: nil
]

{ #category : #'*DomainCode-TrueDiff' }
DCBlock >> uri [

	^ self
]
