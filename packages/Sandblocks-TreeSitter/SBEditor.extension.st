Extension { #name : #SBEditor }

{ #category : #'*Sandblocks-TreeSitter' }
SBEditor >> openTreeSitterQueryDebugger [
	<addAction>
	<label: 'Tree Sitter Query Debugger'>

	self createArtefactInView: SBTSQueryDebugger new
]
