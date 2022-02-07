Class {
	#name : #SBPyPltMarker,
	#superclass : #SBPyPltParamCBReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltMarker class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
				name: (identifier) ="marker"
    				value: (string) @value
			) @argument
	' sample: 'marker="o"'>
	
	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory;
			createReplacementWithSelectedLabel: (aDictionary at: 'value') contents
			)
]

{ #category : #'initialize-release' }
SBPyPltMarker >> items [
	^ {
		{'.'. SBPyPltImage point}.
		{'o'. SBPyPltImage circle}.
		{'^'. SBPyPltImage triangleUp}.
		{'s'. SBPyPltImage square}.
		{'+'. SBPyPltImage plus}.
		{'1'. SBPyPltImage triDown}.
		{'|'. SBPyPltImage vline}.
	}
]

{ #category : #'initialize-release' }
SBPyPltMarker >> prefix [
	^'marker='
]

{ #category : #'initialize-release' }
SBPyPltMarker >> tooltips [
	^ {'point'. 'circle'. 'triangleUp'. 'square'. 'plus'. 'tri_down'. 'vline'}
]
