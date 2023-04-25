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

	self
		layoutPolicy: SBAlgebraLayout new;
		addMorphBack: (SBColumn new
			hResizing: #shrinkWrap;
			cellPositioning: #center;
			layoutInset: 2;
			addMorphBack: (SBStringMorph new contents: 'vertical line:');
			addMorphBack: SBPyPltImage axvline);
		addMorphBack: (self createBindingBlock: 'args')
]

{ #category : #'as yet unclassified' }
SBPyPltAxvline >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: (self submorphs collect: #layoutCommands separatedBy: [SBAlgebraCommand softLineOrGap])
]

{ #category : #accessing }
SBPyPltAxvline >> palettes [

	^ {SBPyPltPaletteAxvline. SBPyPltPaletteOverview}, super palettes
]
