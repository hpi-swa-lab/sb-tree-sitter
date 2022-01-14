Class {
	#name : #SBTSNodeSeq,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'elements'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeSeq >> copy [

	^ super copy
		elements: self elements;
		addAllMorphs: (self submorphs collect: #copy)
]

{ #category : #'as yet unclassified' }
SBTSNodeSeq >> elements [

	^ elements
]

{ #category : #'as yet unclassified' }
SBTSNodeSeq >> elements: aCollection [

	elements := aCollection
]

{ #category : #'as yet unclassified' }
SBTSNodeSeq >> printOn: aStream [

	aStream nextPut: $(.
	self elements do: [:alt | aStream print: alt] separatedBy: [aStream nextPutAll: ' '].
	aStream nextPut: $)
]

{ #category : #'as yet unclassified' }
SBTSNodeSeq >> resultsFor: aParser [

	| queue |
	queue := OrderedCollection new.
	
	^ Array streamContents: [:stream | | reportResultsBlock |
		reportResultsBlock := [:seq :isLast | | newResults |
			newResults := (self elements at: seq submorphCount + 1) resultsFor: (seq hasSubmorphs ifTrue: [seq lastChild parser] ifFalse: [aParser]) copy.
			newResults = #noMatch ifFalse: [
				isLast ifTrue: [stream nextPutAll: (newResults collect: [:r | seq copy addChild: r])] ifFalse: [
					newResults do: [:result |
						result parser atEnd
							ifTrue: [stream nextPut: (seq copy addChild: result)]
							ifFalse: [queue add: (seq copy addChild: result)]]]]].
		
		reportResultsBlock value: self value: self elements size = 1.
		
		[queue notEmpty] whileTrue: [ | seq isLast |
			seq := queue removeFirst.
			isLast := seq submorphCount = (self elements size - 1).
			
			reportResultsBlock value: seq value: isLast]]
]
