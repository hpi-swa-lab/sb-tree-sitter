"
How to draw the end caps if the line is is_dashed.
"
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
			createReplacement: (aDictionary at: 'value') contents;
			source: (aDictionary at: 'argument') sourceString
			)
]

{ #category : #'initialize-release' }
SBPyPltDashCapStyle >> createReplacement: aLabel [

	| items itemsTooltips selection |
	
	items := {
			{'projecting'. SBPyPltImage capStyleProjecting}.
			{'butt'. SBPyPltImage capStyleButt}.
			{'round'. SBPyPltImage capStyleRound}.
			} collect: [:pair |
				SBRow new
					cellGap: 8;
					addMorphBack: (SBStringMorph new contents: pair first);
					addMorphBack: pair second
				].
			
	itemsTooltips := {'the line is squared off as in butt, but the filled in area extends beyond the endpoint a distance of linewidth/2.'. 'the line is squared off at its endpoint.'. 'like butt, but a semicircular cap is added to the end of the line, of radius linewidth/2.'}.
	
	selection := (items select: [:i | i submorphs first contents = aLabel]) ifEmpty: [aLabel] ifNotEmpty: [:aCollection | aCollection first].

	self
		addMorphBack:  (SBPyPltComboBox new 
				values: items; prefix: 'dash_capstyle='; object: selection; tooltips: itemsTooltips)
]

{ #category : #classification }
SBPyPltDashCapStyle >> palettes [

	^ {SBPyPltPalettePlot}
]
