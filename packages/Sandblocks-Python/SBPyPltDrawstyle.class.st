Class {
	#name : #SBPyPltDrawstyle,
	#superclass : #SBPyPltParamCBReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltDrawstyle class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: [(identifier) ="drawstyle" (identifier) ="ds"]
    value: (string) @value
) @argument' sample: 'drawstyle="steps"'>
	
	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory;
			createReplacementWithSelectedLabel: (aDictionary at: 'value') contents
			)
]

{ #category : #'initialize-release' }
SBPyPltDrawstyle >> items [
	^ {
			{'default'. SBPyPltImage drawstyleDefault}.
			{'steps'. SBPyPltImage drawstylePre}.
			{'steps-pre'. SBPyPltImage drawstylePre}.
			{'steps-mid'. SBPyPltImage drawstyleMid}.
			{'steps-post'. SBPyPltImage drawstylePost}.
		}
]

{ #category : #'initialize-release' }
SBPyPltDrawstyle >> prefix [
	^ 'drawstyle='
]

{ #category : #'initialize-release' }
SBPyPltDrawstyle >> tooltips [
	^ {'For "default", the points are connected with straight lines.'. '"steps" is equal to "steps-pre" and is maintained for backward-compatibility.'. 'The step is at the beginning of the line segment, i.e. the line will be at the y-value of point to the right.'. 'The step is halfway between the points.'. 'The step is at the end of the line segment, i.e. the line will be at the y-value of the point to the left.'  }
]
