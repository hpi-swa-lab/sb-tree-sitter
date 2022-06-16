Class {
	#name : #SBTSInputReconcile,
	#superclass : #Object,
	#instVars : [
		'before',
		'target',
		'choices'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSInputReconcile >> tryAdjacent [
	"if we are at the very lowest level, in a textmorph still, dont try adjacent blocks just yet"

	before ifTrue: [^ false].
	target isTextMorph ifTrue: [^ false].
	self positionAfterDo: [:position |
		(position isText and: [position block wantsInput]) ifTrue: [
			^ SBTSDisambiguatePopup new
				for: position block
				input: self contents
				before: false
				from: position block].
		position isInsert ifTrue: [
			(position command tryExpandWithInput: self contents) ifTrue: [
				target sandblockEditor do: position command.
				choices := #().
				^ true]]].
	^ false
]
