"
The starting point for all matplotlib related content. It imports matplotlib, so it needs to be placed before any other matplotlib replacements.
"
Class {
	#name : #SBPyPltInitPlots,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltInitPlots class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(assignment
    	left: (pattern_list
        	(identifier) ="fig"
            (identifier) ="ax"
        )
        right: (call
        	function: (attribute
            	(identifier) ="plt"
                (identifier) ="subplots"
            )
        )
    ) @init' sample: 'fig, ax = plt.subplots()'>
	
	^ aBlock value: (aDictionary at: 'init') value: (self new
		factory: (aDictionary at: 'init') factory;
		createReplacement)
]

{ #category : #'initialize-release' }
SBPyPltInitPlots >> createReplacement [

	self addMorphBack: (SBColumn new cellGap: 2;
			addMorphBack: (SBStringMorph new contents: 'Matplotlib context:');
			addMorphBack: (SBRow new cellGap: 4;
				addMorphBack: (SBPython parseElement: 'fig');
				addMorphBack: (SBPython parseElement: 'ax')
			)
		)

]

{ #category : #'as yet unclassified' }
SBPyPltInitPlots >> palettes [

	^ {SBPyPltPaletteOverview}
]

{ #category : #'as yet unclassified' }
SBPyPltInitPlots >> type [

	^ 'assignment'
]

{ #category : #'as yet unclassified' }
SBPyPltInitPlots >> writeSourceOn: aStream indent: aNumber [

	aStream nextPutAll: ('
import matplotlib.pyplot as plt
import io
import base64
import sys

fig, ax = plt.subplots()' lines joinSeparatedBy: (String cr, (String new: aNumber withAll: Character tab))).
]
