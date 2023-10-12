Class {
	#name : #DCMatcher,
	#superclass : #Object,
	#category : #'DomainCode-Diff'
}

{ #category : #'as yet unclassified' }
DCMatcher >> applyEditsIn: aDest to: aSrc [

	DCChawatheScriptGenerator new
		generateFrom: aSrc
		to: aDest
		in: (self matchFrom: aSrc to: aDest)
]

{ #category : #'as yet unclassified' }
DCMatcher >> commonAncestorOf: aCollection root: aTree [

	| current |
	aCollection ifEmpty: [^ nil].
	
	current := aCollection first parent.
	[current ~= aTree] whileTrue: [
		(aCollection allSatisfy: [:t | t = current or: [t hasAnyParent: current]]) ifTrue: [^ current].
		current := current parent].
	
	^ aTree
]

{ #category : #'as yet unclassified' }
DCMatcher >> doCommandForEditsIn: aDest to: aSrc in: anEditor [

	SBToggledCode comment: '' active: 1 do: {
		[
			DCChawatheScriptGenerator new
				generateFrom: aSrc
				to: aDest
				in: (self matchFrom: aSrc to: aDest)].
		[
			DCCommandScriptGenerator new
				editor: anEditor;
				generateFrom: aSrc to: aDest in: (self matchFrom: aSrc to: aDest)]}
]

{ #category : #'as yet unclassified' }
DCMatcher >> fineGrainedMatch2From: src to: dest in: aMapping [

	| topSrc topDest |
	topSrc := self
		commonAncestorOf: (Array streamContents: [:s | src allChildrenDo: [:k | (aMapping isSrcMapped: k) ifFalse: [s nextPut: k]]])
		root: src.
	topDest := self
		commonAncestorOf: (Array streamContents: [:s | dest allChildrenDo: [:k | (aMapping isDestMapped: k) ifFalse: [s nextPut: k]]])
		root: dest.
	(topSrc notNil and: [topDest notNil]) ifTrue: [
		"see if we can answer quickly, otherwise we accept a worse diff result"
		[
			DCGreedyBottomUpMatcher new
				sizeThreshold: 900000000;
				lastChanceMatchFrom: topSrc to: topDest in: aMapping]
			valueWithin: 400 milliSeconds
			onTimeout: []]
]

{ #category : #'as yet unclassified' }
DCMatcher >> fineGrainedMatchFrom: src to: dest in: aMapping [

	| topSrc topDest |
	topSrc := (Array streamContents: [:s | src allChildrenDo: [:k | (aMapping isSrcMapped: k) ifFalse: [s nextPut: k]]]) detectMax: #treeHeight.
	topDest := (Array streamContents: [:s | dest allChildrenDo: [:k | (aMapping isDestMapped: k) ifFalse: [s nextPut: k]]]) detectMax: #treeHeight.
	
	self halt.
	topSrc ifNotNil: [
		self assert: (aMapping destForSrc: topSrc parent) = topDest parent.
		DCGreedyBottomUpMatcher new
			sizeThreshold: 900000000;
			lastChanceMatchFrom: topSrc to: topDest in: aMapping]
]

{ #category : #'as yet unclassified' }
DCMatcher >> largestUnmappedFor: aTree isSrc: aBoolean in: aMapping [

	^ (Array streamContents: [:s | aTree allChildrenDo: [:k | (aBoolean ifTrue: [aMapping isSrcMapped: k] ifFalse: [aMapping isDestMapped: k]) ifFalse: [s nextPut: k]]]) detectMax: #treeHeight
]

{ #category : #'as yet unclassified' }
DCMatcher >> matchFrom: src to: dest [

	| mappings |
	mappings := DCMappingStore new from: src to: dest.
	DCGreedySubtreeMatcher new matchFrom: src to: dest in: mappings.
	DCGreedyBottomUpMatcher new matchFrom: src to: dest in: mappings.
	self fineGrainedMatch2From: src to: dest in: mappings.
	
	^ mappings
]

{ #category : #'as yet unclassified' }
DCMatcher >> performEditsIn: aDest to: aSrc [

	aSrc allChildrenDo: [:m | m clearDiffCache].
	
	DCChawatheScriptGenerator new
		generateFrom: aSrc
		to: aDest
		in: (self matchFrom: aSrc to: aDest)
]
