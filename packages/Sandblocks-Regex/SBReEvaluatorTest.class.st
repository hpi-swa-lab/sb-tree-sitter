Class {
	#name : #SBReEvaluatorTest,
	#superclass : #SBBlock,
	#instVars : [
		'pattern'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReEvaluatorTest >> color [

	^ color
]

{ #category : #'as yet unclassified' }
SBReEvaluatorTest >> color: aColor [

	color := aColor
]

{ #category : #'as yet unclassified' }
SBReEvaluatorTest >> contents [

	^ self submorphs first contents
]

{ #category : #'as yet unclassified' }
SBReEvaluatorTest >> contents: aString [

	self submorphs first contents: aString
]

{ #category : #'as yet unclassified' }
SBReEvaluatorTest >> execute [

	self parseResult: (SBJavascript instance runtime evaluate: self javascriptSource)
]

{ #category : #'as yet unclassified' }
SBReEvaluatorTest >> initialize [

	super initialize.
	
	self
		addMorphBack: (SBTextBubble multiLine placeholderText: 'string');
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		changeTableLayout
]

{ #category : #'as yet unclassified' }
SBReEvaluatorTest >> javascriptSource [

"'const result = {1}.match(RegExp({2}));',
		'console.log(JSON.stringify(\{matches: result, groups: result?.groups\}))'"

	^ 'console.log(JSON.stringify(RegExp({1}).exec({2})?.[0] ?? ""))' format: {
		self pattern asJsonString.
		self contents asJsonString.	
	}
]

{ #category : #'as yet unclassified' }
SBReEvaluatorTest >> match [

	self color: Color green
]

{ #category : #'as yet unclassified' }
SBReEvaluatorTest >> noMatch [

	self color: Color red
]

{ #category : #'as yet unclassified' }
SBReEvaluatorTest >> parseResult: aString [

	(Json readFrom: aString readStream) = self contents
		ifTrue: [self match]
		ifFalse: [self noMatch]
	
]

{ #category : #'as yet unclassified' }
SBReEvaluatorTest >> pattern [

	^ self owner ifNotNil: [:owner | owner pattern]
]

{ #category : #'as yet unclassified' }
SBReEvaluatorTest >> patternChanged [

	self execute
]
