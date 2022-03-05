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

{ #category : #query }
SBTSNodeSeq >> childrenForQueryDo: aBlock [

	self submorphsDo: [:m | m childrenForQueryDo: aBlock]
]

{ #category : #'as yet unclassified' }
SBTSNodeSeq >> cursorPositionsDo: aClosure shallow: aBoolean blocks: aCollection parent: aBlock [

	self elements do: [:child | child cursorPositionsDo: aClosure shallow: aBoolean blocks: aCollection parent: aBlock]
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
		reportResultsBlock := [:seq :isLast | | newResults |
			newResults := (self elements at: seq children size + 1) resultsFor: (seq children ifNotEmpty: [seq lastChild parser] ifEmpty: [aParser]) copy.
			newResults = #noMatch ifFalse: [
				isLast ifTrue: [stream nextPutAll: (newResults collect: [:r | seq copy addChild: r])] ifFalse: [
					newResults do: [:result | | candidate |
						candidate := seq copy addChild: result.
						result parser atEnd
							ifTrue: [stream nextPut: candidate]
							ifFalse: [queue add: candidate]]]]].
		
		reportResultsBlock value: self makeConcrete value: self elements size = 1.
		
		[queue notEmpty] whileTrue: [ | seq isLast |
			seq := queue removeFirst.
			isLast := seq children size = (self elements size - 1).
			
			reportResultsBlock value: seq value: isLast]]) ifEmpty: [#noMatch]
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

{ #category : #printing }
SBTSNodeSeq >> writeSourceOn: aStream indent: aNumber [

	self printElementsSeparated: self submorphs on: aStream indent: aNumber
]
