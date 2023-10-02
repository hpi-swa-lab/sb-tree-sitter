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

	self children do: [:c | c allChildrenDo: aBlock].
	aBlock value: self
]

{ #category : #'*DomainCode-Core' }
Morph >> allChildrenSelect: aBlock [

	^ Array streamContents: [:stream | self allChildrenDo: [:b | (aBlock value: b) ifTrue: [stream nextPut: b]]]
]

{ #category : #'*DomainCode-Core' }
Morph >> children [

	^ submorphs
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

	^ self children notEmpty
]

{ #category : #'*DomainCode-Core' }
Morph >> isNode: aNode [

	^ self = aNode
]

{ #category : #'*DomainCode-Core' }
Morph >> treeSize [

	| i |
	i := 0.
	self allChildrenDo: [:m | i := i + 1].
	^ i
]
