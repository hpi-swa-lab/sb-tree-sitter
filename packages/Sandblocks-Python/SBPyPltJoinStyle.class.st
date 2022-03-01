"
How to draw the end caps if the line is is_dashed.
"
Class {
	#name : #SBPyPltJoinStyle,
	#superclass : #SBPyPltParamCBReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltJoinStyle class >> matchDash: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: (identifier) ="dash_joinstyle"
      value: (string) @value
) @argument' sample: 'ax.plot(dash_joinstyle="round")'>
	
	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory; prefix: 'dash_joinstyle=';
			createReplacementWithSelectedLabel: (aDictionary at: 'value') contents
			)
]

{ #category : #'as yet unclassified' }
SBPyPltJoinStyle class >> matchSolid: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: (identifier) ="solid_joinstyle"
      value: (string) @value
) @argument' sample: 'ax.plot(solid_joinstyle="round")'>
	
	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory; prefix: 'solid_joinstyle=';
			createReplacementWithSelectedLabel: (aDictionary at: 'value') contents
			)
]

{ #category : #'initialize-release' }
SBPyPltJoinStyle >> itemDefinitions [
	^ {
		{'miter'. SBPyPltImage joinStyleMiter. 'the "arrow-tip" style. Each boundary of the filled-in area will extend in a straight line parallel to the tangent vector of the centerline at the point it meets the corner, until they meet in a sharp point.'}.
		{'round'. SBPyPltImage joinStyleRound. 'stokes every point within a radius of linewidth/2 of the center lines.'}.
		{'bevel'. SBPyPltImage joinStyleBevel. 'the "squared-off" style. It can be thought of as a rounded corner where the "circular" part of the corner has been cut off.'}.
	}
]
