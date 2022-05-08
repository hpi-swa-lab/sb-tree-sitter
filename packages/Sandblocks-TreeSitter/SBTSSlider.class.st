Class {
	#name : #SBTSSlider,
	#superclass : #SBTSReplacementBlock,
	#instVars : [
		'value',
		'handle',
		'dragging',
		'scrubbingCommand',
		'oldCursor'
	],
	#category : #'Sandblocks-TreeSitter-Replacements'
}

{ #category : #'as yet unclassified' }
SBTSSlider >> build [

	self
		createBinding: [:c | self value: (c at: 'value') contents asNumber]
		update: [:c :m | (c at: 'value') contents: m value asString]
]

{ #category : #'as yet unclassified' }
SBTSSlider >> buildJs [
	<lang: #javascript match: '(subscript_expression (array (number) @value (string (_) ="slider")) (number) ="0")' sample: '[123, "slider"][0]'>

	self build
]

{ #category : #'as yet unclassified' }
SBTSSlider >> buildLowpass [
	<lang: #python match: '(call (identifier) ="lowpass" (argument_list (float) @root @value))' sample: 'lowpass(0.3, 4, 5)'>

	self build
]

{ #category : #'as yet unclassified' }
SBTSSlider >> buildPython [
	<lang: #python match: '(subscript (list [(float) (integer)] @value (string (string_content) ="slider")) (integer) ="0")' sample: '[0.0, "slider"][0]'>

	self build
]

{ #category : #'as yet unclassified' }
SBTSSlider >> buildSmalltalk [
	<lang: #smalltalk match: '(subscript_expression (array (number) @value (string (_) ="slider")) (number) ="0")' sample: '{0.0. #slider}'>

	self build
]

{ #category : #'as yet unclassified' }
SBTSSlider >> drawOn: aCanvas [

	| y |
	y := self center y.
	aCanvas line: self handleLeft @ y to: self handleRight @ y color: (self foregroundColor alpha: 0.3)
]

{ #category : #'as yet unclassified' }
SBTSSlider >> handleLeft [

	^ self left + (self handleSize x * 0.5)
]

{ #category : #'as yet unclassified' }
SBTSSlider >> handleRight [

	^ self right - (self handleSize x * 0.5)
]

{ #category : #'as yet unclassified' }
SBTSSlider >> handleSize [

	^ 12 asPoint
]

{ #category : #'as yet unclassified' }
SBTSSlider >> handleWidth [

	^ self width - self handleSize x
]

{ #category : #'as yet unclassified' }
SBTSSlider >> handlesMouseMove: anEvent [

	^ dragging
]

{ #category : #'as yet unclassified' }
SBTSSlider >> initialize [

	super initialize.
	
	dragging := false.
	
	self
		addMorphBack: (handle := CircleMorph new extent: self handleSize);
		extent: 60 @ (self handleSize y + 2);
		layoutPolicy: nil;
		hResizing: #rigid;
		vResizing: #rigid;
		value: 0.0
]

{ #category : #'as yet unclassified' }
SBTSSlider >> minExtent [

	^ 120 @ (self handleSize x + 2)
]

{ #category : #'as yet unclassified' }
SBTSSlider >> mouseCursorAt: anEvent [

	^ Cursor resizeLeft
]

{ #category : #'as yet unclassified' }
SBTSSlider >> mouseDown: anEvent [

	self valueFromEvent: anEvent.
	self select.
	dragging := true.
	scrubbingCommand := SBMutatePropertyCommand new
		oldValue: self value;
		selector: #value;
		target: self
]

{ #category : #'as yet unclassified' }
SBTSSlider >> mouseMove: anEvent [

	self valueFromEvent: anEvent
]

{ #category : #'as yet unclassified' }
SBTSSlider >> mouseUp: evt [

	dragging := false.
	(scrubbingCommand notNil and: [scrubbingCommand oldValue ~= self value]) ifTrue: [self sandblockEditor do: (scrubbingCommand value: self value)].
	super mouseUp: evt
]

{ #category : #'as yet unclassified' }
SBTSSlider >> repositionHandle [

	self handleLeft + (self handleWidth * value).
	handle center: self handleLeft + (self handleWidth * value) @ self center y
]

{ #category : #'as yet unclassified' }
SBTSSlider >> startDrag: anEvent [

	
]

{ #category : #'as yet unclassified' }
SBTSSlider >> value [

	^ value
]

{ #category : #'as yet unclassified' }
SBTSSlider >> value: aNumber [

	value := aNumber.
	self repositionHandle
]

{ #category : #'as yet unclassified' }
SBTSSlider >> valueFromEvent: anEvent [

	self value: (anEvent position x - self handleLeft / self handleWidth
		clampLow: 0
		high: 1).
	self batchedChangeStep
]
