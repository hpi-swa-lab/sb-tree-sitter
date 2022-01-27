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

{ #category : #query }
SBTSNodeSeq >> childrenForQueryDo: aBlock [

	self submorphsDo: [:m | m childrenForQueryDo: aBlock]
]

{ #category : #accessing }
SBTSNodeSeq >> elements [

	^ elements
]

{ #category : #accessing }
SBTSNodeSeq >> elements: aCollection [

	elements := aCollection
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
			newResults := (self elements at: seq submorphCount + 1) resultsFor: (seq hasSubmorphs ifTrue: [seq lastChild parser] ifFalse: [aParser]) copy.
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
			isLast := seq submorphCount = (self elements size - 1).
			
			reportResultsBlock value: seq value: isLast]]) ifEmpty: [#noMatch]
]

{ #category : #parsing }
SBTSNodeSeq >> takeNodesFrom: aParser [

	| queue |
	queue := OrderedCollection new
		add: self makeConcrete;
		yourself.
	^ (Array streamContents: [:stream |
		[queue notEmpty] whileTrue: [ | seq results |
			seq := queue removeFirst.
			results := (self elements at: seq submorphCount + 1) takeNodesFrom: (seq hasSubmorphs ifTrue: [seq lastChild parser] ifFalse: [aParser]) copy.
			results = #noMatch ifFalse: [
				results do: [:res | | candidate |
					candidate := seq copy addChild: res.
					candidate submorphCount = self elements size
						ifTrue: [stream nextPut: candidate]
						ifFalse: [queue add: candidate]]]]]) ifEmpty: [#noMatch]
]

{ #category : #printing }
SBTSNodeSeq >> writeSourceOn: aStream indent: aNumber [

	self printElementsSeparated: self submorphs on: aStream indent: aNumber
]
