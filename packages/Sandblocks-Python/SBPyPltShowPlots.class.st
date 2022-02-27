"
This replacements shows the image by executing its enclosing module.
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

{ #category : #'event handling' }
SBPyPltShowPlots >> artefactSaved: anArtefact [
	anArtefact = self containingArtefact ifTrue: [self updateImage].
]

{ #category : #'initialize-release' }
SBPyPltShowPlots >> createReplacement [

	self addMorphBack: (SBColumn new
		 addMorphBack: (SBButton new icon: SBIcon iconPlay label: 'show plot' do: [self updateImage]);
		addMorphBack: (image asMorph)).
]

{ #category : #'initialize-release' }
SBPyPltShowPlots >> initialize [

	super initialize.
	image := '' asMorph.
]

{ #category : #classification }
SBPyPltShowPlots >> palettes [

	^ {SBPyPltPaletteOverview}
]

{ #category : #classification }
SBPyPltShowPlots >> type [

	^ 'call'
]

{ #category : #updating }
SBPyPltShowPlots >> updateImage [
	[
		image := (Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self toplevel evaluate readStream)) asMorph.
		self firstSubmorph removeMorph: (self firstSubmorph lastSubmorph).
		self firstSubmorph addMorphBack: image.
		
	] on: Error do: [ :err | "print error code"
		self firstSubmorph removeMorph: (self firstSubmorph submorphs last).
		self firstSubmorph addMorphBack: (SBMultilineOwnTextMorph new
			contents: err contents;
			maxWidth: 400;
			yourself)
	]
]

{ #category : #copying }
SBPyPltShowPlots >> writeSourceOn: aStream [
"python code prints the image to stdout, so it can be parsed as a Form"

	aStream nextPutAll: '
bytes = io.BytesIO()
plt.savefig(bytes, format="png")
bytes.seek(0)
sys.stdout.buffer.write(base64.b64encode(bytes.read()))
bytes.close()
'.
]
