Class {
	#name : #SBReEvaluatorTestList,
	#superclass : #SBBlock,
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReEvaluatorTestList >> addExample: aString [

	self addMorphBack: (SBTextBubble multiLine contents: aString)
]

{ #category : #'as yet unclassified' }
SBReEvaluatorTestList >> contents [

	^ self submorphs collect: [:each | each contents]
]

{ #category : #'as yet unclassified' }
SBReEvaluatorTestList >> fixedNumberOfChildren [

	^ false
]

{ #category : #'as yet unclassified' }
SBReEvaluatorTestList >> initialize [

	super initialize.
	
	self
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		changeTableLayout.
		
	self addMorphBack: (SBReEvaluatorTest new)
]

{ #category : #'as yet unclassified' }
SBReEvaluatorTestList >> newEmptyChildNear: aBlock before: aBoolean [

	^ SBReEvaluatorTest new
]

{ #category : #'as yet unclassified' }
SBReEvaluatorTestList >> objectInterfaceNear: aBlock at: aSymbol [

	^ {[:o | o isKindOf: SBReEvaluatorTest]}
]

{ #category : #'as yet unclassified' }
SBReEvaluatorTestList >> pattern [

	^ (self ownerThatIsA: SBReEvaluator) ifNotNil: [:owner | owner pattern sourceString]
]

{ #category : #'as yet unclassified' }
SBReEvaluatorTestList >> patternChanged [

	self submorphsDo: [:each | each patternChanged]
]
