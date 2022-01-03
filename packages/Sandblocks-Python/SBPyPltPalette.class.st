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
	aBuilder addBlock: 'Create plot with evenly spaced y axis' as: (SBPython parseAndReplace: 'ax.plot(X)') childSandblocks first.
	aBuilder addBlock: 'Create plots' as: (SBPython parseElement: 'ax.plot(X, Y)').
]

{ #category : #'as yet unclassified' }
SBPyPltPalette class >> context [

	^ super context, { [:aBlock | aBlock relatedClass canUnderstand: #isAxes]. #isAxes}
]

{ #category : #'as yet unclassified' }
SBPyPltPalette class >> language [

	^#python
]
