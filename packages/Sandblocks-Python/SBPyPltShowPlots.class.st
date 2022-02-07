"
This replacements shows the image. It renders the whole AST and adds python code to write the output image to stdout.
"
Class {
	#name : #SBPyPltShowPlots,
	#superclass : #SBInlineBlockReplace,
	#instVars : [
		'image'
	],
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltShowPlots class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(call
	function: (attribute
		(identifier) ="plt"
        (identifier) ="show"
    )
) @show' sample: 'plt.show()'>
	
	^ aBlock 
		value: (aDictionary at: 'show') 
		value: (self new factory: (aDictionary at: 'show') factory; createReplacement)
]

{ #category : #'initialize-release' }
SBPyPltShowPlots >> createReplacement [

	self addMorphBack: (SBColumn new
		 addMorphBack: (SBButton new icon: SBIcon iconPlay label: 'show plot' do: [self updateImage]);
		addMorphBack: (image asMorph)).
]

{ #category : #'accessing - extension' }
SBPyPltShowPlots >> getModuleSource [
"traverses AST upwards until the whole module is included. Then parse python source"

	| aStream closestCommonAncestor |
	
	aStream := ReadWriteStream on: String new.
	
	closestCommonAncestor := self.
	[ closestCommonAncestor type ~= 'module' ] whileTrue: [
		closestCommonAncestor := closestCommonAncestor owner.
	].
	
	closestCommonAncestor writeSourceOn: aStream.
	^ aStream contents
]

{ #category : #'initialize-release' }
SBPyPltShowPlots >> initialize [

	super initialize.
	image := '' asMorph.
]

{ #category : #'as yet unclassified' }
SBPyPltShowPlots >> palettes [

	^ {SBPyPltPaletteOverview}
]

{ #category : #'as yet unclassified' }
SBPyPltShowPlots >> type [

	^ 'call'
]

{ #category : #updating }
SBPyPltShowPlots >> updateImage [

	image := (Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: (SBPython instance runtime evaluate: self getModuleSource) readStream)) asMorph.

	self firstSubmorph removeMorph: (self firstSubmorph lastSubmorph).
	self firstSubmorph addMorphBack: image.
]

{ #category : #'initialize-release' }
SBPyPltShowPlots >> writeSourceOn: aStream [
"unlike other replacements, the underlying python code prints the image to stdout, so it can be parsed as a Form"

	aStream nextPutAll: '
bytes = io.BytesIO()
plt.savefig(bytes, format="png")
bytes.seek(0)
sys.stdout.buffer.write(base64.b64encode(bytes.read()))
bytes.close()
'.
]
