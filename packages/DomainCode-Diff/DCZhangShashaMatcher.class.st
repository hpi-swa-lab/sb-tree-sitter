Class {
	#name : #DCZhangShashaMatcher,
	#superclass : #Object,
	#category : #'DomainCode-Diff'
}

{ #category : #'as yet unclassified' }
DCZhangShashaMatcher >> computeForestDistFrom: zsSrc at: i to: zsDest at: j in: forestDist treeDist: treeDist [

	forestDist at: (zsSrc lldAt: i) at: (zsDest lldAt: j) put: 0.
	(zsSrc lldAt: i) to: i do: [:di | | costDeletion |
		costDeletion := self deletionCostOf: (zsSrc treeAt: di).
		forestDist
			at: di + 1
			at: (zsDest lldAt: j)
			put: (forestDist at: di at: (zsDest lldAt: j)) + costDeletion.
		(zsDest lldAt: j) to: j do: [:dj | | constInsertion |
			constInsertion := self insertionCostOf: (zsDest lldAt: dj).
			forestDist
				at: (zsSrc lldAt: i)
				at: dj + 1
				put: (forestDist at: (zsSrc lldAt: i) at: dj) + constInsertion.
			((zsSrc lldAt: di) = (zsSrc lldAt: i) and: [(zsDest lldAt: dj) = (zsDest lldAt: j)])
				ifTrue: [ | costUpdate cost |
					costUpdate := self updateCostFrom: (zsSrc treeAt: di) to: (zsDest treeAt: dj).
					cost := {
						(forestDist at: di at: dj + 1) + costDeletion.
						(forestDist at: di + 1 at: dj) + constInsertion.
						(forestDist at: di at: dj) + costUpdate} min.
					forestDist at: di + 1 at: dj + 1 put: cost.
					treeDist at: di + 1 at: dj + 1 put: cost]
				ifFalse: [
					forestDist at: di + 1 at: dj + 1 put: {
						(forestDist at: di at: dj + 1) + costDeletion.
						(forestDist at: di + 1 at: dj) + constInsertion.
						(forestDist at: (zsSrc lldAt: di) at: (zsDest lldAt: dj)) + (treeDist at: di + 1 at: dj + 1)} min]]]
]

{ #category : #'as yet unclassified' }
DCZhangShashaMatcher >> computeTreeDistFrom: zsSrc to: zsDest [

	| treeDist forestDist |
	treeDist := Matrix rows: zsSrc nodeCount + 1 columns: zsDest nodeCount + 1.
	forestDist := Matrix rows: zsSrc nodeCount + 1 columns: zsDest nodeCount + 1.
	
	1 to: zsSrc keyRoots size - 1 do: [:i |
		1
			to: zsDest keyRoots size - 1
			do: [:j | self computeForestDistFrom: zsSrc at: i to: zsDest at: j in: forestDist treeDist: treeDist]].
	
	^ forestDist
]

{ #category : #'as yet unclassified' }
DCZhangShashaMatcher >> deletionCostOf: tree [

	^ 1
]

{ #category : #'as yet unclassified' }
DCZhangShashaMatcher >> insertionCostOf: tree [

	^ 1
]

{ #category : #'as yet unclassified' }
DCZhangShashaMatcher >> levenshteinDistanceFrom: aString to: anotherString [
	"distances at: i at: j will hold the Levenshtein distance between the first i characters of the receiver and the first j characters of anotherString."

	| distances |
	distances := Matrix rows: aString size columns: anotherString size element: 0.
	
	"source prefixes can be transformed into empty string by dropping all characters"
	1 to: aString size do: [:i | distances at: i at: 1 put: i].
	"target prefixes can be reached from empty source prefix by inserting every character"
	1 to: anotherString size do: [:j | distances at: 1 at: j put: j].
	
	2 to: anotherString size do: [:j |
		2 to: aString size do: [:i | | deletionCost insertionCost substitutionCost |
			deletionCost := (distances at: i - 1 at: j) + 1.
			insertionCost := (distances at: i at: j - 1) + 1.
			substitutionCost := (distances at: i - 1 at: j - 1) + ((aString at: i) = (anotherString at: j) ifTrue: [0] ifFalse: [1]).
			distances at: i at: j put: ((deletionCost min: insertionCost) min: substitutionCost)]].
	
	^ distances at: aString size at: anotherString size
]

{ #category : #'as yet unclassified' }
DCZhangShashaMatcher >> matchFrom: src to: dest in: aMappingStore [

	| zsSrc zsDest treePairQueue rootNodePair forestDist |
	zsSrc := DCZhangShashaTree new for: src.
	zsDest := DCZhangShashaTree new for: dest.
	
	forestDist := self computeTreeDistFrom: zsSrc to: zsDest.
	rootNodePair := true.
	
	treePairQueue := OrderedCollection with: {zsSrc nodeCount. zsDest nodeCount}.
	[treePairQueue notEmpty] whileTrue: [ | treePair lastRow lastCol firstRow firstCol row col |
		treePair := treePairQueue removeFirst.
		lastRow := treePair first.
		lastCol := treePair second.
		
		rootNodePair ifTrue: [rootNodePair := false] ifFalse: ["need to recalc tree/forestDist?"
		self flag: #todo].
		
		firstRow := (zsSrc lldAt: lastRow) - 1.
		firstCol := (zsDest lldAt: lastCol) - 1.
		
		row := lastRow.
		col := lastCol.
		[row > firstRow or: [col > firstCol]] whileTrue: [
			(row > firstRow and: [(forestDist at: row at: col + 1) + 1 = (forestDist at: row + 1 at: col + 1)])
				ifTrue: [row := row - 1]
				ifFalse: [
					(col > firstCol and: [(forestDist at: row + 1 at: col) + 1 = (forestDist at: row + 1 at: col + 1)])
						ifTrue: [col := col - 1]
						ifFalse: [
							((zsSrc lldAt: row) = (zsSrc lldAt: lastRow) and: [(zsDest lldAt: col) = (zsDest lldAt: lastCol)])
								ifTrue: [ | tSrc tDest |
									tSrc := zsSrc treeAt: row.
									tDest := zsDest treeAt: col.
									tSrc type = tDest type
										ifTrue: [aMappingStore addMappingFrom: tSrc to: tDest]
										ifFalse: [self error: 'should not map incompatible nodes.'].
									row := row - 1.
									col := col - 1]
								ifFalse: [
									treePairQueue addFirst: {row. col}.
									row := (zsSrc lldAt: row) - 1.
									col := (zsDest lldAt: col) - 1]]]]]
]

{ #category : #'as yet unclassified' }
DCZhangShashaMatcher >> updateCostFrom: src to: dest [

	^ src type = dest type
		ifTrue: [
			((src isTextMorph not or: [src contents isEmpty]) or: [dest isTextMorph not or: [dest contents isEmpty]])
				ifTrue: [1]
				ifFalse: [1 - (src contents levenshteinRatioTo: dest contents)]]
		ifFalse: [900000000]
]
