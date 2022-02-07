Class {
	#name : #SBPyPltDashJoinStyle,
	#superclass : #SBPyPltParamCBReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltDashJoinStyle class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: (identifier) ="dash_joinstyle"
      value: (string) @value
) @argument' sample: 'dash_joinstyle="round"'>
	
	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory;
			createReplacementWithSelectedLabel: (aDictionary at: 'value') contents
			)
]

{ #category : #'initialize-release' }
SBPyPltDashJoinStyle >> items [
	^ {
		{'miter'. SBPyPltImage joinStyleMiter}.
		{'round'. SBPyPltImage joinStyleRound}.
		{'bevel'. SBPyPltImage joinStyleBevel}.
	}
]

{ #category : #'initialize-release' }
SBPyPltDashJoinStyle >> prefix [

 	^ 'dash_joinstyle='
]

{ #category : #'initialize-release' }
SBPyPltDashJoinStyle >> tooltips [
	^ {'the "arrow-tip" style. Each boundary of the filled-in area will extend in a straight line parallel to the tangent vector of the centerline at the point it meets the corner, until they meet in a sharp point.'. 'stokes every point within a radius of linewidth/2 of the center lines.'. 'the "squared-off" style. It can be thought of as a rounded corner where the "circular" part of the corner has been cut off.'}
]
