Class {
	#name : #SBTSMemoizedBlocks,
	#superclass : #Object,
	#instVars : [
		'blocks',
		'position',
		'wasIncomplete'
	],
	#category : #'Sandblocks-TreeSitter-Parser'
}

{ #category : #'as yet unclassified' }
SBTSMemoizedBlocks >> adapt: aParser for: aSymbol [

	^ aParser copy
		basicAddBlocks: (self blocksCopied collect: [:b |
			aSymbol isBlockInlinedInParent ifFalse: [
				"we match the memo table by the general symbol; now we replace the matching symbol with the exact symbol that the current context wants"
				self assert: b slot lastNode type = aSymbol type.
				b slot: (b slot replaceLast: aSymbol)].
			b]);
		wasIncomplete: self wasIncomplete;
		position: self position;
		yourself
]

{ #category : #'as yet unclassified' }
SBTSMemoizedBlocks >> blocks [

	^ blocks
]

{ #category : #'as yet unclassified' }
SBTSMemoizedBlocks >> blocks: anObject [

	blocks := anObject
]

{ #category : #'as yet unclassified' }
SBTSMemoizedBlocks >> blocksCopied [

	^ self blocks collect: [:b | b copyBlock]
]

{ #category : #'as yet unclassified' }
SBTSMemoizedBlocks >> position [

	^ position
]

{ #category : #'as yet unclassified' }
SBTSMemoizedBlocks >> position: anObject [

	position := anObject
]

{ #category : #'as yet unclassified' }
SBTSMemoizedBlocks >> postCopy [

	super postCopy.
	blocks := self blocksCopied
]

{ #category : #'as yet unclassified' }
SBTSMemoizedBlocks >> wasIncomplete [

	^ wasIncomplete
]

{ #category : #'as yet unclassified' }
SBTSMemoizedBlocks >> wasIncomplete: aBoolean [

	wasIncomplete := aBoolean
]
