Class {
	#name : #SBMapList,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBMapList >> buildPython [
	<lang: #python match: '(call function: (identifier) ="list" (argument_list
	(call function: (identifier) ="map" (argument_list
		(lambda (lambda_parameters (identifier) @iterator) (_) @body)
		(_) @list))))' sample: 'list(map(lambda src: src["a"], l))'>

	
	self
		useAlgebraLayout;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		addMorphBack: (SBStringMorph new contents: 'for each ');
		addMorphBack: (self createBindingBlock: 'list');
		addMorphBack: (SBStringMorph new contents: ' as ');
		addMorphBack: (self createBindingBlock: 'iterator');
		addMorphBack: (SBStringMorph new contents: ': ');
		addMorphBack: (self createBindingBlock: 'body')
]

{ #category : #'as yet unclassified' }
SBMapList >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: ((self submorphs viewFrom: 1 to: 5) collect: #layoutCommands), {SBAlgebraCommand indent data: {SBAlgebraCommand softLine. (self submorphs at: 6) layoutCommands}}
]
