"
How to draw the end caps if the line is is_dashed.
"
Class {
	#name : #SBPyPltCapStyle,
	#superclass : #SBPyPltParamCBReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltCapStyle class >> matchDash: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: (identifier) ="dash_capstyle"
    value: (string) @value
) @argument' sample: 'ax.plot(dash_capstyle="butt")'>
	
	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory; prefix: 'dash_capstyle=';
			createReplacementWithSelectedLabel: (aDictionary at: 'value') contents
			)
]

{ #category : #'as yet unclassified' }
SBPyPltCapStyle class >> matchSolid: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: (identifier) ="solid_capstyle"
    value: (string) @value
) @argument' sample: 'ax.plot(solid_capstyle="butt")'>
	
	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory; prefix: 'solid_capstyle=';
			createReplacementWithSelectedLabel: (aDictionary at: 'value') contents
			)
]

{ #category : #'initialize-release' }
SBPyPltCapStyle >> itemDefinitions [
	^ {
			{'projecting'. SBPyPltImage capStyleProjecting. 'the line is squared off as in butt, but the filled in area extends beyond the endpoint a distance of linewidth/2.'}.
			
			{'butt'. SBPyPltImage capStyleButt. 'the line is squared off at its endpoint.'}.
			
			{'round'. SBPyPltImage capStyleRound. 'like butt, but a semicircular cap is added to the end of the line, of radius linewidth/2.'}.
			}
]
