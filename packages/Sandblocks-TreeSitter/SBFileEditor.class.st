Class {
	#name : #SBFileEditor,
	#superclass : #SBBrowserEditor,
	#instVars : [
		'root',
		'projectSemantics'
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
SBFileEditor >> artefactChanged: aMethodBlock [

	aMethodBlock = self currentFile ifTrue: [projectSemantics didChange: self currentFile]
]

{ #category : #'as yet unclassified' }
SBFileEditor >> batchedChangeStep: aBlock [

	| file |
	super batchedChangeStep: aBlock.
	file := aBlock containingArtefact.
	file ifNil: [^ self].
	file semantics didChange: file
]

{ #category : #'as yet unclassified' }
SBFileEditor >> currentFile [

	^ self childSandblocks ifNotEmpty: [:f | f anyOne] ifEmpty: [nil]
]

{ #category : #'as yet unclassified' }
SBFileEditor >> initialize [

	| fileScroller |
	super initialize.
	
	projectSemantics := SBTSLanguageSemantics new.
	
	self submorphs second addMorphFront: (SBBlock new
		attachDecorator: (SBResizableDecorator new edge: #right);
		addMorphBack: (fileScroller := ScrollPane new
			hResizing: #spaceFill;
			vResizing: #spaceFill);
		vResizing: #spaceFill;
		changeTableLayout;
		layoutInset: (SBEdgeInsets right: 4 sbScaled);
		width: 200).
	fileScroller scroller addMorphBack: (root := SBFileTree new
		on: FileSystem disk / 'home';
		layoutInset: (SBEdgeInsets right: 12);
		toggleExpand;
		when: #open send: #openFile: to: self)
]

{ #category : #'as yet unclassified' }
SBFileEditor >> openFile: aFile [

	self currentFile ifNotNil: [:currentFile | projectSemantics didClose: currentFile].
	aFile isDirectory ifFalse: [ | newFile |
		newFile := (SBTSFile for: aFile pathString)
			semantics: projectSemantics;
			yourself.
		self openMorphInView: newFile.
		projectSemantics didOpen: newFile.
		^ newFile].
	^ nil
]

{ #category : #'as yet unclassified' }
SBFileEditor >> openProject: aStringPath [

	root on: (FileSystem disk referenceTo: aStringPath).
	root toggleExpand
]

{ #category : #'as yet unclassified' }
SBFileEditor >> outOfWorld: aWorld [

	super outOfWorld: aWorld.
	
	projectSemantics shutdown
]

{ #category : #'as yet unclassified' }
SBFileEditor >> root [

	^ root
]

{ #category : #'as yet unclassified' }
SBFileEditor >> useTypescriptLSP [
	<globalAction>

	projectSemantics := SBTSLSPSemantics new on: self root directory
]
