"
Base class for all python palettes. Palettes are referenced by the static 'palettes' selector.
"
Class {
	#name : #SBPyPalette,
	#superclass : #SBTSPalette,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPalette class >> asSubSectionText: aString [
	^ SBMultilineOwnTextMorph new
			contents: (aString asText addAttribute: (TextFontChange fontNumber: 1));
			maxWidth: 150;
			yourself
]

{ #category : #'as yet unclassified' }
SBPyPalette class >> buildOn: aBuilder [

	aBuilder addSectionHeader: 'Python'.
	aBuilder addBlock: 'Open' as: (SBPython parse: 'open("")').
	aBuilder addBlock: 'Path' as: (SBPyFilepath new
		factory: SBPython new;
		path: '').
]

{ #category : #'as yet unclassified' }
SBPyPalette class >> buildOnLine2d: aBuilder [
"Palette for matplotlib Line2D properties, which are used e.g. by the args of SBPyPalettePlot (ax.plot()), SBPyPaletteAxvline (ax.axvline())"

	aBuilder addBlock: 'Set the alpha value used for blending - not supported on all backends.' as: 
		(SBPython parseKeywordArgument: 'alpha=0.5').
		
	aBuilder addBlock: 'Set the color.' as:
		(SBPython parseKeywordArgument: 'color="blue"').
		
	aBuilder addBlock: 'Set a label that will be displayed in the legend.' as:
		(SBPython parseKeywordArgument: 'label="shown in legend"').

	aBuilder addSubSectionHeader: 'Line-specific'.
	
	aBuilder addBlock: 'How to draw the end caps if the line is is_dashed.' as:
		(SBPython parseKeywordArgument: 'dash_capstyle="butt"').
		
	aBuilder addBlock: 'How to join segments of the line if it is_dashed.' as:
		(SBPython parseKeywordArgument: 'dash_joinstyle="round"').
		
	aBuilder addBlock: 'Set the dash sequence.
The dash sequence is a sequence of floats of even length describing the length of dashes and spaces in points.
For example, (5, 2, 1, 2) describes a sequence of 5 point and 1 point dashes separated by 2 point spaces.' as:
		(SBPyPltDashes new factory: SBPython instance; createReplacementFromSequence: {'3'. '1'}).
		
	aBuilder addBlock: 'Set the drawstyle of the plot.
The drawstyle determines how the points are connected.' as:
		(SBPython parseKeywordArgument: 'drawstyle="steps"').
		
	"den"
	aBuilder addBlock: 'Set the linestyle of the line.' as:
		(SBPython parseKeywordArgument: 'linestyle="-"').
		
	aBuilder addBlock: 'Set the line width in points.' as: (SBPython parseKeywordArgument: 'linewidth=2').
	
	aBuilder addBlock: 'How to draw the end caps if the line is solid (not is_dashed).' as:
		(SBPython parseKeywordArgument: 'solid_capstyle="butt"').
		
	aBuilder addBlock: 'How to join segments if the line is solid.' as:
		(SBPython parseKeywordArgument: 'solid_joinstyle="round"').
	
	
	
	aBuilder addSubSectionHeader: 'Marker'.
	aBuilder content addMorphBack: (SBRow new
		addMorphBack: (SBMultilineOwnTextMorph new
			contents: ( 'Customize the markers for the data points.' asText 
				addAttribute: (TextFontChange fontNumber: 1));
			maxWidth: 90;
			yourself);
		addMorphBack: ((SBPyPltImage markersExplanation form scaledIntoFormOfSize: 60@60) asMorph)
	).
	
	aBuilder addBlock: 'Set the line marker.' as:
		(SBPython parseKeywordArgument: 'marker="red"').
		
	aBuilder addBlock: 'Set the marker edge color.' as:
		(SBPython parseKeywordArgument: 'markeredgecolor="red"').
		
	aBuilder addBlock: 'Set the marker edge width in points.' as:
		(SBPython parseKeywordArgument: 'markeredgewidth=1.5').
		
	aBuilder addBlock: 'Set the marker edge width in points.' as:
		(SBPython parseKeywordArgument: 'markerfacecolor="green"').
		
	aBuilder addBlock: 'Set the alternate marker face color.' as:
		(SBPython parseKeywordArgument: 'markerfacecoloralt="yellow"').
		
	aBuilder addBlock: 'Set the marker size in points.' as:
		(SBPython parseKeywordArgument: 'markersize=2').
		
	aBuilder addBlock: 'Set the marker fill style.' as:
		(SBPython parseKeywordArgument: 'fillstyle="full"').

	aBuilder addBlock: 'Set the markevery property to subsample the plot when using markers. Note: Setting markevery will still only draw markers at actual data points. While the float argument form aims for uniform visual spacing, it has to coerce from the ideal spacing to the nearest available data point. Depending on the number and distribution of data points, the result may still not look evenly spaced.

When using a start offset to specify the first marker, the offset will be from the first data point which may be different from the first the visible data point if the plot is zoomed in.

If zooming in on a plot when using float arguments then the actual data points that have markers will change because the distance between markers is always determined from the display-coordinates axes-bounding-box-diagonal regardless of the actual axes data limits.' as:
		(SBPython parseKeywordArgument: 'markevery=5').
		
	
	
	aBuilder addSubSectionHeader: 'Clipping'.
	
	aBuilder addBlock: 'Set the artists clip Bbox.' as:
		(SBPython parseKeywordArgument: 'clip_box=Bbox([[1, 1], [3, 7]])').
		
	aBuilder addBlock: 'Set the artists clip Bbox.' as:
		(SBPython parseKeywordArgument: 'clip_on=False').
	
	aBuilder addBlock: 'Set the artists clip path.' as:
		(SBPython parseKeywordArgument: 'clip_path=Center(0,0, radius=15)').
	
	
	
	aBuilder addSubSectionHeader: 'Misc'.
		
	aBuilder addBlock: '(2, N) array or two 1D arrays.' as: (SBPython parseKeywordArgument: 'data=obj').
		
	aBuilder addBlock: 'Set the Figure instance the artist belongs to. A figure is the top level container for all the plot elements.
The Figure instance supports callbacks through a callbacks attribute which is a CallbackRegistry instance. The events you can connect to are "dpi_changed", and the callback will be called with func(fig) where fig is the Figure instance.' as:
		(SBPython parseKeywordArgument: 'figure=plt.figure()').
		
	aBuilder addBlock: 'Set the (group) id for the artist.' as: (SBPython parseKeywordArgument: 'gid="group1"').
		
	aBuilder addBlock: 'Set if artist is to be included in layout calculations, E.g. Constrained Layout Guide, Figure.tight_layout(), and fig.savefig(fname, bbox_inches="tight").' as:
		(SBPython parseKeywordArgument: 'in_layout=False').
	
	aBuilder addBlock: 'a filter function, which takes a (m, n, 3) float array and a dpi value, and returns a (m, n, 3) array' as:
		(SBPython parseKeywordArgument: 'agg_filter=(m, n, 3)').
		
	aBuilder addBlock: 'Set whether the artist is intended to be used in an animation.
If True, the artist is excluded from regular drawing of the figure. You have to call Figure.draw_artist / Axes.draw_artist explicitly on the artist. This appoach is used to speed up animations using blitting.' as:
		(SBPython parseKeywordArgument: 'animated=True').
		
	aBuilder addBlock: 'Set whether to use antialiased rendering.' as:
		(SBPython parseKeywordArgument: 'antialiased=True').
		
	aBuilder addBlock: 'Set the path effects.' as:
		(SBPython parseKeywordArgument: 'path_effects=[path_effects.withSimplePatchShadow()]').
		
	aBuilder addBlock: 'Set the event picker details for the line. If a float, it is used as the pick radius in points.' as:
		(SBPython parseKeywordArgument: 'picker=6').
		
	aBuilder addBlock: 'Set the pick radius used for containment tests.' as:
		(SBPython parseKeywordArgument: 'pickradius=6').
		
	aBuilder addBlock: 'Force rasterized (bitmap) drawing for vector graphics output.
Rasterized drawing is not supported by all artists. If you try to enable this on an artist that does not support it, the command has no effect and a warning will be issued.
This setting is ignored for pixel-based output.' as:
		(SBPython parseKeywordArgument: 'rasterized=True').
		
	aBuilder addBlock: 'Set the sketch parameters.' as:
		(SBPython parseKeywordArgument: 'sketch_params=(2, 128, 16)').
		
	aBuilder addBlock: 'Set the snapping behavior.
Snapping aligns positions with the pixel grid, which results in clearer images. For example, if a black line of 1px width was defined at a position in between two pixels, the resulting image would contain the interpolated value of that line in the pixel grid, which would be a grey value on both adjacent pixel positions. In contrast, snapping will move the line to the nearest integer pixel value, so that the resulting image will really contain a 1px wide black line.
Snapping is currently only supported by the Agg and MacOSX backends.' as:
		(SBPython parseKeywordArgument: 'snap=True').
		
	aBuilder addBlock: 'Set the artist transform.' as:
		(SBPython parseKeywordArgument: 'transform=Affine2D.from_values(1,0,1,0)').
		
	aBuilder addBlock: 'Set the url for the artist.' as:
		(SBPython parseKeywordArgument: 'url=urlOfArtist').
		
	aBuilder addBlock: 'Set the artists visibility.' as:
		(SBPython parseKeywordArgument: 'visible=False').
		
	aBuilder addBlock: 'Set the data array for x.' as:
		(SBPython parseKeywordArgument: 'xdata=[0, 1, 2, 3]').
		
	aBuilder addBlock: 'Set the data array for y.' as:
		(SBPython parseKeywordArgument: 'ydata=[0, 1, 2, 3]').
		
	aBuilder addBlock: 'Set the zorder for the artist. Artists with lower zorder values are drawn first.' as:
		(SBPython parseKeywordArgument: 'zorder=99').
]

{ #category : #'as yet unclassified' }
SBPyPalette class >> collapse: aSBInlineBlock withSignature: aString [
"collapses the first statement of aSBInlineBlock and returns aSBInlineBlock"
	aSBInlineBlock access children first collapseBlock.
	aSBInlineBlock access children first submorphs first contents: 'def'.
	aSBInlineBlock access children first submorphs second contents: aString.
	^ aSBInlineBlock

]

{ #category : #'as yet unclassified' }
SBPyPalette class >> divider [
	^ (SBColumn new 
	layoutInset: (SBEdgeInsets left: 0 right: 0 top: 8 bottom: 8); 
	addMorphBack: (SBDivider new width: 200))
]
