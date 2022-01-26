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
					newResults do: [:result |
						result parser atEnd
							ifTrue: [stream nextPut: (seq copy addChild: result)]
							ifFalse: [queue add: (seq copy addChild: result)]]]]].
		
		reportResultsBlock value: self makeConcrete value: self elements size = 1.
		
		[queue notEmpty] whileTrue: [ | seq isLast |
			seq := queue removeFirst.
			isLast := seq submorphCount = (self elements size - 1).
			
			reportResultsBlock value: seq value: isLast]]) ifEmpty: [#noMatch]
]
