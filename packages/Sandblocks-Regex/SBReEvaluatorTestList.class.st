"
A SBReEvaluatorTestList is a container for SBReEvaluatorTest instances.
"
Class {
	#name : #SBReEvaluatorTestList,
	#superclass : #SBBlock,
	#category : #'Sandblocks-Regex'
}

{ #category : #accessing }
SBReEvaluatorTestList >> addExample: aString [

	self addMorphBack: (SBReEvaluatorTest new contents: aString)
]

{ #category : #accessing }
SBReEvaluatorTestList >> contents [

	^ self submorphs collect: [:each | each contents]
]

{ #category : #'testing hierarchy' }
SBReEvaluatorTestList >> fixedNumberOfChildren [

	^ false
]

{ #category : #initialization }
SBReEvaluatorTestList >> initialize [

	super initialize.
	
	self
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		changeTableLayout.
		
	self addMorphBack: (SBReEvaluatorTest new)
]

{ #category : #'insert/delete' }
SBReEvaluatorTestList >> newEmptyChildNear: aBlock before: aBoolean [

	^ SBReEvaluatorTest new
]

{ #category : #'object interface' }
SBReEvaluatorTestList >> objectInterfaceNear: aBlock at: aSymbol [

	^ {[:o | o isKindOf: SBReEvaluatorTest]}
]

{ #category : #accessing }
SBReEvaluatorTestList >> pattern [

	^ (self ownerThatIsA: SBReEvaluator) ifNotNil: [:owner | owner pattern sourceString]
]

{ #category : #updating }
SBReEvaluatorTestList >> patternChanged [

	self submorphsDo: [:each | each patternChanged]
]

{ #category : #updating }
SBReEvaluatorTestList >> removeAllExamples [

	self removeAllMorphs
]
