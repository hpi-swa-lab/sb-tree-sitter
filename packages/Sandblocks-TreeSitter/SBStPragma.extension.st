Extension { #name : #SBStPragma }

{ #category : #'*Sandblocks-TreeSitter-Tools' }
SBStPragma >> asQueryDebugger: converter [
	<convert>
	<automatic>

	converter
		if: [{#lang:match:. #lang:match:sample:. #lang:match:sample:keyword:} includes: self keyword]
		do: [SBTSQueryDebugger new asInlineFor: self]
]
