Class {
	#name : #SBStColor,
	#superclass : #SBTSReplacementBlock,
	#instVars : [
		'previousColor'
	],
	#category : #'Sandblocks-TreeSitter-Replacements'
}

{ #category : #'as yet unclassified' }
SBStColor >> build [
	<lang: #smalltalk match: '[(unary_message
	(identifier) ="Color"
	(identifier) @selector)
(keyword_message
	(identifier) ="Color"
	(number) @r
	(number) @g
	(number) @b)
]@root' sample: 'a
	Color red.
	Color r: 2 g: 4 b: 6'>

	self
		layoutInset: 4;
		addMorphBack: (self
			createBinding: [:c | | blob |
				blob := Morph new extent: 16 asPoint.
				(c at: 'selector')
					ifNotNil: [:sel | blob color: (Color perform: sel contents asSymbol)]
					ifNil: [blob color: (Color r: (c at: 'r') contents asFloat g: (c at: 'g') contents asFloat b: (c at: 'b') contents asFloat)].
				blob]
			update: [:c :m |
				c
					at: 'root'
					put: ((SBTSFileParser new parse: 'a ', m color storeString language: SBTSSmalltalk) childSandblocks second slot: (c at: 'root') slot)])
]

{ #category : #'as yet unclassified' }
SBStColor >> buildPyParam [
	<lang: #python match: '(keyword_argument (identifier) ="color" (string) @color @root)' sample: 'ax.plot(color="red")'>

	self
		layoutInset: 4;
		addMorphBack: (self
			createBinding: [:c |
				Morph new
					extent: 16 asPoint;
					color: (Color fromCSS2String: (c at: 'color') contents);
					yourself]
			update: [:c :m | (c at: 'color') contents: m color asHTMLColor])
]

{ #category : #'as yet unclassified' }
SBStColor >> colorContentsUpdate: aColor [

	self firstSubmorph color: aColor.
	self batchedChangeStep
]

{ #category : #'as yet unclassified' }
SBStColor >> doubleClick: anEvent [

	previousColor := self firstSubmorph color.
	(NewColorPickerMorph
		on: self
		originalColor: self firstSubmorph color
		setColorSelector: #colorContentsUpdate:)
		openInWorld;
		bottomLeft: self positionInWorld - (30 @ 30);
		when: #closed
			send: #saveColor
			to: self
]

{ #category : #'as yet unclassified' }
SBStColor >> saveColor [

	self sandblockEditor do: (SBMutatePropertyCommand new
		target: self firstSubmorph;
		selector: #color;
		value: self firstSubmorph color;
		oldValue: previousColor)
]
