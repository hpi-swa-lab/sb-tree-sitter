Class {
	#name : #SBTSGrammarTests,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Tests'
}

{ #category : #'as yet unclassified' }
SBTSGrammarTests >> testBlockInlineDetect [

	| factory |
	factory := SBMetaBlockFactory new grammar: (Json readFrom: '{"supertypes":[],"inline":[]}' readStream).
	factory at: 'expr' putTemplate: (SBInlineBlockChoice new alternatives: {
		SBInlineBlockSequence new elements: {
			SBInlineBlockSymbol new type: 'expr' factory: factory.
			SBInlineBlockLabel new label: '+'.
			SBInlineBlockSymbol new type: 'expr' factory: factory}.
		SBInlineBlockText new regexString: '[0-9]+'}).
	factory at: 'arguments' putTemplate: (SBInlineBlockSequence new elements: {
		SBInlineBlockLabel new label: '('.
		SBInlineBlockSymbol new type: 'expr' factory: factory.
		SBInlineBlockLabel new label: ')'}).
	factory at: 'call' putTemplate: (SBInlineBlockSequence new elements: {
		SBInlineBlockSymbol new type: 'expr' factory: factory.
		SBInlineBlockSymbol new type: 'arguments' factory: factory}).
	
	factory findBlockInlineCandidates.
	
	self assert: (factory shouldBlockInline: 'arguments')
]

{ #category : #'as yet unclassified' }
SBTSGrammarTests >> testPythonForInClauseRepeat [

	| clause |
	clause := SBPython instance getTemplate: 'for_in_clause'.
	self assert: clause elements last required
]

{ #category : #'as yet unclassified' }
SBTSGrammarTests >> testResolveAlias [

	| resolved |
	resolved := (SBTSCursor new library: nil cursor: nil factory: SBJavascript new)
		resolveAlias: 'property_identifier'
		in: 'member_expression'.
	self assert: '(identifier)' equals: resolved printString.
	
	resolved := (SBTSCursor new library: nil cursor: nil factory: SBJavascript new)
		resolveAlias: 'property_identifier'
		in: '_property_name'.
	self assert: '(identifier | get | set | async | static | export)' equals: resolved printString.
	
	resolved := (SBTSCursor new library: nil cursor: nil factory: SBJavascript new)
		resolveAlias: 'property_identifier'
		in: 'pair_pattern'.
	self assert: '(identifier | get | set | async | static | export)' equals: resolved printString
]

{ #category : #'as yet unclassified' }
SBTSGrammarTests >> testResolveAmbiguousAlias [

	| resolved library |
	library := SBTreeSitter new.
	{{'"abc"'. '(unescaped_double_string_fragment)'}. {'''abc'''. '(unescaped_single_string_fragment)'}} do: [:pair |
		library parseAsCursor: pair first language: #javascript do: [:c | | cursor |
			cursor := SBTSCursor new library: library cursor: c factory: SBJavascript new.
			
			cursor
				gotoFirstChild;
				gotoFirstChild;
				gotoFirstChild;
				gotoNextSibling.
			self assert: 'string_fragment' equals: cursor type.
			
			resolved := cursor resolveAlias: 'string_fragment' in: 'string'.
			self assert: pair second equals: resolved printString]]
]