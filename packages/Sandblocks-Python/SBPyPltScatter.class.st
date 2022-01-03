"
I am the class representing the matplotlib scatter
"
Class {
	#name : #SBPyPltScatter,
	#superclass : #SBPyPltPlots,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltScatter class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '
    	(call
        	function: (attribute
            	object: (identifier) ="ax" @ax
                	attribute: (identifier) ="scatter" @plot
            )
        	arguments: (argument_list
			(identifier) @paramX
            	(identifier) @paramY
		) @args
        ) @call' sample: 'ax.scatter(X, Y)'>
	
	(((aDictionary at: 'args') firstSubmorph submorphs size) > 2) ifTrue: [^nil].
	
	^ aBlock
		value: (aDictionary at: 'call')
		value: (self new factory: (aDictionary at: 'call') factory;
			createReplacementWithX: (aDictionary at: 'paramX') contents Y:  (aDictionary at: 'paramY') contents)
]

{ #category : #'initialize-release' }
SBPyPltScatter >> createReplacementWithX: xString Y: yString [ 

	self addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: 'scatter plot: (');
			addMorphBack: (SBTextBubble new contents: xString);
			addMorphBack: (SBStringMorph new contents: ',');
			addMorphBack: (SBTextBubble new contents: yString);
			addMorphBack: (SBStringMorph new contents: ')');
			addMorphBack: (SBPyPltImage scatterPlot);
			cellGap: 4
		).
]

{ #category : #'initialize-release' }
SBPyPltScatter >> isAxes [
	"indicates whether this replacement is to be shown in the Axes Palette"

	^ true
]

{ #category : #'as yet unclassified' }
SBPyPltScatter >> writeSourceOn: aStream [
"called when blocks are copied. It transforms the block back to source code"

	| xArg yArg |
	xArg := self submorphs first submorphs second contents.
	yArg := (self submorphs first submorphs at: 4) contents.
	
	aStream nextPutAll: 'ax.scatter('.
	aStream nextPutAll: xArg.
	aStream nextPutAll: ', '.
	aStream nextPutAll: yArg.
	aStream nextPutAll: ')'.
]
