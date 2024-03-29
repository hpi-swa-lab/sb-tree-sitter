Class {
	#name : #SBTSQueryDebugger,
	#superclass : #SBBlock,
	#instVars : [
		'language',
		'source',
		'query',
		'program',
		'inline',
		'syntaxInvalid',
		'sourceTree',
		'keyword'
	],
	#category : #'Sandblocks-TreeSitter-Replacements'
}

{ #category : #'as yet unclassified' }
SBTSQueryDebugger >> artefactSaved: aMethodBlock [

	(inline and: [aMethodBlock = self containingArtefact]) ifTrue: [self saveTryFixing: false quick: false]
]

{ #category : #'as yet unclassified' }
SBTSQueryDebugger >> asInlineFor: aPragma [

	inline := true.
	query contents: aPragma arguments second contents.
	aPragma arguments size >= 3 ifTrue: [source contents: aPragma arguments third contents].
	aPragma arguments size >= 4 ifTrue: [keyword contents: aPragma arguments fourth contents].
	language object: (SBTSLanguage allSubclasses detect: [:class | class language = aPragma arguments first contents]).
	self firstSubmorph contents: 'Query Match'
]

{ #category : #'as yet unclassified' }
SBTSQueryDebugger >> example [

	SBMorphExample
		setUp: [self class new]
		cases: {SBMorphExampleCase name: 'example 1' caseBlock: [:m | m]}
		extent: 300 @ 300
]

{ #category : #'as yet unclassified' }
SBTSQueryDebugger >> initialize [

	super initialize.
	
	inline := false.
	
	self
		changeTableLayout;
		cellGap: 8;
		layoutInset: 8;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		attachDecorator: SBMoveDecorator new;
		attachDecorator: SBResizableDecorator new;
		addMorphBack: (SBStringMorph new
			contents: 'Tree Sitter Query Debugger';
			bold);
		addMorphBack: (language := SBComboBox new
			values: SBTSLanguage allSubclasses;
			prefix: 'Language: ';
			object: SBJavascript);
		addMorphBack: (SBStringMorph new contents: 'Source Code:');
		addMorphBack: (source := SBTextBubble multiLine
			placeholderText: 'void main() ...';
			hResizing: #spaceFill);
		addMorphBack: (sourceTree := SBTextBubble multiLine
			placeholderText: '';
			hResizing: #spaceFill);
		addMorphBack: (SBStringMorph new contents: 'Query:');
		addMorphBack: (query := SBTextBubble multiLine
			placeholderText: '(program (...';
			hResizing: #spaceFill);
		addMorphBack: (keyword := SBTextBubble new
			placeholderText: 'keyword';
			hResizing: #spaceFill);
		addMorphBack: (SBStringMorph new contents: 'Preview (save to update):')
]

{ #category : #'as yet unclassified' }
SBTSQueryDebugger >> isArtefact [

	^ inline not
]

{ #category : #'as yet unclassified' }
SBTSQueryDebugger >> saveTryFixing: aFixBoolean quick: aQuickBoolean [

	program ifNotNil: #delete.
	source contents ifEmpty: [^ true].
	
	source detachDecorators: SBErrorDecorator.
	program := [SBTSFileParser new parse: source contents language: language object]
		on: SBTSSyntaxError
		do: [:error |
			source attachDecorator: (SBErrorDecorator new message: 'syntax invalid').
			^ false].
	sourceTree contents: program printTree.
	self addMorphBack: program.
	program hResizing: #spaceFill.
	
	program allBlocksDo: [:block |
		block query: query contents capturesDo: [:captures |
			captures keysAndValuesDo: [:name :match |
				match isSandblock ifTrue: [
					match
						attachDecorator: (SBReportedValueDecorator new label: name);
						attachDecorator: SBErrorDecorator new]]]].
	
	^ true
]

{ #category : #'as yet unclassified' }
SBTSQueryDebugger >> writeSourceOn: aStream [

	aStream nextPutAll: '<lang: '.
	aStream store: language object language.
	aStream nextPutAll: ' match: '.
	aStream store: query contents.
	source contents ifNotEmpty: [
		aStream nextPutAll: ' sample: '.
		aStream store: source contents].
	keyword contents ifNotEmpty: [
		aStream nextPutAll: ' keyword: '.
		aStream store: keyword contents].
	aStream nextPutAll: '>'
]
