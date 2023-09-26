Class {
	#name : #DCMappingStore,
	#superclass : #Object,
	#instVars : [
		'srcToDest',
		'destToSrc'
	],
	#category : #'DomainCode-Diff'
}

{ #category : #'as yet unclassified' }
DCMappingStore >> addMappingFrom: src to: dest [

	self assert: src rootBlock ~= dest rootBlock.
	srcToDest at: src put: dest.
	destToSrc at: dest put: src
]

{ #category : #'as yet unclassified' }
DCMappingStore >> addRecursiveMappingFrom: src to: dest [

	self addMappingFrom: src to: dest.
	src submorphs with: dest submorphs do: [:a :b | self addRecursiveMappingFrom: a to: b]
]

{ #category : #'as yet unclassified' }
DCMappingStore >> allowedToMapFrom: srcCandidate to: destCandidate [

	^ srcCandidate type = destCandidate type and: [self areBothUnmappedSrc: srcCandidate dest: destCandidate]
]

{ #category : #'as yet unclassified' }
DCMappingStore >> areBothUnmappedSrc: src dest: dest [

	^ (self isSrcMapped: src) not and: [(self isDestMapped: dest) not]
]

{ #category : #'as yet unclassified' }
DCMappingStore >> destForSrc: t [

	^ srcToDest at: t ifAbsent: [nil]
]

{ #category : #'as yet unclassified' }
DCMappingStore >> initialize [

	super initialize.
	
	srcToDest := Dictionary new.
	destToSrc := Dictionary new
]

{ #category : #'as yet unclassified' }
DCMappingStore >> isDestMapped: dest [

	^ destToSrc includesKey: dest
]

{ #category : #'as yet unclassified' }
DCMappingStore >> isSrcMapped: src [

	^ srcToDest includesKey: src
]

{ #category : #'as yet unclassified' }
DCMappingStore >> keysAndValuesDo: aBlock [

	srcToDest keysAndValuesDo: aBlock
]

{ #category : #'as yet unclassified' }
DCMappingStore >> srcForDest: t [

	^ destToSrc at: t ifAbsent: [nil]
]
