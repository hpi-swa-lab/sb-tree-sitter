"
Ready to use snippets for matplotlib.
"
Class {
	#name : #SBPyPltPaletteSnippets,
	#superclass : #SBPyPalette,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltPaletteSnippets class >> buildOn: aBuilder [
	
	aBuilder addSectionHeader: 'Ready-to-use Snippets'.
	
	aBuilder content addMorphBack: (self asSubSectionText: 'Create a scatter plot with a legend using a labelled numpy dataset').
	aBuilder content addMorphBack: ((SBPyPltImage snippetScatter form scaledIntoFormOfSize: 160@100) asMorph).
	aBuilder addMorphBack: (SBRow new
		addMorphBack: (SBCheckbox new value: true; nonEdit: true);
		addMorphBack: (SBButton new active: false; label: 'numpy' shortcut: nil do: []);
		addMorphBack: (SBCheckbox new value: true; nonEdit: true);
		addMorphBack: (SBButton new active: false; label: 'scatter' shortcut: nil do: [])
	 ).
	aBuilder addMorphBack: (SBRow new
		addMorphBack: (SBCheckbox new value: true; nonEdit: true);
		addMorphBack: (SBButton new active: false; label: 'legend' shortcut: nil do: []);
		addMorphBack: (SBCheckbox new value: false; nonEdit: true);
		addMorphBack: (SBButton new active: false; label: 'histogram' shortcut: nil do: [])
	).
	"
	aBuilder addMorphBack: (aBuilder container: ((SBPython parseAndReplace: '
def scatter():
    import numpy as np
    # data is a numpy array of shape (n, 3)
    labels = np.unique(data[:, 2])
    fig, ax = plt.subplots()
    for label in labels:
        ax.scatter(data[data[:, 2] == label, 0],
                   data[data[:, 2] == label, 1], label=label)
') width: 400) label: 'Create a scatter plot with a legend using a labelled numpy dataset').
"
	aBuilder addBlock: 'Create a scatter plot with a legend using a labelled numpy dataset' as: (SBPython parseAndReplace: '
def scatter():
	import numpy as np
	# data is a numpy array of shape (n, 3)
	labels = np.unique(data[:, 2])
	fig, ax = plt.subplots()
	for label in labels:
		ax.scatter(data[data[:, 2] == label, 0], data[data[:, 2] == label, 1], label=label)
').
	aBuilder addMorphBack: (SBDivider new width: 200)
]
