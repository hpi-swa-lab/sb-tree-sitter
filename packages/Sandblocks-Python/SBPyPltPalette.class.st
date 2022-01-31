"
This is the entry palette for matplotlib.
"
Class {
	#name : #SBPyPltPalette,
	#superclass : #SBPyPalette,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltPalette class >> buildOn: aBuilder [
	aBuilder addSectionHeader: 'Plots'.
	aBuilder addBlock: 'Create plot with evenly spaced x axis' as: (SBPython parseAndReplace: 'ax.plot(X)').
	aBuilder addBlock: 'Create plots' as: (SBPython parseAndReplace: 'ax.plot(X, Y)').
	
	aBuilder addSectionHeader: 'Axis Customization'.
	aBuilder addBlock: 'Add title to plot' as: (SBPython parseAndReplace: 'ax.set_title("plot title")').
	aBuilder addBlock: 'Show legend. The legend entries consist of the labels of each plot' as: (SBPyPltLegend new factory: (SBPython instance); createReplacement).
	aBuilder addBlock: 'Set the label for the x axis' as: (SBPython parseAndReplace: 'ax.set_xlabel("label")').
	aBuilder addBlock: 'Set the label for the y axis' as: (SBPython parseAndReplace: 'ax.set_ylabel("label")').
	aBuilder addBlock: 'Set the x axis view limits (min, max).' as: (SBPython parseAndReplace: 'ax.set_xlim(0, 100)').
	aBuilder addBlock: 'Set the y axis view limits (min, max).' as: (SBPython parseAndReplace: 'ax.set_ylim(0, 100)').
	aBuilder addBlock: 'Set the x axis scale.' as: (SBPython parseAndReplace: 'ax.set_xscale("log")').
	aBuilder addBlock: 'Set the y axis scale.' as: (SBPython parseAndReplace: 'ax.set_yscale("log")').
]
