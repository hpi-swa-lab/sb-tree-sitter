Class {
	#name : #DCZhangShashaTree,
	#superclass : #Object,
	#instVars : [
		'nodeCount',
		'leafCount',
		'llds',
		'labels',
		'keyRoots'
	],
	#category : #'DomainCode-Diff'
}

{ #category : #'as yet unclassified' }
DCZhangShashaTree >> for: aTree [

	| index tmpData visited k |
	nodeCount := aTree treeSize.
	leafCount := 0.
	llds := Array new: nodeCount.
	labels := Array new: nodeCount.
	
	index := 1.
	tmpData := Dictionary new.
	aTree allChildrenDo: [:n |
		tmpData at: n put: index.
		labels at: index put: n.
		llds at: index put: (tmpData at: n firstDeepChildNode) - 1.
		n hasChildren ifFalse: [leafCount := leafCount + 1].
		index := index + 1].
	
	keyRoots := Array new: leafCount + 1.
	visited := Array new: nodeCount + 1 withAll: false.
	k := leafCount.
	nodeCount to: 1 by: -1 do: [:i |
		(visited at: (self lldAt: i)) ifFalse: [
			keyRoots at: k + 1 put: i.
			visited at: (self lldAt: i) put: true.
			k := k - 1]]
]

{ #category : #'as yet unclassified' }
DCZhangShashaTree >> isLeaf: i [

	^ (self lldAt: i) = i
]

{ #category : #'as yet unclassified' }
DCZhangShashaTree >> keyRoots [

	^ keyRoots
]

{ #category : #'as yet unclassified' }
DCZhangShashaTree >> lldAt: i [

	^ (llds at: i) + 1
]

{ #category : #'as yet unclassified' }
DCZhangShashaTree >> nodeCount [

	^ nodeCount
]

{ #category : #'as yet unclassified' }
DCZhangShashaTree >> treeAt: i [

	^ labels at: i
]
