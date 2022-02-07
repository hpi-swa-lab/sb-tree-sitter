"
This is an alternative to SBPyPltPalettePlotExtended. It shows the documentation strings above the blocks. It opens in the context of the ""alternative"" which can be found in SBPyPalette for example.
"
Class {
	#name : #SBPyPltPalettePlotExtended,
	#superclass : #SBPyPalette,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltPalettePlotExtended class >> buildOn: aBuilder [
	aBuilder addSectionHeader: 'Plot Parameter'.
	
	aBuilder content addMorphBack: (StringMorph new contents: 'Set the alpha value used for blending - not supported on all backends.').
	aBuilder addBlock: 'Set the alpha value used for blending - not supported on all backends.' as: 
		(SBPyPltAlpha new factory: SBPython instance; createReplacement: '0.5').
		
	aBuilder content addMorphBack: (StringMorph new contents:  'Set the color.').
	aBuilder addBlock: 'Set the color.' as:
		(SBPyPltColor new factory: SBPython instance; createReplacement: 'blue').
		
		aBuilder content addMorphBack: (StringMorph new contents:   'Set a label that will be displayed in the legend.').
	aBuilder addBlock: 'Set a label that will be displayed in the legend.' as:
		(SBPyPltLabel new factory: SBPython instance; createReplacement: 'obj').

	
	
	
	aBuilder addSubSectionHeader: 'Line-specific'.

	aBuilder content addMorphBack: (StringMorph new contents:   'How to draw the end caps if the line is is_dashed.' ).	
	aBuilder addBlock: 'How to draw the end caps if the line is is_dashed.' as:
		(SBPyPltDashCapStyle new factory: SBPython instance; createReplacement: 'butt').
		
	aBuilder content addMorphBack: (StringMorph new contents:   'How to join segments of the line if it is_dashed.').
	aBuilder addBlock: 'How to join segments of the line if it is_dashed.' as:
		(SBPyPltDashJoinStyle new factory: SBPython instance; createReplacement: 'round').
		
	aBuilder content addMorphBack: (StringMorph new contents:  'Set the dash sequence.
The dash sequence is a sequence of floats of even length describing the length of dashes and spaces in points.
For example, (5, 2, 1, 2) describes a sequence of 5 point and 1 point dashes separated by 2 point spaces.').
	aBuilder addBlock: 'Set the dash sequence.
The dash sequence is a sequence of floats of even length describing the length of dashes and spaces in points.
For example, (5, 2, 1, 2) describes a sequence of 5 point and 1 point dashes separated by 2 point spaces.' as:
		(SBPyPltDashes new factory: SBPython instance; createReplacementFromSequence: {'3'. '1'}).
		
	aBuilder content addMorphBack: (StringMorph new contents:  'Set the drawstyle of the plot.
The drawstyle determines how the points are connected.' ).
	aBuilder addBlock: 'Set the drawstyle of the plot.
The drawstyle determines how the points are connected.' as:
		(SBPyPltDrawstyle new factory: SBPython instance; createReplacement: 'steps').
		
	"den"
	aBuilder content addMorphBack: (StringMorph new contents:  'Set the linestyle of the line.' ).
	aBuilder addBlock: 'Set the linestyle of the line.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'linestyle="-"').
		
	aBuilder content addMorphBack: (StringMorph new contents:   'Set the line width in points.').
	aBuilder addBlock: 'Set the line width in points.' as:
		(SBPyPltLinewidth new factory: SBPython instance; createReplacement: '2').
	
"extract CapStyle or new replacement?"
	aBuilder content addMorphBack: (StringMorph new contents:  'How to draw the end caps if the line is solid (not is_dashed).').
	aBuilder addBlock: 'How to draw the end caps if the line is solid (not is_dashed).' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'solid_capstyle="butt"').
		
"extract CapStyle or new replacement?"
	aBuilder content addMorphBack: (StringMorph new contents: 'How to join segments if the line is solid.').
	aBuilder addBlock: 'How to join segments if the line is solid.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'solid_joinstyle="round"').
	
	
	
	aBuilder addSubSectionHeader: 'Marker'.
	
	aBuilder addBlock: 'Set the line marker.' as:
		(SBPyPltMarker new factory: SBPython instance; createReplacement: 'o').
		
	aBuilder addBlock: 'Set the marker edge color.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'markeredgecolor="red"').
		
	aBuilder addBlock: 'Set the marker edge width in points.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'markeredgewidth=1.5').
		
	aBuilder addBlock: 'Set the marker edge width in points.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'markerfacecolor="green"').
		
	aBuilder addBlock: 'Set the alternate marker face color.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'markerfacecoloralt="yellow"').
		
	aBuilder addBlock: 'Set the marker size in points.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'markersize=2').
		
	"den"	
	aBuilder addBlock: 'Set the marker fill style.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'fillstyle="full"').

"den"
	aBuilder addBlock: 'Set the markevery property to subsample the plot when using markers. Note: Setting markevery will still only draw markers at actual data points. While the float argument form aims for uniform visual spacing, it has to coerce from the ideal spacing to the nearest available data point. Depending on the number and distribution of data points, the result may still not look evenly spaced.

When using a start offset to specify the first marker, the offset will be from the first data point which may be different from the first the visible data point if the plot is zoomed in.

If zooming in on a plot when using float arguments then the actual data points that have markers will change because the distance between markers is always determined from the display-coordinates axes-bounding-box-diagonal regardless of the actual axes data limits.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'markevery=5').
		
	
	
	aBuilder addSubSectionHeader: 'Clipping'.
	
	aBuilder addBlock: 'Set the artists clip Bbox.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'clip_box=Bbox([[1, 1], [3, 7]])').
		
	aBuilder addBlock: 'Set the artists clip Bbox.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'clip_on=False').
	
	aBuilder addBlock: 'Set the artists clip path.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'clip_path=Center(0,0, radius=15)').
	
	
	
	aBuilder addSubSectionHeader: 'Misc'.
		
	aBuilder addBlock: '(2, N) array or two 1D arrays.' as:
		(SBPyPltData new factory: SBPython instance; createReplacement: 'X').
		
	aBuilder addBlock: 'Set the Figure instance the artist belongs to. A figure is the top level container for all the plot elements.
The Figure instance supports callbacks through a callbacks attribute which is a CallbackRegistry instance. The events you can connect to are "dpi_changed", and the callback will be called with func(fig) where fig is the Figure instance.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'figure=plt.figure()').
		
	aBuilder addBlock: 'Set the (group) id for the artist.' as:
		(SBPyPltGid new factory: SBPython instance; createReplacement: 'group1').
		
	aBuilder addBlock: 'Set if artist is to be included in layout calculations, E.g. Constrained Layout Guide, Figure.tight_layout(), and fig.savefig(fname, bbox_inches="tight").' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'in_layout=False').
	
	aBuilder addBlock: 'a filter function, which takes a (m, n, 3) float array and a dpi value, and returns a (m, n, 3) array' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'agg_filter=(m, n, 3)').
		
	aBuilder addBlock: 'Set whether the artist is intended to be used in an animation.
