Class {
	#name : #DCGreedySubtreeMatcher,
	#superclass : #Object,
	#instVars : [
		'rootSrc',
		'rootDest'
	],
	#category : #'DomainCode-Diff'
}

{ #category : #'as yet unclassified' }
DCGreedySubtreeMatcher >> handleAmbiguousMappings: aCollection for: aMapping [

	| comparator |
	comparator := DCMappingComparator new
		rootSrc: rootSrc rootDest: rootDest;
		mappingStore: aMapping.
	
	aCollection sort: [:m1 :m2 | | s1 s2 |
		s1 := m1 first detectMax: [:t | t treeSize].
		s2 := m2 first detectMax: [:t | t treeSize].
		s1 treeSize < s2 treeSize].
	
	aCollection do: [:entry | | candidates |
		candidates := Array streamContents: [:s | entry first do: [:src | entry second do: [:dest | s nextPut: {src. dest}]]].
		
		(candidates sort: [:m1 :m2 | (comparator compare: m1 with: m2) <= 0]) do: [:mapping | (aMapping areBothUnmappedSrc: mapping first dest: mapping second) ifTrue: [aMapping addRecursiveMappingFrom: mapping first to: mapping second]]]
]

{ #category : #'as yet unclassified' }
DCGreedySubtreeMatcher >> matchFrom: src to: dest in: aMapping [

	| ambiguousMappings srcTrees destTrees |
	rootSrc := src.
	rootDest := dest.
	
	ambiguousMappings := OrderedCollection new.
	srcTrees := DCPriorityTreeQueue new add: src.
	destTrees := DCPriorityTreeQueue new add: dest.
	[
		self synchronizePriority: srcTrees with: destTrees.
		srcTrees notEmpty and: [destTrees notEmpty]] whileTrue: [ | mapper |
		mapper := DCHashBasedMapper new.
		srcTrees removeHighest do: [:t | mapper addSrc: t].
		destTrees removeHighest do: [:t | mapper addDest: t].
		
		mapper uniqueEntries do: [:entry | aMapping addRecursiveMappingFrom: entry first anyOne to: entry second anyOne].
		ambiguousMappings addAll: mapper ambiguousEntries.
		mapper unmappedEntries do: [:entry |
			entry first do: [:t | srcTrees addTree: t].
			entry second do: [:t | destTrees addTree: t]]].
	self handleAmbiguousMappings: ambiguousMappings for: aMapping
]

{ #category : #'as yet unclassified' }
DCGreedySubtreeMatcher >> synchronizePriority: aQueue with: anotherQueue [

	[(aQueue notEmpty and: [anotherQueue notEmpty]) and: [aQueue first treeHeight ~= anotherQueue first treeHeight]] whileTrue: [
		aQueue first treeHeight > anotherQueue first treeHeight
			ifTrue: [aQueue removeHighestAndOpen]
			ifFalse: [anotherQueue removeHighestAndOpen]].
	
	(aQueue isEmpty or: [anotherQueue isEmpty]) ifTrue: [
		aQueue removeAll.
		anotherQueue removeAll.
		^ false].
	^ true
]
