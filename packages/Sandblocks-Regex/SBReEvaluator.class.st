"
A SBReEvaluator is a block that allows to evaluate a sub-expression of a regex against multiple test strings and see the result. See SBReEvaluatorTest.
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
		addMorphBack: (SBColumn new
			addMorphBack: (SBRow new
				addMorphBack: (SBButton new
					balloonText: 'execute';
					icon: SBIcon iconPlay
					shortcut: nil
					do: [self execute]);
				addMorphBack: (SBButton new
					balloonText: 'remove';
					icon: SBIcon iconRemove
					shortcut: nil
					do: [self replaceWithWrapped])
			);
			addMorphBack: (examples := SBReEvaluatorTestList new))
]

{ #category : #updating }
SBReEvaluator >> patternChanged [

	self updateAllHighlights.
	self execute
]
