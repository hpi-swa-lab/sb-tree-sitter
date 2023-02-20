Class {
	#name : #SBFileEditor,
	#superclass : #SBBrowserEditor,
	#instVars : [
		'root',
		'projectSemantics',
		'commandBar'
	],
	#category : #'Sandblocks-TreeSitter-Files'
}

{ #category : #'as yet unclassified' }
SBFileEditor class >> openProject: aPath [

	self new
		openProject: aPath;
		openInWindow
]

{ #category : #'as yet unclassified' }
SBFileEditor >> addRuntime: aRuntime [

	commandBar addMorphBack: aRuntime
]

{ #category : #'as yet unclassified' }
SBFileEditor >> artefactChanged: aMethodBlock [

	aMethodBlock = self currentFile ifTrue: [self runtimesDo: [:r | r didChange: self currentFile]]
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
	
	paletteContainer removeDropShadow.
	
	self addMorphBack: (commandBar := SBRow new
		changeTableLayout;
		hResizing: #spaceFill;
		cellGap: 4;
		layoutInset: 4;
		addMorphBack: (SBButton new
			icon: SBIcon iconSearch
				shortcut: nil
				do: [SBPreferences largeInsets: SBPreferences largeInsets not];
			balloonText: 'Toggle Block Palette');
		addMorphBack: (SBButton new
			icon: SBIcon iconColumns shortcut: nil do: [self togglePalette];
			balloonText: 'Toggle Block Palette');
		addMorphBack: (SBButton new
			icon: SBIcon iconFilesO shortcut: nil do: [self toggleFileBrowser];
			balloonText: 'Toggle File Browser')).
	
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

	self currentFile ifNotNil: [:currentFile | self runtimesDo: [:r | r didClose: currentFile]].
	aFile isDirectory ifFalse: [ | newFile |
		newFile := SBTSFile forNoReplace: aFile pathString.
		self openMorphInView: newFile.
		self runtimesDo: [:r | r didOpen: newFile].
		^ newFile].
	^ nil
]

{ #category : #'as yet unclassified' }
SBFileEditor >> openProject: aStringPath [

	root on: (FileSystem disk referenceTo: aStringPath).
	root toggleExpand.
	
	SBTSLanguageRuntime allSubclassesDo: [:runtimeClass | runtimeClass activateFor: root file do: [:runtime | self addRuntime: runtime]]
]

{ #category : #'as yet unclassified' }
SBFileEditor >> outOfWorld: aWorld [

	super outOfWorld: aWorld.
	
	self runtimesDo: [:r | r shutdown]
]

{ #category : #'as yet unclassified' }
SBFileEditor >> root [

	^ root
]

{ #category : #'as yet unclassified' }
SBFileEditor >> runtimesDo: aBlock [

	commandBar submorphsDo: [:s | (s isKindOf: SBTSLanguageRuntime) ifTrue: [aBlock value: s]]
]
