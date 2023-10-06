Class {
	#name : #DCMappingStore,
	#superclass : #Object,
	#instVars : [
		'srcToDest',
		'destToSrc',
		'srcRoot',
		'destRoot'
	],
	#category : #'DomainCode-Diff'
}

{ #category : #'as yet unclassified' }
DCMappingStore >> addMappingFrom: src to: dest [

	self assert: (src type = dest type or: [src = srcRoot]).
	srcToDest at: src put: dest.
	destToSrc at: dest put: src
]

{ #category : #'as yet unclassified' }
DCMappingStore >> addRecursiveMappingFrom: src to: dest [

	self addMappingFrom: src to: dest.
	src children with: dest children do: [:a :b | self addRecursiveMappingFrom: a to: b]
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
DCMappingStore >> destToSrc [

	^ destToSrc
]

{ #category : #'as yet unclassified' }
DCMappingStore >> from: aSrc to: aDest [

	srcRoot := aSrc.
	destRoot := aDest
]

{ #category : #'as yet unclassified' }
DCMappingStore >> includes: aMapping [

	^ (self destForSrc: aMapping first) = aMapping second
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

{ #category : #'as yet unclassified' }
DCMappingStore >> srcToDest [

	^ srcToDest
]

{ #category : #'as yet unclassified' }
DCMappingStore >> visualizeFrom: src to: dest [

	| destExtent srcExtent editor |
	srcExtent := src
		fullBounds;
		extent.
	destExtent := dest
		fullBounds;
		extent.
	
	"container := SBBlock new.
	 listDirection: #leftToRight; hResizing: #shrinkWrap; vResizing: #shrinkWrap; changeTableLayout; layoutInset: 10; cellGap: 50; addMorphBack: src; addMorphBack: dest."
	
	editor := SBEditor openFor: src.
	editor openMorphInView: dest.
	self keysAndValuesDo: [:from :to |
		from layoutInset: 10.
		to layoutInset: 10.
		(editor connectFrom: from to: to) color: (Color random alpha: 0.5)]
]
