"
How to draw the end caps if the line is is_dashed.
"
Class {
	#name : #SBPyPltDashJoinStyle,
	#superclass : #SBPyPltParamReplacement,
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
			createReplacement: (aDictionary at: 'value') contents;
			source: (aDictionary at: 'argument') sourceString
			)
]

{ #category : #'initialize-release' }
SBPyPltDashJoinStyle >> createReplacement: aLabel [

	| items itemsTooltips selection |
	
	items := {
			{'"miter"'. SBPyPltImage joinStyleMiter}.
			{'"round"'. SBPyPltImage joinStyleRound}.
			{'"bevel"'. SBPyPltImage joinStyleBevel}.
			} collect: [:pair |
				SBRow new
					cellGap: 8;
					addMorphBack: (SBStringMorph new contents: pair first);
					addMorphBack: pair second
				].
			
	itemsTooltips := {'the "arrow-tip" style. Each boundary of the filled-in area will extend in a straight line parallel to the tangent vector of the centerline at the point it meets the corner, until they meet in a sharp point.'. 'stokes every point within a radius of linewidth/2 of the center lines.'. 'the "squared-off" style. It can be thought of as a rounded corner where the "circular" part of the corner has been cut off.'}.
	
	selection := (items select: [:i | i submorphs first contents = aLabel]) ifEmpty: [aLabel] ifNotEmpty: [:aCollection | aCollection first].

	self
		addMorphBack:  (SBPyPltComboBox new 
				values: items; prefix: 'dash_joinstyle='; object: selection; tooltips: itemsTooltips)
]
