Class {
	#name : #SBTSSlotTest,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSSlotTest >> testStmtInArgument [

	| targetPosition dropped new |
	"self=stmt,expr,id	anotherSlot=expr|num"
	targetPosition := SBTSSlot with: (SBPython instance bodyNodeForRule: 'argument_list') elements second element.
	dropped := (SBPython parseToplevel: 'a') childSandblocks first.
	new := dropped adaptSlotFor: targetPosition ifFailed: [self assert: false].
	self assert: new slot lastNode type equals: #expression.
	self assert: new slot lastNode parent equals: targetPosition firstNode
]
