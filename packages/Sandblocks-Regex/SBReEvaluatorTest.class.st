"
A SBReEvaluatorTest is one test case in a SBReEvaluator.

The text it contains is matched against the regex contained in the SBReEvaluator. Because this is intended for testing only a sub-expression of a regex, only the relevant part of the complete regex is used for matching. This loss of context could lead to some unexpected results. For example, if the complete regex is 'abc' and a test case for only the middle 'b' part is created, the whole regex does not match the string 'abbc' while the incomplete part matches the string 'bb'. This is unexpected, in my opinion, as the sub-expression is only relevant in the context of the complete expression. Therefore, a match is only valid if is the whole input string. This can break when lazy quantifiers are involved.
Future work: Another possibility is to show what part of the string was matched and what part was not matched. Even the groups could be listed.

To execute the regex, the Javascript runtime is used.

Because of bad performance, the matches are not updated on regex or test case change.
"
Class {
	#name : #SBReEvaluatorTest,
	#superclass : #SBBlock,
	#instVars : [
		'pattern'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #accessing }
SBReEvaluatorTest >> color [

	^ color
]

{ #category : #accessing }
SBReEvaluatorTest >> color: aColor [

	color := aColor
]

{ #category : #accessing }
SBReEvaluatorTest >> contents [

	^ self submorphs first contents
]

{ #category : #accessing }
SBReEvaluatorTest >> contents: aString [

	self submorphs first contents: aString
]

{ #category : #actions }
SBReEvaluatorTest >> execute [

	self parseResult: (SBJavascript instance runtime evaluate: self javascriptSource)
]

{ #category : #initialization }
SBReEvaluatorTest >> initialize [

	super initialize.
	
	self
		addMorphBack: (SBTextBubble multiLine placeholderText: 'string');
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		changeTableLayout
]

{ #category : #helpers }
SBReEvaluatorTest >> javascriptSource [

	^ 'console.log(JSON.stringify(RegExp({1}).exec({2})?.[0] ?? ""))' format: {
		self pattern asJsonString.
		self contents asJsonString.	
	}
]

{ #category : #updating }
SBReEvaluatorTest >> match [

	self color: Color green
]

{ #category : #updating }
SBReEvaluatorTest >> noMatch [

	self color: Color red
]

{ #category : #updating }
SBReEvaluatorTest >> parseResult: aString [

	(Json readFrom: aString readStream) = self contents
		ifTrue: [self match]
		ifFalse: [self noMatch]
	
]

{ #category : #accessing }
SBReEvaluatorTest >> pattern [

	^ self owner ifNotNil: [:owner | owner pattern]
]

{ #category : #updating }
SBReEvaluatorTest >> patternChanged [

	self execute
]