If True, the artist is excluded from regular drawing of the figure. You have to call Figure.draw_artist / Axes.draw_artist explicitly on the artist. This appoach is used to speed up animations using blitting.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'animated=True').
		
	aBuilder addBlock: 'Set whether to use antialiased rendering.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'antialiased=True').
		
	aBuilder addBlock: 'Set the path effects.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'path_effects=[path_effects.withSimplePatchShadow()]').
		
	aBuilder addBlock: 'Set the event picker details for the line. If a float, it is used as the pick radius in points.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'picker=6').
		
	aBuilder addBlock: 'Set the pick radius used for containment tests.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'pickradius=6').
		
	aBuilder addBlock: 'Force rasterized (bitmap) drawing for vector graphics output.
Rasterized drawing is not supported by all artists. If you try to enable this on an artist that does not support it, the command has no effect and a warning will be issued.
This setting is ignored for pixel-based output.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'rasterized=True').
		
"den?"
	aBuilder addBlock: 'Set the sketch parameters.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'sketch_params=(2, 128, 16)').
		
	aBuilder addBlock: 'Set the snapping behavior.
Snapping aligns positions with the pixel grid, which results in clearer images. For example, if a black line of 1px width was defined at a position in between two pixels, the resulting image would contain the interpolated value of that line in the pixel grid, which would be a grey value on both adjacent pixel positions. In contrast, snapping will move the line to the nearest integer pixel value, so that the resulting image will really contain a 1px wide black line.
Snapping is currently only supported by the Agg and MacOSX backends.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'snap=True').
		
	aBuilder addBlock: 'Set the artist transform.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'transform=Affine2D.from_values(1,0,1,0)').
		
	aBuilder addBlock: 'Set the url for the artist.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'url=urlOfArtist').
		
	aBuilder addBlock: 'Set the artists visibility.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'visible=False').
		
	aBuilder addBlock: 'Set the data array for x.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'xdata=[0, 1, 2, 3]').
		
	aBuilder addBlock: 'Set the data array for y.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'ydata=[0, 1, 2, 3]').
		
	aBuilder addBlock: 'Set the zorder for the artist. Artists with lower zorder values are drawn first.' as:
		(SBPython parseAsKeywordArgumentAndReplace: 'zorder=99').
]
