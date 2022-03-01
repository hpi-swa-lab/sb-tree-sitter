"
Replacement for ax.axvline
"
Class {
	#name : #SBPyPltAxvline,
	#superclass : #SBPyPltPlots,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltAxvline class >> match: aDictionary do: aBlock [
	<lang: #python match: '(call
        	function: (attribute
            	object: (identifier) ="ax" @ax
                attribute: (identifier) ="axvline" @plot
            )
        	arguments: (argument_list)
        ) @call' sample: 'ax.axvline(Y)'>
	
	^ aBlock
		value: (aDictionary at: 'call')
		value: (self new factory: (aDictionary at: 'call') factory;
			createReplacementOfArgs: (aDictionary at: 'call') access arguments buildCopy)
]

{ #category : #'initialize-release' }
SBPyPltAxvline >> createReplacementOfArgs: aSBTSFieldAccessor [
		
	self addMorphBack: (SBRow new
		addMorphBack: (AlignmentMorph newColumn 
			color: Color transparent; 
			hResizing: #shrinkWrap; 
			addMorphBack: (AlignmentMorph newSpacer: Color transparent);
			addMorphBack: (SBStringMorph new contents: 'vertical line:');
			addMorphBack: (SBPyPltImage axvline);
			addMorphBack: (AlignmentMorph newSpacer: Color transparent)
		 );
		addMorphBack: aSBTSFieldAccessor;
		cellGap: 4
	)
]

{ #category : #classification }
SBPyPltAxvline >> palettes [

	^ {SBPyPltPaletteAxvline}, super palettes
]

{ #category : #copying }
SBPyPltAxvline >> writeSourceOn: aStream [

	aStream nextPutAll: 'ax.axvline'.
	(self firstSubmorph submorphs asOrderedCollection second) writeSourceOn: aStream.
]
