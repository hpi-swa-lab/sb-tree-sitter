"
Ready to use snippets for matplotlib.
"
Class {
	#name : #SBPyPltPaletteSnippets,
	#superclass : #SBPyPalette,
	#category : #'Sandblocks-Matplotlib'
}

{ #category : #'as yet unclassified' }
SBPyPltPaletteSnippets class >> buildOn: aBuilder [

	aBuilder addSectionHeader: 'Ready-to-use Snippets'.
	aBuilder addMorphBack: (SBRow new
		addMorphBack: (SBCheckbox new
			value: true;
			nonEdit: true);
		addMorphBack: (SBButton new
			active: false;
			label: 'numpy' shortcut: nil do: []);
		addMorphBack: (SBCheckbox new
			value: true;
			nonEdit: true);
		addMorphBack: (SBButton new
			active: false;
			label: 'scatter' shortcut: nil do: [])).
	aBuilder addMorphBack: (SBRow new
		addMorphBack: (SBCheckbox new
			value: true;
			nonEdit: true);
		addMorphBack: (SBButton new
			active: false;
			label: 'legend' shortcut: nil do: []);
		addMorphBack: (SBCheckbox new
			value: false;
			nonEdit: true);
		addMorphBack: (SBButton new
			active: false;
			label: 'histogram' shortcut: nil do: [])).
	
	aBuilder addSubSectionHeader: 'Scatter with legend and numpy'.
	aBuilder content addMorphBack: (SBPyPltImage snippetScatter form scaledIntoFormOfSize: 160 @ 100) asMorph.
	
	aBuilder
		addBlock: 'Create a scatter plot with a legend using a labelled numpy dataset'
		as: ((SBPython parseStatement: '
def scatter(ax, data: np.ndarray):
	# data is a numpy array of shape (n, 3)
	assert(data.shape[1] == 3)
	labels = np.unique(data[:, 2])
	for label in labels:
		ax.scatter(data[data[:, 2] == label, 0], data[data[:, 2] == label, 1], 1, label=label)
	ax.legend()
') in: [:module | self collapse: module withSignature: 'scatter(ax, data)']).
	
	aBuilder addMorphBack: self divider.
	
	aBuilder addSubSectionHeader: 'Fill Between'.
	aBuilder content addMorphBack: (SBPyPltImage snippetFilledArea form scaledIntoFormOfSize: 160 @ 100) asMorph.
	aBuilder
		addBlock: 'Create a line plot with a fill between the bottom and the y values'
		as: ((SBPython parseStatement: '
def fillbetween(ax, x, y, y_min):
	ax.plot(x, y, lw=2)
	ax.fill_between(x, y_min, y, alpha=0.7)
	ax.grid(True)
	ax.set_ylabel("price")
	for label in ax.get_yticklabels():
		label.set_visible(False)
') in: [:module | self collapse: module withSignature: 'fillbetween(ax, x, y, y_min)']).
	aBuilder addMorphBack: self divider.
	
	aBuilder addSubSectionHeader: 'Stacked bar chart'.
	aBuilder content addMorphBack: (SBPyPltImage snippetStackedBarChart form scaledIntoFormOfSize: 160 @ 100) asMorph.
	aBuilder
		addBlock: 'This is an example of creating a stacked bar plot with error bars using bar. Note the bottom to stack the womens bars on top of the mens bars.'
		as: ((SBPython parseStatement: '
def barchart(ax, y1, y2, xlabels, width):
	ax.bar(xlabels, y1, width, label="Men")
	ax.bar(xlabels, y2, width, bottom=y1, label="Women")

	ax.set_ylabel("Scores")
	ax.set_title("Scores by group and gender")
	ax.legend()

	plt.show()
') in: [:module | self collapse: module withSignature: 'barchart(ax, y1, y2, xlabels, bar_width)'])
]
