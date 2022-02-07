Class {
	#name : #SBPyPltDashCapStyle,
	#superclass : #SBPyPltParamCBReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltDashCapStyle class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: (identifier) ="dash_capstyle"
    value: (string) @value
) @argument' sample: 'dash_capstyle="butt"'>
	
	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory;
			createReplacementWithSelectedLabel: (aDictionary at: 'value') contents
			)
]

{ #category : #'initialize-release' }
SBPyPltDashCapStyle >> items [
	^ {
			{'projecting'. SBPyPltImage capStyleProjecting}.
			{'butt'. SBPyPltImage capStyleButt}.
			{'round'. SBPyPltImage capStyleRound}.
			}
]

{ #category : #'initialize-release' }
SBPyPltDashCapStyle >> prefix [
	^ 'dash_capstyle='
]

{ #category : #'initialize-release' }
SBPyPltDashCapStyle >> tooltips [
	^ {'the line is squared off as in butt, but the filled in area extends beyond the endpoint a distance of linewidth/2.'. 'the line is squared off at its endpoint.'. 'like butt, but a semicircular cap is added to the end of the line, of radius linewidth/2.'}
]
