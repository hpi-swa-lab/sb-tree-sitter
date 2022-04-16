"
A SBReEvaluator is a block that allows to evaluate a sub-expression of a regex against multiple test strings and see the result. See SBReEvaluatorTest.

If the updateOnChange method returns true, the test cases are automatically updated when the regex changes. You might want to disable this if you are having performance issues.

You can use the Ctrl+N shortcut to wrap the currently selected block with an evaluator.
"
Class {
	#name : #SBReEvaluator,
	#superclass : #SBReEncodedReplacement,
	#instVars : [
		'examples'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #updating }
SBReEvaluator >> artefactChanged: aBlock [

	(aBlock = self containingArtefact and: [self updateOnChange])
		ifTrue: [self execute]
]

{ #category : #initialization }
SBReEvaluator >> build [

	self
		addMorphBack: (self createBindingBlock: 'pattern');
		addMorphBack: (examples := self
			createBindingListFor: 'annotation'
			build: [:list | SBReEvaluatorTestList new examples: list]
			update: [:c :m | m examples])
]

{ #category : #accessing }
SBReEvaluator >> examples [

	^ examples
]

{ #category : #actions }
SBReEvaluator >> execute [
	<action>

	self examples patternChanged
]

{ #category : #accessing }
SBReEvaluator >> isArtefact [

	^ true
]

{ #category : #accessing }
SBReEvaluator >> pattern [

	^ self firstSubmorph
]

{ #category : #updating }
SBReEvaluator >> patternChanged [

	self updateAllHighlights.
	self execute
]

{ #category : #accessing }
SBReEvaluator >> updateOnChange [

	^ true
]
