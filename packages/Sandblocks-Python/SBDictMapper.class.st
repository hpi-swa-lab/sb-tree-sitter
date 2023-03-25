Class {
	#name : #SBDictMapper,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBDictMapper >> buildPython [
	<lang: #python match: '(subscript value: (dictionary) @dict subscript: (_) @expr) @root' sample: '{''a'': 2, ''b'': 3}[''a'']'>

	| table |
	self
		listDirection: #topToBottom;
		layoutInset: 4.
	
	table := self createBindingBlock: 'dict'.
	table firstSubmorph applyReplacement valueCellWidth: 100.
	
	self
		addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: 'Given ');
			addMorphBack: (self createBindingBlock: 'expr');
			addMorphBack: (SBStringMorph new contents: ' map to ...'));
		addMorphBack: table
]
