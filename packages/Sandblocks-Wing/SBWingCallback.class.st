Class {
	#name : #SBWingCallback,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Wing'
}

{ #category : #'as yet unclassified' }
SBWingCallback >> build [
	<lang: #wing match: '(structured_access_expression
	(array_literal .
		(_) @expression
		(string) ="post"
		(string) @route .))' sample: '[httpPost(), "post", "/video"][0]'>

	self layoutPolicy: SBAlgebraLayout new.
	self layoutInset: 8.
	self addMorphBack: (self createBindingBlock: 'expression').
	self addMorphBack: (SBRow new
		useAlgebraLayout;
		addMorphBack: SBIcon iconArrowRight;
		addMorphBack: (self createBinding: [SBTextBubble new prefix: 'Callback: '] contents: 'route'))
]

{ #category : #'as yet unclassified' }
SBWingCallback >> layoutCommands [

	^ SBAlgebraCommand container
		data: (self submorphs
			collect: [:s | s layoutCommands]
			separatedBy: [SBAlgebraCommand hardLine withGap: true]);
		morph: self
]
