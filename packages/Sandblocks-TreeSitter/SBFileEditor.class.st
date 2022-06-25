Class {
	#name : #SBFileEditor,
	#superclass : #SBBrowserEditor,
	#instVars : [
		'root'
	],
	#category : #'Sandblocks-TreeSitter-Project'
}

{ #category : #'as yet unclassified' }
SBFileEditor class >> openProject: aPath [

	self new
		openProject: aPath;
		openInWindow
]

{ #category : #'as yet unclassified' }
SBFileEditor >> initialize [

	| fileScroller |
	super initialize.
	
	self submorphs second addMorphFront: (fileScroller := ScrollPane new
		vResizing: #spaceFill;
		width: 200).
	fileScroller scroller addMorphBack: (root := SBFileTree new
		on: FileSystem disk / 'home';
		layoutInset: (SBEdgeInsets right: 12);
		toggleExpand;
		when: #open send: #openFile: to: self)
]

{ #category : #'as yet unclassified' }
SBFileEditor >> openFile: aFile [

	aFile isDirectory ifFalse: [self openMorphInView: (SBTSFile for: aFile pathString)]
]

{ #category : #'as yet unclassified' }
SBFileEditor >> openProject: aStringPath [

	root on: (FileSystem disk referenceTo: aStringPath).
	root toggleExpand
]
