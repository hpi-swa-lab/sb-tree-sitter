Class {
	#name : #SBWingParameter,
	#superclass : #SBRow,
	#instVars : [
		'name'
	],
	#category : #'Sandblocks-Wing'
}

{ #category : #'as yet unclassified' }
SBWingParameter >> from: anArgumentsBlock [

	
]

{ #category : #'as yet unclassified' }
SBWingParameter >> icon: aMorph [

	self addMorphFront: aMorph
]

{ #category : #'as yet unclassified' }
SBWingParameter >> initialize [

	super initialize.
	
	self cellGap: 4
]

{ #category : #'as yet unclassified' }
SBWingParameter >> name [

	^ name
]

{ #category : #'as yet unclassified' }
SBWingParameter >> name: aSymbol [

	name := aSymbol
]

{ #category : #'as yet unclassified' }
SBWingParameter >> update [

	
]

{ #category : #'as yet unclassified' }
SBWingParameter >> value [

	^ self shouldNotImplement
]
