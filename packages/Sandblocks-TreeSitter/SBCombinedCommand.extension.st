Extension { #name : #SBCombinedCommand }

{ #category : #'*Sandblocks-TreeSitter-VR' }
SBCombinedCommand >> vrDo [

	commands do: [:command | command vrDo]
]
