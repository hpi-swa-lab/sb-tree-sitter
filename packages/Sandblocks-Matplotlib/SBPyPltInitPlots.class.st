"
Entry point for all matplotlib related content. It imports matplotlib, so it needs to be placed before any other matplotlib content, and calls ""fig, ax = plt.subplots()"", which is used by all matplotlib replacements.  Please see the cheatsheets at https://matplotlib.org/cheatsheets/ for a quick overview of matplotlib's terminology. All replacements follow the oo interface of matplotlib besides the replacements in SBPyPltPaletteEntry. The code is broadly split into the parameters (SBPyPltParam...) of all plots (SBPyPltPlots) which are shown in palettes (SBPyPltPalette). Axis customization is organized in SBPyPltAxis.
"
Class {
	#name : #SBPyPltInitPlots,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Matplotlib'
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

{ #category : #classification }
SBPyPltInitPlots >> palettes [

	^ {SBPyPltPaletteOverview}
]

{ #category : #classification }
SBPyPltInitPlots >> type [

	^ 'assignment'
]

{ #category : #copying }
SBPyPltInitPlots >> writeSourceOn: aStream indent: aNumber [

	aStream nextPutAll: ('
import matplotlib.pyplot as plt
import io
import base64
import sys

fig, ax = plt.subplots()
fig.set_dpi(60)
fig.set_size_inches(3, 3)' lines joinSeparatedBy: String cr, (String new: aNumber withAll: Character tab))
]
