Extension { #name : #SBTSBlock }

{ #category : #'*Sandblocks-TreeSitter-VR' }
SBTSBlock >> blockDepth [

	| depth |
	depth := 0.
	self withAllOwnersDo: [:owner |
		depth := depth + 1.
		owner = self containingFloat ifTrue: [^ depth]].
	
	self assert: false
]

{ #category : #'*Sandblocks-TreeSitter-VR' }
SBTSBlock >> exportStructure [

	| previous |
	previous := nil.
	^ {
		#children -> (Array streamContents: [:stream |
			self
				cursorPositionsDo: [:pos |
					"pos isInsert ifTrue: [stream nextPut: ({#class -> #insert. #bounds -> (pos bounds in: [:r | {r left. r top. r width. r height}]). #horizontal -> pos hasHorizontalLayout. #type -> pos command element type} as: Dictionary)]."
					pos isText ifTrue: [stream nextPut: pos block currentTextMorph exportStructure].
					(pos isSelect and: [pos block ~= self]) ifTrue: [
						previous ifNotNil: [(pos block factory hardLineBreakBetween: previous and: pos block) ifTrue: [stream nextPut: ({#class -> #hardLineBreak} as: Dictionary)]].
						stream nextPut: pos block exportStructure.
						previous := pos block]]
				shallow: true]).
		#class -> #block.
		#bounds -> (self bounds in: [:r | {r left. r top. r width. r height}]).
		#type -> self type.
		#id -> self vrId} as: Dictionary
]
