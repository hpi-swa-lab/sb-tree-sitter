Class {
	#name : #SBGDFunctionDefinition,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-GDScript'
}

{ #category : #'as yet unclassified' }
SBGDFunctionDefinition >> build [
	<lang: #gdscript match: '(function_definition (name) @name (parameters) @params (body) @body)' sample: 'func a(b, c):
	pass'>

	self
		layoutPolicy: SBAlgebraLayout new;
		addMorphBack: (SBRow new
			layoutInset: 8 sbScaled;
			useAlgebraLayout;
			cornerRadius: 5 sbScaled;
			cornerStyle: #rounded;
			color: (Color r: 1 g: 0.0 b: 0.0) muchLighter;
			addMorphBack: SBIcon iconSend;
			addMorphBack: (self createBindingBlock: 'name');
			addMorphBack: (self createBindingBlock: 'params'));
		addMorphBack: (self createBindingBlock: 'body')
]

{ #category : #'as yet unclassified' }
SBGDFunctionDefinition >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: {
			self firstSubmorph layoutCommands.
			SBAlgebraCommand indent data: {SBAlgebraCommand hardLine withGap: true. self lastSubmorph layoutCommands}}
]
