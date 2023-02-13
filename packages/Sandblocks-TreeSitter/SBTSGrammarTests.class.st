Class {
	#name : #SBTSGrammarTests,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Tests'
}

{ #category : #'as yet unclassified' }
SBTSGrammarTests >> testResolveAlias [

	| resolved |
	resolved := (SBTSCursor new library: nil cursor: nil factory: SBJavascript instance)
		resolveAlias: 'property_identifier'
		in: 'member_expression'
		with: SBJavascript instance grammar aliasOccurrences.
	self assert: 'identifier' equals: resolved element printString.
	
	resolved := (SBTSCursor new library: nil cursor: nil factory: SBJavascript instance)
		resolveAlias: 'property_identifier'
		in: '_property_name'
		with: SBJavascript instance grammar aliasOccurrences.
	self
		assert: 'identifier'
		equals: resolved element printString.
	
	resolved := (SBTSCursor new library: nil cursor: nil factory: SBJavascript instance)
		resolveAlias: 'property_identifier'
		in: 'pair_pattern'
		with: SBJavascript instance grammar aliasOccurrences.
	self
		assert: 'identifier'
		equals: resolved element printString
]

{ #category : #'as yet unclassified' }
SBTSGrammarTests >> testResolveAmbiguousAlias [

	| resolved library |
	library := SBTreeSitter new.
	{{'"abc"'. 'unescaped_double_string_fragment'}. {'''abc'''. 'unescaped_single_string_fragment'}} do: [:pair |
		library parseAsCursor: pair first language: #javascript do: [:c | | cursor |
			cursor := SBTSCursor new library: library cursor: c factory: SBJavascript instance grammar.
			
			cursor
				gotoFirstChild;
				gotoFirstChild;
				gotoFirstChild;
				gotoNextSibling.
			self assert: 'string_fragment' equals: cursor type.
			
			resolved := cursor
				resolveAlias: 'string_fragment'
				in: 'string'
				with: SBJavascript instance grammar aliasOccurrences.
			self assert: pair second equals: resolved element printString]]
]
