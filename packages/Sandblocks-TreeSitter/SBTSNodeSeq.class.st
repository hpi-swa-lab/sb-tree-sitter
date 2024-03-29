Class {
	#name : #SBTSNodeSeq,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'elements',
		'hasStatementTerminator'
	],
	#category : #'Sandblocks-TreeSitter-Grammar'
}

{ #category : #'as yet unclassified' }
SBTSNodeSeq >> allChildrenDo: aBlock visited: aSet [

	aBlock value: self.
	self elements do: [:el | el allChildrenDo: aBlock visited: aSet]
]

{ #category : #'as yet unclassified' }
SBTSNodeSeq >> allElementsDo: aBlock [

	aBlock value: self.
	self elements do: [:el | el allElementsDo: aBlock]
]

{ #category : #'as yet unclassified' }
SBTSNodeSeq >> allSubTypesDo: aBlock parents: aCollection [

	(self elements viewAllButFirst allSatisfy: [:e | e isTSRepeat and: [e required not]]) ifTrue: [self elements first allSubTypesDo: aBlock parents: aCollection]
]

{ #category : #copying }
SBTSNodeSeq >> basicCopy [

	^ super basicCopy
		elements: self elements;
		hasStatementTerminator: self hasStatementTerminator
]

{ #category : #'as yet unclassified' }
SBTSNodeSeq >> buildEmpty [

	^ self elements gather: [:element | element buildEmpty]
]

{ #category : #'as yet unclassified' }
SBTSNodeSeq >> buildEmptyNodes [

	^ self elements gather: [:element | element buildEmptyNodes]
]

{ #category : #'as yet unclassified' }
SBTSNodeSeq >> cursorPositionsDo: aClosure shallow: aBoolean blocks: aStream parent: aBlock [

	self elements do: [:child | child cursorPositionsDo: aClosure shallow: aBoolean blocks: aStream parent: aBlock]
]

{ #category : #accessing }
SBTSNodeSeq >> elements [

	^ elements
]

{ #category : #accessing }
SBTSNodeSeq >> elements: aCollection [

	elements := aCollection.
	
	aCollection do: [:elem | elem parent: self]
]

{ #category : #testing }
SBTSNodeSeq >> hasPotentialPrecedenceConflict: aCollection [

	| types newAnswer otherTypes |
	true ifTrue: [^ false].
	
	SBToggledCode comment: '' active: 0 do: {
		[ | recursing |recursing := ((aCollection select: [:node | (aCollection count: [:n | n type = node type]) > 1]) collect: [:node | node type]) withoutDuplicates]}.
	
	types := self elements select: [:el | el type notNil].
	otherTypes := (aCollection collect: #type) select: #notNil.
	aCollection last type.
	newAnswer := types anySatisfy: [:type | type type = aCollection last type or: [type allSubTypes anySatisfy: [:sym | sym type = aCollection last type]]].
	^ newAnswer
]

{ #category : #accessing }
SBTSNodeSeq >> hasStatementTerminator [

	^ hasStatementTerminator
]

{ #category : #accessing }
SBTSNodeSeq >> hasStatementTerminator: aBoolean [

	hasStatementTerminator := aBoolean
]

{ #category : #'as yet unclassified' }
SBTSNodeSeq >> initialize [

	super initialize.
	
	hasStatementTerminator := false
]

{ #category : #testing }
SBTSNodeSeq >> isTSSeq [

	^ true
]

{ #category : #printing }
SBTSNodeSeq >> labelPrintOn: aStream [

	self elements
		do: [:element | element labelPrintOn: aStream]
		separatedBy: [aStream nextPutAll: ' ']
]

{ #category : #layout }
SBTSNodeSeq >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: (Array streamContents: [:stream |
			self submorphs withIndexDo: [:morph :index |
				stream nextPut: morph layoutCommands.
				index ~= self submorphCount ifTrue: [ | next |
					next := self submorphs at: index + 1.
					stream nextPut: ((self factory hardLineBreakMatchBetween: morph and: next)
						ifTrue: [SBAlgebraCommand hardLine]
						ifFalse: [
							(self factory softLineBreakMatchBetween: morph and: next)
								ifTrue: [SBAlgebraCommand softLineOrGap]
								ifFalse: [SBAlgebraCommand gap]])]]])
]

{ #category : #accessing }
SBTSNodeSeq >> maxChildren [

	^ self elements size
]

{ #category : #printing }
SBTSNodeSeq >> printOn: aStream [

	aStream nextPut: $(.
	self elements do: [:alt | aStream print: alt] separatedBy: [aStream nextPutAll: ' '].
	aStream nextPut: $)
]

{ #category : #parsing }
SBTSNodeSeq >> resultsFor: aParser [

	| queue results incompleteResults reportResultsBlock |
	queue := OrderedCollection new.
	results := OrderedCollection new.
	incompleteResults := OrderedCollection new.
	
	reportResultsBlock := [:parser :index | | newResults |
		newResults := (self elements at: index) resultsFor: parser.
		index = self elements size
			ifTrue: [
				self hasStatementTerminator ifTrue: [
					newResults do: [:r |
						(r stream nextMatchAll: self language statementTerminator) ifTrue: [
							r skipExtras.
							r stream atEnd ifTrue: [r blocks last lastDeepChild lastConstructed: true]]]].
				results addAll: newResults]
			ifFalse: [
				newResults do: [:candidate |
					candidate atEnd
						ifTrue: [incompleteResults add: {candidate. index}]
						ifFalse: [queue add: {candidate. index}]]]].
	
	reportResultsBlock value: aParser value: 1.
	
	[queue notEmpty] whileTrue: [ | pair index parser |
		pair := queue removeFirst.
		parser := pair first.
		index := pair second + 1.
		reportResultsBlock value: parser value: index].
	
	"simplify controlflow, probably dont need separate results lists"
	self flag: #todo.
	aParser allowIncomplete
		ifTrue: [
			incompleteResults do: [:pair |
				(SBToggledCode
					comment: ''
					active: 2
					do: {[false]. [pair first shouldAbortIncompleteExpansion]}) ifFalse: [
					self elements
						from: pair second + 1
						to: self elements size
						do: [:node | pair first addEmptyBlocks: node buildEmptyNodes].
					results add: pair first]]]
		ifFalse: [
			incompleteResults do: [:pair | "if none of the remaining nodes produce any blocks it is still a complete result"
			((self elements viewFrom: pair second + 1 to: self elements size) allSatisfy: [:node | node buildEmptyNodes isEmpty]) ifTrue: [results add: pair first]]].
	^ results
]

{ #category : #parsing }
SBTSNodeSeq >> resultsForBlocks: aParser [

	| queue |
	queue := OrderedCollection with: {aParser. 0}.
	^ Array streamContents: [:stream |
		[queue notEmpty] whileTrue: [ | pair parser results index |
			pair := queue removeFirst.
			parser := pair first.
			index := pair second + 1.
			results := (self elements at: index) resultsForBlocks: parser.
			results do: [:candidate |
				index = self elements size
					ifTrue: [stream nextPut: candidate]
					ifFalse: [queue add: {candidate. index}]]]]
]

{ #category : #parsing }
SBTSNodeSeq >> takeNodesFrom: aParser [

	| queue |
	queue := OrderedCollection with: {aParser. 0}.
	^ Array streamContents: [:stream |
		[queue notEmpty] whileTrue: [ | pair parser results index |
			pair := queue removeFirst.
			parser := pair first copy.
			index := pair second + 1.
			results := (self elements at: index) takeNodesFrom: parser.
			results do: [:candidate |
				index = self elements size
					ifTrue: [stream nextPut: candidate]
					ifFalse: [queue add: {candidate. index}]]]]
]

{ #category : #'as yet unclassified' }
SBTSNodeSeq >> traverseBlocks: aStream do: aBlock [

	self elements do: [:child | child traverseBlocks: aStream do: aBlock]
]

{ #category : #printing }
SBTSNodeSeq >> writeSourceOn: aStream indent: aNumber [

	self printElementsSeparated: self submorphs on: aStream indent: aNumber
]
