Class {
	#name : #SBTSNodeSeq,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'elements'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #copying }
SBTSNodeSeq >> basicCopy [

	^ super basicCopy elements: self elements
]

{ #category : #build }
SBTSNodeSeq >> build [

	^ self children gather: [:child | child build]
]

{ #category : #query }
SBTSNodeSeq >> childrenForQueryDo: aBlock [

	self submorphsDo: [:m | m childrenForQueryDo: aBlock]
]

{ #category : #'as yet unclassified' }
SBTSNodeSeq >> cursorPositionsDo: aBlock shallow: aBoolean blocks: aCollection [

	self elements do: [:child | child cursorPositionsDo: aBlock shallow: aBoolean blocks: aCollection]
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
	queue := OrderedCollection with: self makeConcrete.
	^ (Array streamContents: [:stream |
		[queue notEmpty] whileTrue: [ | seq results |
			seq := queue removeFirst.
			results := (self elements at: seq children size + 1) takeNodesFrom: (seq children ifNotEmpty: [seq lastChild parser] ifEmpty: [aParser]) copy.
			results = #noMatch ifFalse: [
				results do: [:res | | candidate |
					candidate := seq copy addChild: res.
					candidate children size = self elements size
						ifTrue: [stream nextPut: candidate]
						ifFalse: [queue add: candidate]]]]]) ifEmpty: [#noMatch]
]

{ #category : #printing }
SBTSNodeSeq >> writeSourceOn: aStream indent: aNumber [

	self printElementsSeparated: self submorphs on: aStream indent: aNumber
]
