Class {
	#name : #DCHashBasedMapper,
	#superclass : #Object,
	#instVars : [
		'mappings'
	],
	#category : #'DomainCode-Diff'
}

{ #category : #'as yet unclassified' }
DCHashBasedMapper >> addDest: tree [

	(self entryForTree: tree) second add: tree
]

{ #category : #'as yet unclassified' }
DCHashBasedMapper >> addSrc: tree [

	(self entryForTree: tree) first add: tree
]

{ #category : #'as yet unclassified' }
DCHashBasedMapper >> ambiguousEntries [

	^ mappings select: [:entry | (entry first size > 1 and: [entry second size >= 1]) or: [entry first size >= 1 and: [entry second size > 1]]]
]

{ #category : #'as yet unclassified' }
DCHashBasedMapper >> entryForTree: tree [

	^ mappings at: tree treeHash ifAbsentPut: [
		{Set new. Set new}]
]

{ #category : #'as yet unclassified' }
DCHashBasedMapper >> initialize [

	super initialize.
	
	mappings := Dictionary new
]

{ #category : #'as yet unclassified' }
DCHashBasedMapper >> uniqueEntries [

	^ mappings select: [:entry | entry first size = 1 and: [entry second size = 1]]
]

{ #category : #'as yet unclassified' }
DCHashBasedMapper >> unmappedEntries [

	^ mappings select: [:entry | entry first isEmpty or: [entry second isEmpty]]
]
