Class {
	#name : #SBReEvaluator,
	#superclass : #SBReAnnotation,
	#instVars : [
		'examples'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReEvaluator >> annotation [

	^ (self examples contents collect: [:each | each base64Encoded]) joinSeparatedBy: ','
]

{ #category : #'as yet unclassified' }
SBReEvaluator >> annotation: aString [

	self examples removeAllExamples.
	(aString splitBy: ',') do: [:each | self examples addExample: each base64Decoded]
]

{ #category : #'as yet unclassified' }
SBReEvaluator >> color [

	^ Color r: 0.794 g: 0.25 b: 0.25
]

{ #category : #'as yet unclassified' }
SBReEvaluator >> examples [

	^ examples
]

{ #category : #'as yet unclassified' }
SBReEvaluator >> execute [

	self examples patternChanged
]

{ #category : #'as yet unclassified' }
SBReEvaluator >> initialize [

	super initialize.
	
	self
		addMorphBack: (SBRow new
			addMorphBack: self pattern;
			addMorphBack: (SBColumn new
				addMorphBack: (SBRow new
					addMorphBack: (SBButton new
						icon: SBIcon iconPlay
						shortcut: nil
						do: [self execute]);
					addMorphBack: (SBButton new
						icon: SBIcon iconRemove
						shortcut: nil
						do: [self replaceWithWrapped])
				);
				addMorphBack: (examples := SBReEvaluatorTestList new)
			))
]

{ #category : #'as yet unclassified' }
SBReEvaluator >> patternChanged [

	self updateAllHighlights.
	self execute
]
