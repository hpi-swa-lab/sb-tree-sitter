Class {
	#name : #SBVisExample,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-TreeSitter-Replacements'
}

{ #category : #'as yet unclassified' }
SBVisExample >> build [
	<lang: #typescript match: '(call_expression (arguments . (expression) @render (string (string_fragment) @color)))' sample: 'visualize(random_points(), "red")' keyword: 'visualize'>

	self layoutInset: 4.
	self addMorphBack: (self createBindingBlock: 'render').
	self addMorphBack: (Morph new color: (self createStatic: [:color | Color fromCSS2String: color] contents: 'color'))
]
