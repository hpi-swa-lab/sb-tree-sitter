Class {
	#name : #DCProject,
	#superclass : #SBBlock,
	#instVars : [
		'directory',
		'name'
	],
	#category : #'DomainCode-Core'
}

{ #category : #'as yet unclassified' }
DCProject >> directory [

	^ directory
]

{ #category : #'as yet unclassified' }
DCProject >> directory: aDirectory [

	directory := aDirectory asFSReference.
	
	self
		removeAllMorphs;
		changeTableLayout;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		listDirection: #leftToRight;
		addMorphBack: (name := SBTextBubble new contents: directory basename);
		addMorphBack: (SBButton new icon: SBIcon iconFolderOpen do: [self addProp: #open])
]

{ #category : #'as yet unclassified' }
DCProject >> domainParent [

	^ self owner owner
]

{ #category : #'as yet unclassified' }
DCProject >> domainReferencesDo: aClosure [

	aClosure value: self directory
]

{ #category : #'as yet unclassified' }
DCProject >> name [

	^ name contents
]

{ #category : #'as yet unclassified' }
DCProject >> name: aString [

	name contents: aString
]
