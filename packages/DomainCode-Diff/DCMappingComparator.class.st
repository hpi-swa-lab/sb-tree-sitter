Class {
	#name : #DCMappingComparator,
	#superclass : #Object,
	#instVars : [
		'srcDescendants',
		'destDescendants',
		'mappingStore',
		'srcAncestors',
		'destAncestors',
		'rootSrc',
		'rootDest'
	],
	#category : #'DomainCode-Diff'
}

{ #category : #'as yet unclassified' }
DCMappingComparator class >> diceCoefficientCommon: aCommonNumber left: aLeftNumber right: aRightNumber [

	^ 2.0 * aCommonNumber / (aLeftNumber + aRightNumber)
]

{ #category : #'as yet unclassified' }
DCMappingComparator class >> diceSimilarityFrom: src to: dest in: aMapping [

	^ self
		diceCoefficientCommon: (self numberOfMappedDescendantsFrom: src to: dest in: aMapping)
		left: src recursiveSubmorphCount - 1
		right: dest recursiveSubmorphCount - 1
]

{ #category : #'as yet unclassified' }
DCMappingComparator class >> numberOfMappedDescendantsFrom: src to: dest in: aMapping [

	| dstDescendants mappedDescendants |
	dstDescendants := dest descendantsPreOrder asSet.
	mappedDescendants := 0.
	
	src descendantsPreOrder do: [:srcDescendant | ((aMapping isSrcMapped: srcDescendant) and: [dstDescendants includes: (aMapping destForSrc: srcDescendant)]) ifTrue: [mappedDescendants := mappedDescendants + 1]].
	
	^ mappedDescendants
]

{ #category : #'as yet unclassified' }
DCMappingComparator >> compare: aMapping with: anotherMapping [

	| result |
	result := self similaritySiblingsCompare: aMapping with: anotherMapping.
	result = 0 ifFalse: [^ result].
	
	result := self similarityParentsCompare: aMapping with: anotherMapping.
	result = 0 ifFalse: [^ result].
	
	result := self similarityPositionInParentsCompare: aMapping with: anotherMapping.
	result = 0 ifFalse: [^ result].
	
	result := self distanceTextualCompare: aMapping with: anotherMapping.
	result = 0 ifFalse: [^ result].
	
	result := self distanceAbsoluteCompare: aMapping with: anotherMapping.
	result = 0 ifFalse: [^ result].
	
	^ 0
]

{ #category : #'as yet unclassified' }
DCMappingComparator >> distanceAbsoluteCompare: aMapping with: anotherMapping [

	| position distance |
	"compare the post-order position in the tree of the mapping, between src and dest"
	position := [:tree :root | root absolutePositionOf: tree].
	distance := [:mapping | ((position value: mapping first value: rootSrc) - (position value: mapping second value: rootDest)) abs].
	^ ((distance value: aMapping) - (distance value: anotherMapping)) sign
]

{ #category : #'as yet unclassified' }
DCMappingComparator >> distanceTextualCompare: aMapping with: anotherMapping [

	| distance |
	"compares how far each mapping moved from src to dest in terms of its textual start and end indices"
	distance := [:mapping | (mapping first range start index - mapping second range start index) abs + (mapping first range end index - mapping second range end index) abs].
	^ ((distance value: aMapping) - (distance value: anotherMapping)) sign
]

{ #category : #'as yet unclassified' }
DCMappingComparator >> initialize [

	super initialize.
	
	srcDescendants := Dictionary new.
	destDescendants := Dictionary new.
	srcAncestors := Dictionary new.
	destAncestors := Dictionary new
]

{ #category : #'as yet unclassified' }
DCMappingComparator >> longestCommonSubsequenceWith: aCollection and: anotherCollection [

	| lengths x y indices |
	lengths := Matrix rows: aCollection size + 1 columns: anotherCollection size + 1 element: 0.
	1 to: aCollection size do: [:i |
		1 to: anotherCollection size do: [:j |
			(aCollection at: i) type = (anotherCollection at: j) type
				ifTrue: [lengths at: i + 1 at: j + 1 put: (lengths at: i at: j)]
				ifFalse: [lengths at: i + 1 at: j + 1 put: ((lengths at: i + 1 at: j) max: (lengths at: i at: j + 1))]]].
	
	indices := OrderedCollection new.
	x := aCollection size + 1.
	y := anotherCollection size + 1.
	[x > 1 and: [y > 1]] whileTrue: [
		(lengths at: x at: y) = (lengths at: x - 1 at: y)
			ifTrue: [x := x - 1]
			ifFalse: [
				(lengths at: x at: y) = (lengths at: x at: y - 1)
					ifTrue: [y := y - 1]
					ifFalse: [
						indices add: {x - 1. y - 1}.
						x := x - 1.
						y := y - 1]]].
	
	^ indices reverseInPlace
]

{ #category : #'as yet unclassified' }
DCMappingComparator >> mappingStore: aMapping [

	mappingStore := aMapping
]

{ #category : #'as yet unclassified' }
DCMappingComparator >> numberOfCommonDescendantsIn: src and: dest [

	| common |
	srcDescendants at: src ifAbsentPut: src descendantsPreOrder asSet.
	destDescendants at: dest ifAbsentPut: dest descendantsPreOrder asSet.
	
	common := 0.
	srcDescendants keysDo: [:t | | m |
		m := mappingStore destForSrc: t.
		(m notNil and: [(destDescendants at: dest) includes: m]) ifTrue: [common := common + 1]].
	^ common
]

{ #category : #'as yet unclassified' }
DCMappingComparator >> numberOfCommonParentsIn: src and: dest [

	^ (self longestCommonSubsequenceWith: (srcAncestors at: src) and: (destAncestors at: dest)) size
]

{ #category : #'as yet unclassified' }
DCMappingComparator >> rootSrc: aBlock rootDest: anotherBlock [

	rootSrc := aBlock.
	rootDest := anotherBlock
]

{ #category : #'as yet unclassified' }
DCMappingComparator >> similarityParentsCompare: aMapping with: anotherMapping [

	| s1 s2 |
	(aMapping first owner = anotherMapping first owner and: [aMapping second owner = anotherMapping second owner]) ifTrue: [^ 0].
	
	srcAncestors at: aMapping first ifAbsentPut: (aMapping first allParentsUpTo: rootSrc).
	destAncestors at: aMapping second ifAbsentPut: (aMapping second allParentsUpTo: rootDest).
	srcAncestors
		at: anotherMapping first
		ifAbsentPut: (anotherMapping first allParentsUpTo: rootSrc).
	destAncestors
		at: anotherMapping second
		ifAbsentPut: (anotherMapping second allParentsUpTo: rootDest).
	
	s1 := self class
		diceCoefficientCommon: (self numberOfCommonParentsIn: aMapping first and: aMapping second)
		left: (srcAncestors at: aMapping first) size
		right: (destAncestors at: aMapping second) size.
	s2 := self class
		diceCoefficientCommon: (self numberOfCommonParentsIn: anotherMapping first and: anotherMapping second)
		left: (srcAncestors at: anotherMapping first) size
		right: (destAncestors at: anotherMapping second) size.
	
	^ (s1 - s2) sign
]

{ #category : #'as yet unclassified' }
DCMappingComparator >> similarityPositionInParentsCompare: aMapping with: anotherMapping [

	| indicesInOwnerSubmorphs distance |
	indicesInOwnerSubmorphs := [:src | | current indices |
		indices := OrderedCollection new.
		current := src.
		[current notNil and: [current owner notNil]] whileTrue: [
			indices add: current submorphIndex.
			current := current owner].
		indices].
	distance := [:mapping | | indicesVec1 indicesVec2 sum |
		indicesVec1 := indicesInOwnerSubmorphs value: mapping first.
		indicesVec2 := indicesInOwnerSubmorphs value: mapping second.
		sum := 0.0.
		1
			to: (indicesVec1 size min: indicesVec2 size)
			do: [:index | sum := sum + ((indicesVec1 at: index) - (indicesVec2 at: index)) squared].
		sum sqrt].
	^ ((distance value: aMapping) - (distance value: anotherMapping)) sign
]

{ #category : #'as yet unclassified' }
DCMappingComparator >> similaritySiblingsCompare: aMapping with: anotherMapping [

	| s1 s2 |
	(aMapping first owner = anotherMapping first owner and: [aMapping second owner = anotherMapping second owner]) ifTrue: [^ 0].
	
	s1 := self class
		diceCoefficientCommon: (self numberOfCommonDescendantsIn: aMapping first owner and: aMapping second owner)
		left: (srcDescendants at: aMapping first owner) size
		right: (destDescendants at: aMapping second owner) size.
	s2 := self class
		diceCoefficientCommon: (self numberOfCommonDescendantsIn: anotherMapping first owner and: anotherMapping second owner)
		left: (srcDescendants at: anotherMapping first owner) size
		right: (destDescendants at: anotherMapping second owner) size.
	
	^ (s1 - s2) sign
]
