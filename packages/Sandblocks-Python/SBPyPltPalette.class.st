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
	aBuilder addBlock: 'Create plot with evenly spaced x axis' as: (SBPython parseAndReplace: 'ax.plot(X)') childSandblocks first.
	aBuilder addBlock: 'Create plots' as: (SBPython parseAndReplace: 'ax.plot(X, Y)') childSandblocks first.
	
	aBuilder addSectionHeader: 'Axis Customization'.
	aBuilder addBlock: 'Set the label for the specified axis' as: (SBPython parseAndReplace: 'ax.set_xlabel("label")') childSandblocks first.
	aBuilder addBlock: 'Set the axis view limits (min, max).' as: (SBPython parseAndReplace: 'ax.set_ylim(0, 100)') childSandblocks first.
	aBuilder addBlock: 'Set the axis scale.' as: (SBPython parseAndReplace: 'ax.set_yscale("log")') childSandblocks first.
]
