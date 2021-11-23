Class {
	#name : #SBTSGrammarTests,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Tests'
}

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
