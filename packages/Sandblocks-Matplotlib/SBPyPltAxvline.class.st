"
Replacement for ax.axvline
"
Class {
	#name : #SBPyPltAxvline,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Matplotlib'
}

{ #category : #'initialize-release' }
SBPyPltAxvline >> build [
	<lang: #python match: '(call
        	function: (attribute
            	object: (identifier) ="ax"
                attribute: (identifier) ="axvline"
            )
        	arguments: (argument_list) @args
        )' sample: 'ax.axvline(Y)'>

	self addMorphBack: (SBRow new
		addMorphBack: (SBColumn new
			hResizing: #shrinkWrap;
			cellPositioning: #center;
			layoutInset: 2;
			addMorphBack: (SBStringMorph new contents: 'vertical line:');
			addMorphBack: SBPyPltImage axvline);
		addMorphBack: (self createBindingBlock: 'args');
		cellGap: 4)
]

{ #category : #accessing }
SBPyPltAxvline >> palettes [

	^ {SBPyPltPaletteOverview. SBPyPltPaletteOverview}
]
