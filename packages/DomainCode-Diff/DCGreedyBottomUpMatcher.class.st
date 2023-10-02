Class {
	#name : #DCGreedyBottomUpMatcher,
	#superclass : #Object,
	#instVars : [
		'rootDest',
		'sizeThreshold'
	],
	#category : #'DomainCode-Diff'
}

{ #category : #'as yet unclassified' }
DCGreedyBottomUpMatcher >> destCandidatesFor: src in: aMapping [

	| seeds candidates visited |
	seeds := OrderedCollection new.
	src descendantsPreOrder do: [:c | (aMapping isSrcMapped: c) ifTrue: [seeds add: (aMapping destForSrc: c)]].
	
	candidates := OrderedCollection new.
	visited := Set new.
	seeds do: [:seed | | parent current |
		current := seed.
		self assert: seed notNil.
		[
			parent := current owner.
			parent notNil and: [(visited includes: parent) not]] whileTrue: [
			visited add: parent.
			(parent type = src type and: [((aMapping isDestMapped: parent) or: [parent = rootDest]) not]) ifTrue: [candidates add: parent].
			current := parent]].
	
	^ candidates
]

{ #category : #'as yet unclassified' }
DCGreedyBottomUpMatcher >> lastChanceMatchFrom: src to: dest in: aMapping [

	(src treeSize < self sizeThreshold or: [dest treeSize < self sizeThreshold]) ifTrue: [ | m zsMappings |
		m := DCZhangShashaMatcher new.
		zsMappings := DCMappingStore new.
		m matchFrom: src to: dest in: zsMappings.
		zsMappings keysAndValuesDo: [:srcCandidate :destCandidate | (aMapping allowedToMapFrom: srcCandidate to: destCandidate) ifTrue: [aMapping addMappingFrom: srcCandidate to: destCandidate]]]
]

{ #category : #'as yet unclassified' }
DCGreedyBottomUpMatcher >> matchFrom: src to: dest in: aMapping [

	rootDest := dest.
	src allChildrenDo: [:t |
		src = t
			ifTrue: [
				aMapping addMappingFrom: t to: dest.
				self lastChanceMatchFrom: t to: dest in: aMapping]
			ifFalse: [
				((aMapping isSrcMapped: t) not or: [t hasChildren not]) ifTrue: [
					(((self destCandidatesFor: t in: aMapping) select: [:candidate | (DCMappingComparator diceSimilarityFrom: t to: candidate in: aMapping) >= self similarityThreshold]) detectMax: [:candidate | DCMappingComparator diceSimilarityFrom: t to: candidate in: aMapping]) ifNotNil: [:best |
						self lastChanceMatchFrom: t to: best in: aMapping.
						aMapping addMappingFrom: t to: best]]]]
]

{ #category : #'as yet unclassified' }
DCGreedyBottomUpMatcher >> similarityThreshold [

	^ 0.5
]

{ #category : #'as yet unclassified' }
DCGreedyBottomUpMatcher >> sizeThreshold [

	^ sizeThreshold ifNil: [5]
]

{ #category : #'as yet unclassified' }
DCGreedyBottomUpMatcher >> sizeThreshold: aNumber [

	sizeThreshold := aNumber
]
