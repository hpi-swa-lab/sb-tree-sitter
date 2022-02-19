"
Palette for the arguments of SBPyPltScatter, the replacement for scatter().
"
Class {
	#name : #SBPyPltPaletteScatter,
	#superclass : #SBPyPalette,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltPaletteScatter class >> buildOn: aBuilder [
	aBuilder addSectionHeader: 'Scatter Parameter'.
	
	aBuilder addBlock: 'Set the alpha value used for blending - not supported on all backends.' as: 
		(SBPyPltAlpha new factory: SBPython instance; createReplacement: '0.5').
		
	aBuilder addBlock: 'Set a label that will be displayed in the legend.' as:
		(SBPyPltLabel new factory: SBPython instance; createReplacement: 'obj').
		
	aBuilder addBlock: 'A Colormap instance or registered colormap name. cmap is only used if c is an array of floats.' as:
		(SBPython parseKeywordArgument: 'cmap=colormap').

	aBuilder addBlock: 'If c is an array of floats, norm is used to scale the color data, c, in the range 0 to 1, in order to map into the colormap cmap. If None, use the default colors.Normalize.' as:
		(SBPython parseKeywordArgument: 'norm=True').

	
	aBuilder addSubSectionHeader: 'Line-specific'.
	
	aBuilder addBlock: 'Set the linestyle of the line.' as:
		(SBPython parseKeywordArgument: 'linestyle="-"').
		
	aBuilder addBlock: 'Set the line width in points.' as:
		(SBPyPltLinewidth new factory: SBPython instance; createReplacement: '2.0').
			
	
	aBuilder addSubSectionHeader: 'Marker'.
	
	aBuilder addBlock: 'Set the marker.' as:
		(SBPython parseKeywordArgument: 'marker="o"').
		
	aBuilder addBlock: 'Set the marker edge color.' as:
		(SBPython parseKeywordArgument: 'markeredgecolor="red"').	
	
	
	aBuilder addSubSectionHeader: 'Misc'.
		
	aBuilder addBlock: 'If given, the following parameters also accept a string s, which is interpreted as data[s] (unless this raises an exception):
x, y, s, linewidths, edgecolors, c, facecolor, facecolors, color.' as:
		(SBPyPltData new factory: SBPython instance; createReplacement: 'X').
		
	aBuilder addBlock: 'Set whether to use antialiased rendering.' as:
		(SBPython parseKeywordArgument: 'antialiased=True').
		
	aBuilder addBlock: 'Set the pick radius used for containment tests.' as:
		(SBPython parseKeywordArgument: 'pickradius=6').
		
	aBuilder addBlock: 'Set the artists visibility.' as:
		(SBPython parseKeywordArgument: 'visible=False').
		
	aBuilder addBlock: 'Set the zorder for the artist. Artists with lower zorder values are drawn first.' as:
		(SBPython parseKeywordArgument: 'zorder=99').
]
