Class {
	#name : #SBTSSlotTest,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Tests'
}

{ #category : #'as yet unclassified' }
SBTSSlotTest >> testParseEqualsTypedIdentifier [

	| parsed typed editor |
	parsed := SBJavascript parseToplevel: 'x'.
	typed := SBJavascript parseToplevel: ''.
	editor := self editorAndWorldFor: typed.
	typed lastDeepChild startInsertAtEnd.
	self type: 'x' in: editor.
	self assert: parsed lastDeepChild slot nodes equals: typed lastDeepChild slot nodes
]

{ #category : #'as yet unclassified' }
SBTSSlotTest >> testParseEqualsTypedShorthandProp [

	| parsed typed editor |
	parsed := SBTypescript parseToplevel: 'let a = {key}'.
	typed := SBTypescript parseToplevel: 'let a = {}'.
	editor := self editorAndWorldFor: typed.
	typed lastDeepChild startInsertAtEnd.
	self type: 'key' in: editor.
	self tick.
	self tick.
	self type: String cr in: editor.
	self assert: parsed lastDeepChild slot nodes equals: typed lastDeepChild slot nodes
]

{ #category : #'as yet unclassified' }
SBTSSlotTest >> testStmtInArgument [

	| targetPosition dropped new |
	"self=stmt,expr,id	anotherSlot=expr|num"
	targetPosition := SBTSSlot with: (SBPython instance grammar bodyNodeForRule: 'argument_list') elements second element.
	dropped := (SBPython parseToplevel: 'a') childSandblocks first.
	new := dropped adaptSlotFor: targetPosition ifFailed: [self assert: false].
	self assert: new slot lastNode type equals: #expression.
	self assert: new slot lastNode parent equals: targetPosition firstNode
]
