Class {
	#name : #SBTSTestCursor,
	#superclass : #Object,
	#instVars : [
		'tree',
		'depth',
		'indices',
		'factory'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSTestCursor >> currentDo: aBlock [

	| template |
	template := factory bodyNodeForRule: self currentPair first.
	self assert: template factory notNil.
	^ aBlock value: self currentPair first value: SBTSBlock new value: template
]

{ #category : #'as yet unclassified' }
SBTSTestCursor >> currentPair [

	| current |
	current := tree.
	indices do: [:index | current := current fourth at: index].
	^ current
]

{ #category : #'as yet unclassified' }
SBTSTestCursor >> currentParent [

	| current |
	current := tree.
	indices allButLastDo: [:index | current := current fourth at: index].
	^ current
]

{ #category : #'as yet unclassified' }
SBTSTestCursor >> factory [

	^ factory
]

{ #category : #'as yet unclassified' }
SBTSTestCursor >> factory: aFactory [

	factory := aFactory
]

{ #category : #'as yet unclassified' }
SBTSTestCursor >> gotoFirstChild [

	self currentPair at: 4 ifAbsent: [^ false].
	depth := depth + 1.
	indices add: 1.
	^ true
]

{ #category : #'as yet unclassified' }
SBTSTestCursor >> gotoNextSibling [

	indices last >= self currentParent fourth size ifTrue: [^ true].
	indices atLast: 1 put: indices last + 1.
	^ false
]

{ #category : #'as yet unclassified' }
SBTSTestCursor >> gotoParent [

	depth = 1 ifTrue: [^ false].
	depth := depth - 1.
	indices removeLast.
	^ true
]

{ #category : #'as yet unclassified' }
SBTSTestCursor >> initialize [

	super initialize.
	
	depth := 1.
	indices := OrderedCollection new
]

{ #category : #'as yet unclassified' }
SBTSTestCursor >> isNamed [

	^ self currentPair third
]

{ #category : #'as yet unclassified' }
SBTSTestCursor >> node [

	^ self currentPair
]

{ #category : #'as yet unclassified' }
SBTSTestCursor >> text [

	^ self currentPair second
]

{ #category : #'as yet unclassified' }
SBTSTestCursor >> tree: aTuple [

	tree := aTuple
]
