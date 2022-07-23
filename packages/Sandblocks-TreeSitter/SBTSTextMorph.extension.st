Extension { #name : #SBTSTextMorph }

{ #category : #'*Sandblocks-TreeSitter-VR' }
SBTSTextMorph >> exportStructure [

	^ {
		#class -> #text.
		#bounds -> (self bounds in: [:r | {r left. r top. r width. r height}]).
		#regex -> ([self slot firstNode regexString] ifError: ['']).
		#contents -> self contents.
		#color -> self color asHTMLColor.
		#id -> self vrId} as: Dictionary
]
