Extension { #name : #Morph }

{ #category : #'*DomainCode-Core' }
Morph >> allChildrenBreadthFirstDo: aBlock [

	| remaining |
	remaining := OrderedCollection with: self.
	[remaining notEmpty] whileTrue: [ | next |
		next := remaining removeFirst.
		aBlock value: next.
		remaining addAll: next children]
]

{ #category : #'*DomainCode-Core' }
Morph >> allChildrenDo: aBlock [

	self childrenDo: [:c | c allChildrenDo: aBlock].
	aBlock value: self
]

{ #category : #'*DomainCode-Core' }
Morph >> allChildrenPreorderDo: aBlock [

	aBlock value: self.
	self children do: [:m | m allChildrenPreorderDo: aBlock]
]

{ #category : #'*DomainCode-Core' }
Morph >> allChildrenSelect: aBlock [

	^ Array streamContents: [:stream | self allChildrenDo: [:b | (aBlock value: b) ifTrue: [stream nextPut: b]]]
]

{ #category : #'*DomainCode-Core' }
Morph >> allDomainBlocksWithDepthDo: aBlock leafDo: anotherBlock depth: aNumber [

	anotherBlock value: self value: aNumber
]

{ #category : #'*DomainCode-Core' }
Morph >> allLayoutMorphsDo: aBlock [

	aBlock value: self
]

{ #category : #'*DomainCode-Core' }
Morph >> childCount [

	| i |
	i := 0.
	self childrenDo: [:c | i := i + 1].
	^ i
]

{ #category : #'*DomainCode-Core' }
Morph >> children [

	^ submorphs
]

{ #category : #'*DomainCode-Core' }
Morph >> childrenDo: aBlock [

	submorphs do: aBlock
]

{ #category : #'*DomainCode-Core' }
Morph >> childrenSelect: aBlock [

	^ Array streamContents: [:s | self childrenDo: [:c | (aBlock value: c) ifTrue: [s nextPut: c]]]
]

{ #category : #'*DomainCode-Core' }
Morph >> firstDeepChildNode [

	| current |
	current := self.
	[current children isEmpty] whileFalse: [current := current children first].
	^ current
]

{ #category : #'*DomainCode-Core' }
Morph >> hasChildren [

	self childrenDo: [:c | ^ true].
	^ false
]

{ #category : #'*DomainCode-Core' }
Morph >> isExtra [

	^ false
]

{ #category : #'*DomainCode-Core' }
Morph >> isLineBreak [

	^ false
]

{ #category : #'*DomainCode-Core' }
Morph >> isNode: aNode [

	^ self = aNode
]

{ #category : #'*DomainCode-Core' }
Morph >> isReplacement [

	^ false
]

{ #category : #'*DomainCode-Core' }
Morph >> onlyChildrenDo: aBlock [

	self childrenDo: [:c | c allChildrenDo: aBlock]
]

{ #category : #'*DomainCode-Core' }
Morph >> purpose [

	^ nil
]

{ #category : #'*DomainCode-Core' }
Morph >> setBoundsDirect: aRectangle [

	| priorBounds box |
	priorBounds := self outerBounds.
	
	bounds := aRectangle.
	fullBounds := aRectangle.
	
	box := self outerBounds.
	box = priorBounds ifFalse: [self invalidRect: (priorBounds quickMerge: box)]
]

{ #category : #'*DomainCode-Core' }
Morph >> treeSize [

	| i |
	i := 0.
	self allChildrenDo: [:m | i := i + 1].
	^ i
]

{ #category : #'*DomainCode-Core' }
Morph >> wrapped: aSymbol [

	^ DCReplacement new
		addMorph: self;
		purpose: aSymbol
]
