"
Entry point for all matplotlib related content. It imports matplotlib, so it needs to be placed before any other matplotlib content, and calls ""fig, ax = plt.subplots()"", which is used by all matplotlib replacements.  Please see the cheatsheets at https://matplotlib.org/cheatsheets/ for a quick overview of matplotlib's terminology. All replacements follow the oo interface of matplotlib besides the replacements in SBPyPltPaletteEntry. The code is broadly split into the parameters (SBPyPltParam...) of all plots (SBPyPltPlots) which are shown in palettes (SBPyPltPalette). Axis customization is organized in SBPyPltAxis.
"
Class {
	#name : #SBPyPltInitPlots,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Matplotlib'
}

{ #category : #'initialize-release' }
SBPyPltInitPlots >> build [
	<lang: #python match: '(assignment
    	left: (pattern_list
        	(identifier) ="fig" @fig
            (identifier) ="ax" @ax
        )
        right: (call
        	function: (attribute
            	(identifier) ="plt"
                (identifier) ="subplots"
            )
        )
    ) @init' sample: 'fig, ax = plt.subplots()'>

	self addMorphBack: (SBColumn new
		cellGap: 2;
		addMorphBack: (SBStringMorph new contents: 'Matplotlib context:');
		addMorphBack: (SBRow new
			cellGap: 4;
			addMorphBack: (self createBindingBlock: 'fig');
			addMorphBack: (self createBindingBlock: 'ax')))
]

{ #category : #accessing }
SBPyPltInitPlots >> palettes [

	^ {SBPyPltPaletteOverview}
]
