Class {
	#name : #SBFileEditor,
	#superclass : #SBBrowserEditor,
	#category : #'Sandblocks-TreeSitter-Project'
}

{ #category : #'as yet unclassified' }
SBFileEditor >> initialize [

	| fileScroller |
	super initialize.
	
	self submorphs second addMorphFront: (fileScroller := ScrollPane new
		vResizing: #spaceFill;
		width: 200).
	fileScroller scroller addMorphBack: (SBFileTree new
		on: FileSystem disk / 'home';
		layoutInset: (SBEdgeInsets right: 12);
		toggleExpand;
		when: #open send: #openFile: to: self).
	self openMorphInView: (SBTSFile for: '/home/tom/Code/js/server/test.js')
]

{ #category : #'as yet unclassified' }
SBFileEditor >> openFile: aFile [

	aFile isDirectory ifFalse: [self openMorphInView: (SBTSFile for: aFile pathString)]
]
