Class {
	#name : #BaselineOfSBTreeSitter,
	#superclass : #BaselineOf,
	#category : #BaselineOfSBTreeSitter
}

{ #category : #'as yet unclassified' }
BaselineOfSBTreeSitter class >> createSAR [

	| preamble zip |
	zip := ZipArchive new.
	preamble := String streamContents: [:preambleStream |
	    preambleStream
	        nextPutAll: '| loader |
	loader := MCVersionLoader new.';
	        cr.
	    (((self project version: 'baseline') allPackagesForSpecNamed: #default) collect: #name) do: [:name | | stream version |
	        stream := RWBinaryOrTextStream on: (String new: 10000).
	        version := MCVersion
	            package: (MCPackage named: name)
	            info: ((MCPackage named: 'Sandblocks-Core') workingCopy ancestry ancestors
					ifNotEmpty: #first
					ifEmpty: [MCVersionInfo name: name, '-generated.1' id: UUID new message: '' date: Date today time: Time now author: 'generated' ancestors: #()]).
	        version fileOutOn: stream.
	        (zip addString: stream contents as: name, '.mcz') desiredCompressionLevel: 0.
	        preambleStream
	            nextPutAll: 'loader addVersion: (MCMczReader versionFromStream: (self memberNamed: ''';
	            nextPutAll: name;
	            nextPutAll: '.mcz'') contentStream).';
	            cr].
	    preambleStream nextPutAll: 'loader load.'].
	zip addString: preamble as: 'install/preamble'.
	zip writeToFileNamed: 'sandblocks.sar'
]

{ #category : #'as yet unclassified' }
BaselineOfSBTreeSitter class >> projectVersion [

	^ '0.0.0'
]

{ #category : #baseline }
BaselineOfSBTreeSitter >> baseline: spec [
	<baseline>

	spec for: #common do: [
		spec package: 'Sandblocks-Core' with: [spec repository: 'github://tom95/sandblocks/packages'].
		
		spec
			package: 'Sandblocks-TreeSitter' with: [spec requires: #('Sandblocks-Core')];
			package: 'Sandblocks-Javascript' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Python' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Regex' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Json' with: [spec requires: #('Sandblocks-TreeSitter')].
		
		spec
			group: 'default'
			with: #('Sandblocks-TreeSitter' 'Sandblocks-Javascript' 'Sandblocks-Python' 'Sandblocks-Regex' 'Sandblocks-Json')]
]

{ #category : #baseline }
BaselineOfSBTreeSitter >> projectClass [
	^ Smalltalk
		at: #MetacelloCypressBaselineProject
		ifAbsent: [super projectClass]
]
