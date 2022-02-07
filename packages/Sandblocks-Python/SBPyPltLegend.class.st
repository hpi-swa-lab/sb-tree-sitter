"
Shows the legend. The legend entries are the labels of the individual plots.
"
Class {
	#name : #SBPyPltLegend,
	#superclass : #SBPyPltAxis,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltLegend class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(call
        	function: (attribute
            	(identifier) ="ax"
                (identifier) ="legend"
            )
        ) @block' sample: 'ax.legend()'>
	
	^ aBlock value: (aDictionary at: 'block') value: (self new
		factory: (aDictionary at: 'block') factory; createReplacement)
]

{ #category : #'initialize-release' }
SBPyPltLegend >> createReplacement [

	self addMorphBack: (SBStringMorph new contents: 'Show legend').
]

{ #category : #'as yet unclassified' }
SBPyPltLegend >> writeSourceOn: aStream [

	aStream nextPutAll: 'ax.legend()'.
]
