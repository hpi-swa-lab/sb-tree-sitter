Class {
	#name : #SBTSSlotTest,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSSlotTest >> testStmtInArgument [

	| targetPosition dropped |
	"self=stmt,expr,id	anotherSlot=expr|num"
	targetPosition := SBTSSlot new addNode: (SBPython instance bodyNodeForRule: 'argument_list') elements second element.
	dropped := (SBPython parseToplevel: 'a') childSandblocks first slot.
	self assert: (dropped adaptSlotFor: targetPosition).
	self assert: dropped slot nodes lastNode type equals: #expression.
	self assert: dropped slot nodes lastNode parent equals: targetPosition firstNode
]
