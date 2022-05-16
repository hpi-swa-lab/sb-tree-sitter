Class {
	#name : #SBDocsPopup,
	#superclass : #SBPopup,
	#instVars : [
		'target'
	],
	#category : #'Sandblocks-Clojure'
}

{ #category : #'as yet unclassified' }
SBDocsPopup >> dismiss [
	<action>

	self delete.
	target select
]

{ #category : #'as yet unclassified' }
SBDocsPopup >> showBelow: aBlock closeOnDeselect: aBoolean [

	target := aBlock.
	super showBelow: aBlock closeOnDeselect: aBoolean
]
