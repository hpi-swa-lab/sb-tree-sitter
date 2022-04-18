Class {
	#name : #SBPyPltMarker,
	#superclass : #SBPyPltParamCBReplace,
	#category : #'Sandblocks-Matplotlib'
}

{ #category : #'as yet unclassified' }
SBPyPltMarker class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
				name: (identifier) ="marker"
    				value: (string) @value
			) @argument
	' sample: 'ax.plot(marker="o")'>
	
	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory; prefix: 'marker=';
			createReplacementWithSelectedLabel: (aDictionary at: 'value') contents
			)
]

{ #category : #'initialize-release' }
SBPyPltMarker >> itemDefinitions [
	^ {
		{'.'. SBPyPltImage point. 'point'}.
		{'o'. SBPyPltImage circle. 'circle'}.
		{'^'. SBPyPltImage triangleUp. 'triangleUp'}.
		{'s'. SBPyPltImage square.  'square'}.
		{'+'. SBPyPltImage plus. 'plus'}.
		{'1'. SBPyPltImage triDown. 'tri_down'}.
		{'|'. SBPyPltImage vline. 'vline'}.
	}
]
