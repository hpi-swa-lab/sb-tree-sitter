"
A SBReEvaluatorTestList is a container for SBReEvaluatorTest instances. It's purpose is to allow insertion of new and remolad of old SBReEvaluatorTest instances using the normal Sandblocks editing functions.
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
SBReEvaluatorTestList >> examples [

	^ self submorphs collect: #contents
]

{ #category : #accessing }
SBReEvaluatorTestList >> examples: aCollection [

	aCollection do: [:e | self addExample: e]
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
