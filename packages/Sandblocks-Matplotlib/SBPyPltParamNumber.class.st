Class {
	#name : #SBPyPltParamNumber,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Matplotlib'
}

{ #category : #'as yet unclassified' }
SBPyPltParamNumber >> build [
	<lang: #python match: '(keyword_argument name: (identifier) @name value: [(float) (integer)] @value @root)' sample: 'ax.call(ymin=0.5)'>

	| range |
	range := nil.
	(#('alpha' 'ymin' 'ymax') includes: (bindings at: 'name') contents) ifTrue: [range := 0.0 to: 1.0].
	self addMorphBack: (self
		createBinding: [ | number |
			number := SBPyNumberWithPrefix new floatSteps.
			range ifNotNil: [number rangeFrom: range start to: range stop].
			number]
		contents: 'value')
]
