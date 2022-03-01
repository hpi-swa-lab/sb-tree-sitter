Class {
	#name : #SBPyPltDrawstyle,
	#superclass : #SBPyPltParamCBReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltDrawstyle class >> match: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: [(identifier) ="drawstyle" (identifier) ="ds"]
    value: (string) @value
) @argument' sample: 'ax.plot(drawstyle="steps")'>
	
	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory; prefix:  'drawstyle=';
			createReplacementWithSelectedLabel: (aDictionary at: 'value') contents
			)
]

{ #category : #'initialize-release' }
SBPyPltDrawstyle >> itemDefinitions [
	^ {
			{'default'. SBPyPltImage drawstyleDefault. 'For "default", the points are connected with straight lines.'}.
			{'steps'. SBPyPltImage drawstylePre. '"steps" is equal to "steps-pre" and is maintained for backward-compatibility.'}.
			{'steps-pre'. SBPyPltImage drawstylePre. 'The step is at the beginning of the line segment, i.e. the line will be at the y-value of point to the right.'}.
			{'steps-mid'. SBPyPltImage drawstyleMid. 'The step is halfway between the points.'}.
			{'steps-post'. SBPyPltImage drawstylePost. 'The step is at the end of the line segment, i.e. the line will be at the y-value of the point to the left.'}.
		}
]
