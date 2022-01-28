Class {
	#name : #SBPyPltDrawstyle,
	#superclass : #SBPyPltParamReplacement,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltDrawstyle class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: [(identifier) ="drawstyle" (identifier) ="ds"]
    value: (string) @value
) @argument' sample: 'drawstyle="steps"'>
	
	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory;
			createReplacement: (aDictionary at: 'value') contents;
			source: (aDictionary at: 'argument') sourceString
			)
]

{ #category : #'initialize-release' }
SBPyPltDrawstyle >> createReplacement: aLabel [

	| items itemsTooltips selection |
	
	items := {
			{'"default"'. SBPyPltImage drawstyleDefault}.
			{'"steps"'. SBPyPltImage drawstylePre}.
			{'"steps-pre"'. SBPyPltImage drawstylePre}.
			{'"steps-mid"'. SBPyPltImage drawstyleMid}.
			{'"steps-post"'. SBPyPltImage drawstylePost}.
			} collect: [:pair |
				SBRow new
					cellGap: 8;
					addMorphBack: (SBStringMorph new contents: pair first);
					addMorphBack: pair second
				].
			
	itemsTooltips := {'For "default", the points are connected with straight lines.'. '"steps" is equal to "steps-pre" and is maintained for backward-compatibility.'. 'The step is at the beginning of the line segment, i.e. the line will be at the y-value of point to the right.'. 'The step is halfway between the points.'. 'The step is at the end of the line segment, i.e. the line will be at the y-value of the point to the left.'  }.
	
	selection := (items select: [:i | i submorphs first contents = aLabel]) ifEmpty: [aLabel] ifNotEmpty: [:aCollection | aCollection first].

	self
		addMorphBack:  (SBPyPltComboBox new 
				values: items; prefix: 'drawstyle='; object: selection; tooltips: itemsTooltips)
]
