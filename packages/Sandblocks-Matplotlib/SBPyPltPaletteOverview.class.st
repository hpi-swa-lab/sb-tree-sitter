"
Palette showing matplotlib plots and other axes calls.
"
Class {
	#name : #SBPyPltPaletteOverview,
	#superclass : #SBPyPalette,
	#category : #'Sandblocks-Matplotlib'
}

{ #category : #'as yet unclassified' }
SBPyPltPaletteOverview class >> buildOn: aBuilder [

	SBPyPltPaletteEntry buildOn: aBuilder.
	
	self buildOnPlots: aBuilder.
	self buildOnAxisCustomization: aBuilder.
	
	SBPyPltPaletteSnippets buildOn: aBuilder
]

{ #category : #'as yet unclassified' }
SBPyPltPaletteOverview class >> buildOnAxisCustomization: aBuilder [

	aBuilder addSectionHeader: 'Axis Customization'.
	aBuilder content addMorphBack: (self asSubSectionText: 'Customize the appearance of the axes. Axes is the area enclosed by its x- and y-axis (and possibly z-axis).').
	
	aBuilder
		addBlock: 'Add title to plot'
		as: (SBPython parseExpression: 'ax.set_title("plot title")') applyReplacement.
	aBuilder
		addBlock: 'Show legend. The legend entries consist of the labels of each plot'
		as: (SBPython parseExpression: 'ax.legend()') applyReplacement.
	aBuilder
		addBlock: 'Set the label for the x axis'
		as: (SBPython parseExpression: 'ax.set_xlabel("label")') applyReplacement.
	aBuilder
		addBlock: 'Set the label for the y axis'
		as: (SBPython parseExpression: 'ax.set_ylabel("label")') applyReplacement.
	aBuilder
		addBlock: 'Set the x axis view limits (min, max).'
		as: (SBPython parseExpression: 'ax.set_xlim(0, 100)') applyReplacement.
	aBuilder
		addBlock: 'Set the y axis view limits (min, max).'
		as: (SBPython parseExpression: 'ax.set_ylim(0, 100)') applyReplacement.
	aBuilder
		addBlock: 'Set the x axis scale.'
		as: (SBPython parseExpression: 'ax.set_xscale("log")') applyReplacement.
	aBuilder
		addBlock: 'Set the y axis scale.'
		as: (SBPython parseExpression: 'ax.set_yscale("log")') applyReplacement
]

{ #category : #'as yet unclassified' }
SBPyPltPaletteOverview class >> buildOnPlots: aBuilder [

	aBuilder addSectionHeader: 'Plots'.
	aBuilder content addMorphBack: (self asSubSectionText: 'Plot y versus x as lines and/or markers.').
	
	SBToggledCode comment: '' active: 0 do: {
		[
			aBuilder
				addBlock: 'Create plot with evenly spaced x axis'
				as: (SBPython parseExpression: 'ax.plot(Y)') applyReplacement]}.
	SBToggledCode comment: '' active: 0 do: {
		[
			aBuilder
				addBlock: 'Create plots'
				as: (SBPython parseExpression: 'ax.plot(X, Y)') applyReplacement]}.
	
	aBuilder content addMorphBack: (self asSubSectionText: 'A scatter plot of y vs. x with varying marker size and/or color.').
	aBuilder
		addBlock: 'Create scatter plot with x,y points'
		as: (SBPython parseExpression: 'ax.scatter(X, Y)') applyReplacement.
	aBuilder
		addBlock: 'Create scatter plot with specified sizes'
		as: (SBPython parseExpression: 'ax.scatter(X, Y, sizes)') applyReplacement.
	aBuilder
		addBlock: 'Create scatter plot with specified sizes and colors'
		as: (SBPython parseExpression: 'ax.scatter(X, Y, sizes, colors)') applyReplacement.
	
	aBuilder addMorphBack: (self asSubSectionText: 'Draw a vertical line between [ymin, ymax]').
	aBuilder
		addBlock: 'Draw a vertical line'
		as: (SBPython parseExpression: 'ax.axvline(x, ymin=0, ymax=1)') applyReplacement
]

{ #category : #'as yet unclassified' }
SBPyPltPaletteOverview class >> language [

	^ SBPython
]
