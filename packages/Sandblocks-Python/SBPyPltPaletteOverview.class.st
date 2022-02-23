"
Palette showing basic matplotlib plots (plot, hist, scatter) and axis customizations.
"
Class {
	#name : #SBPyPltPaletteOverview,
	#superclass : #SBPyPalette,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltPaletteOverview class >> buildOn: aBuilder [
	
	SBPyPltPaletteEntry buildOn: aBuilder.
	
	self buildOnPlots: aBuilder.
	self buildOnAxisCustomization: aBuilder.
	
	SBPyPltPaletteSnippets buildOn: aBuilder.
]

{ #category : #'as yet unclassified' }
SBPyPltPaletteOverview class >> buildOnAxisCustomization: aBuilder [
	aBuilder addSectionHeader: 'Axes Customization'.
	aBuilder content addMorphBack: (self asSubSectionText: 'Customize the appearance of the axes. Axes is the area enclosed by its x- and y-axis (and possibly z-axis).').
	
	aBuilder addBlock: 'Add title to plot' as: (SBPython parseAndReplace: 'ax.set_title("plot title")').
	aBuilder addBlock: 'Show legend. The legend entries consist of the labels of each plot' as: (SBPyPltLegend new factory: (SBPython instance); createReplacement).
	aBuilder addBlock: 'Set the label for the x axis' as: (SBPython parseAndReplace: 'ax.set_xlabel("label")').
	aBuilder addBlock: 'Set the label for the y axis' as: (SBPython parseAndReplace: 'ax.set_ylabel("label")').
	aBuilder addBlock: 'Set the x axis view limits (min, max).' as: (SBPython parseAndReplace: 'ax.set_xlim(0, 100)').
	aBuilder addBlock: 'Set the y axis view limits (min, max).' as: (SBPython parseAndReplace: 'ax.set_ylim(0, 100)').
	aBuilder addBlock: 'Set the x axis scale.' as: (SBPython parseAndReplace: 'ax.set_xscale("log")').
	aBuilder addBlock: 'Set the y axis scale.' as: (SBPython parseAndReplace: 'ax.set_yscale("log")').
]

{ #category : #'as yet unclassified' }
SBPyPltPaletteOverview class >> buildOnPlots: aBuilder [

	| manyArgumentsScatter |
	aBuilder addSectionHeader: 'Plots'.
	aBuilder content addMorphBack: (self asSubSectionText: 'Plot y versus x as lines and/or markers.').
			
	aBuilder addBlock: 'Create plot with evenly spaced x axis' as: (SBPython parseAndReplace: 'ax.plot(Y)').
	aBuilder addBlock: 'Create plots' as: (SBPython parseAndReplace: 'ax.plot(X, Y)').
	
	aBuilder content addMorphBack: (self asSubSectionText: 'A scatter plot of y vs. x with varying marker size and/or color.').
	aBuilder addBlock: 'Create scatter plot with x,y points' as: (SBPython parseAndReplace: 'ax.scatter(X, Y)').
	aBuilder addBlock: 'Create scatter plot with specified sizes' as: (SBPython parseAndReplace: 'ax.scatter(X, Y, sizes)').
	manyArgumentsScatter := (SBPython parseAndReplace: 'ax.scatter(X, Y, sizes, colors)').
	"access last colors argument"
	manyArgumentsScatter childSandblocks first childSandblocks first childSandblocks last balloonText: 'doesnt work'.
	
	aBuilder addBlock: 'Create scatter plot with specified sizes and colors' as: manyArgumentsScatter.
	
	aBuilder addMorphBack: (self asSubSectionText: 'Draw a vertical line between [ymin, ymax]').
	aBuilder addBlock: 'Draw a vertical line' as: (SBPython parseAndReplace: 'ax.axvline(x, ymin=0, ymax=1)').
]

{ #category : #'as yet unclassified' }
SBPyPltPaletteOverview class >> language [

	^ #python
]
