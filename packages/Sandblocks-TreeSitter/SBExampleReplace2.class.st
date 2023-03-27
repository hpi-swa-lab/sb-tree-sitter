Class {
	#name : #SBExampleReplace2,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-TreeSitter-Replacements'
}

{ #category : #'as yet unclassified' }
SBExampleReplace2 >> buildPython [
	<lang: #python match: '(subscript (dictionary (pair key: (string) ="with" (lambda (_) @replace)) (pair key: (string) ="_sb_replace" (string) (lambda (_) @original))))' sample: '{"_sb_replace": lambda: "a", "with": lambda: [1, 2]}["with"]'>

	self
		layoutInset: 8;
		layoutPolicy: SBAlgebraLayout new;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap.
	
	self
		removeAllMorphs;
		addMorphBack: (SBStringMorph new contents: 'Original:');
		addMorphBack: (self createBindingBlock: 'original');
		addMorphBack: (SBStringMorph new contents: 'Replace:');
		addMorphBack: (self createBindingBlock: 'replace')
]

{ #category : #'as yet unclassified' }
SBExampleReplace2 >> drawnColor [

	^ Color veryDarkGray
]

{ #category : #'as yet unclassified' }
SBExampleReplace2 >> layoutCommands [

	^ SBAlgebraCommand container
		data: {
			(self submorphs at: 1) layoutCommands.
			SBAlgebraCommand gap.
			(self submorphs at: 2) layoutCommands.
			SBAlgebraCommand hardLine withGap: true.
			(self submorphs at: 3) layoutCommands.
			SBAlgebraCommand gap.
			(self submorphs at: 4) layoutCommands};
		morph: self
]
