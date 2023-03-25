Class {
	#name : #SBDictTable,
	#superclass : #SBTSReplacementBlock,
	#instVars : [
		'keyCellWidth',
		'valueCellWidth'
	],
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBDictTable >> buildCellFor: aBlock [

	^ Morph new
		color: Color transparent;
		hResizing: #rigid;
		vResizing: #spaceFill;
		changeTableLayout;
		layoutInset: 2;
		borderStyle: (BorderStyle width: 1 sbScaled);
		addMorphBack: (aBlock
			hResizing: #spaceFill;
			wrapDirection: #leftToRight)
]

{ #category : #'as yet unclassified' }
SBDictTable >> buildPython [
	<lang: #python match: '(dictionary) @root' sample: '{''a'': 2, ''b'': 3}'>

	self changeTableLayout.
	self resize.
	self hResizing: #rigid.
	self wrapDirection: #leftToRight.
	self cellGap: 0.
	self layoutInset: 0.
	
	(bindings at: 'root') childSandblocks collect: [:pair | | key value |
		value := pair childSandblocks second.
		key := pair childSandblocks first.
		self addMorphBack: ((self buildCellFor: (self bindBlock: key)) width: self keyCellWidth).
		self addMorphBack: ((self buildCellFor: (self bindBlock: value)) width: self valueCellWidth)]
]

{ #category : #'as yet unclassified' }
SBDictTable >> initialize [

	super initialize.
	
	keyCellWidth := 100.
	valueCellWidth := 300
]

{ #category : #'as yet unclassified' }
SBDictTable >> keyCellWidth [

	^ keyCellWidth
]

{ #category : #'as yet unclassified' }
SBDictTable >> keyCellWidth: aNumber [

	keyCellWidth := aNumber.
	
	self submorphs pairsDo: [:key :value | key width: aNumber].
	self resize
]

{ #category : #'as yet unclassified' }
SBDictTable >> resize [

	^ self width: self keyCellWidth + self valueCellWidth + 4
]

{ #category : #'as yet unclassified' }
SBDictTable >> valueCellWidth [

	^ valueCellWidth
]

{ #category : #'as yet unclassified' }
SBDictTable >> valueCellWidth: aNumber [

	valueCellWidth := aNumber.
	
	self submorphs pairsDo: [:key :value | value width: aNumber].
	self resize
]
