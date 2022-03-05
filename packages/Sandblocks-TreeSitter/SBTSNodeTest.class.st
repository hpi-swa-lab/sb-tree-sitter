Class {
	#name : #SBTSNodeTest,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeTest >> testInsertPositionAfter [

	| template factory |
	factory := SBTSTestLanguage new.
	factory add: 'rule1' rule: (template := SBTSNodeSeq new elements: {
		SBTSNodeLabel new.
		SBTSNodeRepeat new multiple: true required: false element: SBTSNodeLabel new.
		SBTSNodeLabel new}).
	self assert: 3 equals: (SBTSRelInsertCommand new
		near: nil
		before: false
		in: (SBTSBlock new
			addAllMorphs: {
				SBTSTextMorph new slot: (SBTSSlot new addNode: template elements first).
				SBTSTextMorph new slot: (SBTSSlot new addNode: template elements second element).
				SBTSTextMorph new slot: (SBTSSlot new addNode: template elements third)};
			slot: (SBTSSlot new addNode: (SBTSNodeSymbol new type: 'rule1' factory: factory)))
		morph: template elements second element) insertIndex
]

{ #category : #'as yet unclassified' }
SBTSNodeTest >> testInsertPositionBefore [

	| template factory |
	factory := SBTSTestLanguage new.
	factory
		add: 'rule1'
		rule: (template := SBTSNodeSeq new elements: {SBTSNodeLabel new. SBTSNodeLabel new. SBTSNodeLabel new}).
	self assert: 2 equals: (SBTSRelInsertCommand new
		near: nil
		before: true
		in: (SBTSBlock new
			addAllMorphs: {
				SBTSTextMorph new slot: (SBTSSlot new addNode: template elements first).
				SBTSTextMorph new slot: (SBTSSlot new addNode: template elements third)};
			slot: (SBTSSlot new addNode: (SBTSNodeSymbol new type: 'rule1' factory: factory)))
		morph: template elements second) insertIndex
]
