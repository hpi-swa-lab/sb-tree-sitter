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
) @argument' sample: 'marker="o"'>
	
	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory;
			createReplacement: (aDictionary at: 'value') contents;
			source: (aDictionary at: 'argument') sourceString
			)
]

{ #category : #'initialize-release' }
SBPyPltMarker >> createReplacement: aLabel [

	| items itemsTooltips selection |
	
	items := {
			{'.'. SBPyPltImage point}.
			{'o'. SBPyPltImage circle}.
			{'^'. SBPyPltImage triangleUp}.
			{'s'. SBPyPltImage square}.
			{'+'. SBPyPltImage plus}.
			{'1'. SBPyPltImage triDown}.
			{'|'. SBPyPltImage vline}.
			} collect: [:pair |
				SBRow new
					cellGap: 8;
					addMorphBack: (SBStringMorph new contents: pair first);
					addMorphBack: pair second
				].
			
	itemsTooltips := {'point'. 'circle'. 'triangleUp'. 'square'. 'plus'. 'tri_down'. 'vline'}.
	
	selection := (items select: [:i | i submorphs first contents = aLabel]) ifEmpty: [aLabel] ifNotEmpty: [:aCollection | aCollection first].

	self
		addMorphBack:  (SBPyPltComboBox new 
				values: items; prefix: 'marker='; object: selection; tooltips: itemsTooltips)
]

{ #category : #classification }
SBPyPltMarker >> palettes [

	^ {SBPyPltPalettePlot}
]
