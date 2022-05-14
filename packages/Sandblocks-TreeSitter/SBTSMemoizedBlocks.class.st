Class {
	#name : #SBTSMemoizedBlocks,
	#superclass : #Object,
	#instVars : [
		'blocks',
		'position'
	],
	#category : #'Sandblocks-TreeSitter-Parser'
}

{ #category : #'as yet unclassified' }
SBTSMemoizedBlocks >> adapt: aParser for: aSymbol [

	^ aParser copy
		addBlocks: (self blocksCopied collect: [:b |
			"we match the memo table by the general symbol; now we replace the matching symbol with the exact symbol that the current context wants"
			self assert: b slot lastNode type = aSymbol type.
			b slot replaceLast: aSymbol.
			b]);
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
