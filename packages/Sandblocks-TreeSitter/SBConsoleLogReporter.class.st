Class {
	#name : #SBConsoleLogReporter,
	#superclass : #SBInlineBlockReplace,
	#instVars : [
		'watch'
	],
	#category : #'Sandblocks-TreeSitter-Examples'
}

{ #category : #'as yet unclassified' }
SBConsoleLogReporter class >> matchJs: aDictionary do: aBlock [
	<lang: #javascript match: '(call_expression (member_expression object: (identifier) ="console" property: (identifier) ="log") (arguments (_) @expression)) @log' sample: 'console.log("HI")'>

	^ aBlock value: (aDictionary at: 'log') value: (self new expression: (aDictionary at: 'expression'))
]

{ #category : #'as yet unclassified' }
SBConsoleLogReporter >> expression [

	^ self lastSubmorph
]

{ #category : #'as yet unclassified' }
SBConsoleLogReporter >> expression: aBlock [

	self
		addMorphBack: (SBStringMorph new
			contents: 'log: ';
			bold);
		addMorphBack: aBlock buildCopy.
	
	watch := SBTSWatch newEmpty when: #reportedValue send: #newValue: to: self
]

{ #category : #'as yet unclassified' }
SBConsoleLogReporter >> newValue: aString [

	Transcript showln: aString
]

{ #category : #'as yet unclassified' }
SBConsoleLogReporter >> writeSourceOn: aStream [

	watch expression: self expression.
	
	aStream nextPutAll: 'console.log('.
	watch writeSourceOn: aStream.
	aStream nextPutAll: ')'
]
