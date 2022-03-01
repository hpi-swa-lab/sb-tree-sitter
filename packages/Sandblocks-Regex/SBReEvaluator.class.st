"
A SBReEvaluator is a block that allows to evaluate a sub-expression of a regex against multiple test strings and see the result. See SBReEvaluatorTest.

If the updateOnChange method returns true, the test cases are automatically updated when the regex changes. You might want to disable this if you are having performance issues.

You can use the Ctrl+N shortcut to wrap the currently selected block with an evaluator.
"
Class {
	#name : #SBReEvaluator,
	#superclass : #SBReAnnotation,
	#instVars : [
		'examples'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #accessing }
SBReEvaluator >> annotation [

	^ (self examples contents collect: [:each | each base64Encoded]) joinSeparatedBy: ','
]

{ #category : #accessing }
SBReEvaluator >> annotation: aString [

	self examples removeAllExamples.
	(aString splitBy: ',') do: [:each | self examples addExample: each base64Decoded]
]

{ #category : #updating }
SBReEvaluator >> artefactChanged: aBlock [

	(aBlock = self containingArtefact and: [self updateOnChange])
		ifTrue: [self execute]
]

{ #category : #accessing }
SBReEvaluator >> color [

	^ Color r: 0.794 g: 0.25 b: 0.25
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

{ #category : #initialization }
SBReEvaluator >> initialize [

	super initialize.
	
	self
		addMorphBack: self pattern;
		addMorphBack: (examples := SBReEvaluatorTestList new)
]

{ #category : #accessing }
SBReEvaluator >> isArtefact [

	^ true
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
