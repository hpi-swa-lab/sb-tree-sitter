Class {
	#name : #SBTSNodeSeq,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'elements'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeSeq >> allChildrenDo: aBlock [

	aBlock value: self.
	self elements do: [:el | el allChildrenDo: aBlock]
]

{ #category : #copying }
SBTSNodeSeq >> basicCopy [

	^ super basicCopy elements: self elements
]

{ #category : #'as yet unclassified' }
SBTSNodeSeq >> buildEmpty [

	^ self elements gather: [:element | element buildEmpty]
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
SBTSNodeSeq >> isTSSeq [

	^ true
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

	| queue |
	queue := OrderedCollection new.
	
	^ (Array streamContents: [:stream | | reportResultsBlock |
		reportResultsBlock := [:parser :index | | newResults |
			newResults := (self elements at: index) resultsFor: parser copy.
			newResults = #noMatch ifFalse: [
				index = self elements size ifTrue: [stream nextPutAll: newResults] ifFalse: [
					newResults do: [:candidate |
						candidate atEnd
							ifTrue: [
								self elements
									from: index + 1
									to: self elements size
									do: [:node | candidate addEmptyBlocks: node buildEmpty].
								stream nextPut: candidate]
							ifFalse: [queue add: {candidate. index}]]]]].
		
		reportResultsBlock value: aParser value: 1.
		
		[queue notEmpty] whileTrue: [ | pair index parser |
			pair := queue removeFirst.
			parser := pair first.
			index := pair second + 1.
			reportResultsBlock value: parser value: index]]) ifEmpty: [#noMatch]
]

{ #category : #parsing }
SBTSNodeSeq >> takeNodesFrom: aParser [

	| queue |
	queue := OrderedCollection with: {aParser. 0}.
	^ (Array streamContents: [:stream |
		[queue notEmpty] whileTrue: [ | pair parser results index |
			pair := queue removeFirst.
			parser := pair first copy.
			index := pair second + 1.
			results := (self elements at: index) takeNodesFrom: parser.
			results = #noMatch ifFalse: [
				results do: [:candidate |
					index = self elements size
						ifTrue: [stream nextPut: candidate]
						ifFalse: [queue add: {candidate. index}]]]]]) ifEmpty: [#noMatch]
]

{ #category : #'as yet unclassified' }
SBTSNodeSeq >> traverseBlocks: aStream do: aBlock [

	self elements do: [:child | child traverseBlocks: aStream do: aBlock]
]

{ #category : #printing }
SBTSNodeSeq >> writeSourceOn: aStream indent: aNumber [

	self printElementsSeparated: self submorphs on: aStream indent: aNumber
]
