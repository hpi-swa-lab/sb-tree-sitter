Class {
	#name : #BaselineOfSBTreeSitter,
	#superclass : #BaselineOf,
	#category : #BaselineOfSBTreeSitter
}

{ #category : #'as yet unclassified' }
BaselineOfSBTreeSitter class >> createSAR [

	| packageNames zip preamble |
	packageNames := self orderedDependencies reject: [:d | d startsWith: 'BaselineOf'].
	SBToggledCode comment: '' active: 0 do: {
		[
			packageNames := ((self project version: 'baseline') allPackagesForSpecNamed: #('default')) collect: #name.
			packageNames := packageNames copyWithoutAll: MCRepository trunk allPackageNames]}.
	
	zip := ZipArchive new.
	preamble := String streamContents: [:preambleStream |
		preambleStream
			nextPutAll: '| loader |
loader := MCVersionLoader new.';
			cr.
		(packageNames select: [:name | (MCPackage named: name) packageInfo classes notEmpty]) do: [:name | | stream version package |
			package := MCPackage named: name.
			stream := RWBinaryOrTextStream on: (String new: 10000).
			version := MCVersion package: package info: (package workingCopy ancestry ancestors
				ifNotEmpty: #first
				ifEmpty: [
					[(MCPackage named: name) workingCopy newVersion info]
						on: MCVersionNameAndMessageRequest
						do: [:notification | notification resume: {notification suggestedName. 'Version for export'}]]).
			version fileOutOn: stream.
			(zip addString: stream contents as: name, '.mcz') desiredCompressionLevel: 0.
			preambleStream
				nextPutAll: 'loader addVersion: (MCMczReader versionFromStream: (self memberNamed: ''';
				nextPutAll: name;
				nextPutAll: '.mcz'') contentStream).';
				cr].
		preambleStream nextPutAll: 'loader load.'].
	zip addString: preamble as: 'install/preamble'.
	^ zip writeToFileNamed: (self name allButFirst: 'BaselineOf' size), '.sar'
]

{ #category : #'as yet unclassified' }
BaselineOfSBTreeSitter class >> flattenDirectives: aDirective [

	(aDirective isKindOf: MetacelloLinearLoadDirective) ifFalse: [^ {aDirective}].
	^ aDirective loadDirectives gather: [:d | self flattenDirectives: d]
]

{ #category : #'as yet unclassified' }
BaselineOfSBTreeSitter class >> orderedDependencies [

	| deduplicated all |
	deduplicated := OrderedCollection new.
	all := ((Array streamContents: [:s |
		(Metacello new
			baseline: #SBTreeSitter;
			record) versionDirectivesDo: [:d | s nextPut: d]]) gather: [:d | BaselineOfSBTreeSitter flattenDirectives: d]) collect: #label.
	all do: [:d | (deduplicated includes: d) ifFalse: [deduplicated add: d]].
	^ deduplicated select: [:d | d last isDigit not]
]

{ #category : #baseline }
BaselineOfSBTreeSitter >> baseline: spec [
	<baseline>

	spec for: #common do: [
		" smalltalk needed for the tool integration "
		spec baseline: 'Sandblocks' with: [
			spec
				repository: 'github://hpi-swa/sandblocks/packages';
				loads: #('Sandblocks-Core' 'Sandblocks-Smalltalk' 'Sandblocks-Tutorial' 'Sandblocks-Watch' 'Sandblocks-Babylonian')].
		spec project: 'FFI' with: [
			spec
				className: 'ConfigurationOfFFI';
				repository: 'http://www.squeaksource.com/MetacelloRepository';
				versionString: #development;
				loads: #('Core')].
		spec project: 'OSProcess' with: [
			spec
				className: 'ConfigurationOfOSProcess';
				repository: 'http://www.squeaksource.com/MetacelloRepository';
				versionString: #stable;
				loads: #('Core')].
		spec package: 'JSON' with: [
			spec
				file: 'JSON-ul.35';
				repository: 'https://www.squeaksource.com/JSON'].
		
		spec
			package: 'Sandblocks-TreeSitter' with: [spec requires: #('Sandblocks' 'FFI' 'JSON' 'OSProcess')];
			package: 'Sandblocks-Javascript' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Python' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Regex' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Json' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-C' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Cpp' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Vhdl' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-TSSmalltalk' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Bash' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Matplotlib' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-RequestsTool' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Clojure' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Typescript' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Kotlin' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-GDScript' with: [spec requires: #('Sandblocks-TreeSitter')].
		
		spec
			group: 'default'
			with: #('Sandblocks-TreeSitter' 'Sandblocks-Javascript' 'Sandblocks-Python' 'Sandblocks-Regex' 'Sandblocks-Json' 'Sandblocks-C' 'Sandblocks-Cpp' 'Sandblocks-Vhdl' 'Sandblocks-Bash' 'Sandblocks-Clojure' 'Sandblocks-TSSmalltalk' 'Sandblocks-Typescript' 'Sandblocks-Matplotlib' 'Sandblocks-RequestsTool' 'Sandblocks-Kotlin' 'Sandblocks-GDScript')]
]

{ #category : #baseline }
BaselineOfSBTreeSitter >> depSqueakSource: aMCRepository name: aString targetRepository: anotherMCRepository [
	"taken from https://github.com/LinqLover/SimulationStudio/blob/master/packages/BaselineOfSimulationStudio.package/BaselineOfSimulationStudio.class/instance/depSqueakSource.name.targetRepository..st"

	(aMCRepository isKindOf: MCRepository) ifFalse: [
		^ self
			depSqueakSource: (MCRepository in: aMCRepository)
			name: aString
			targetRepository: anotherMCRepository].
	(anotherMCRepository isKindOf: MCRepository) ifFalse: [
		^ self
			depSqueakSource: aMCRepository
			name: aString
			targetRepository: (MCRepository in: anotherMCRepository)].
	
	^ ('{1} ({2})' format: {aString. aMCRepository description}) -> [ | packageName |
		packageName := aString, '.mcz'.
		[Installer new primMerge: packageName from: aMCRepository]
			on: MCPackageNotFound
			do: [:ex |
				(anotherMCRepository notNil
					and: [ex repository == aMCRepository]
					and: [ex packageName = packageName]) ifFalse: [ex pass].
				self notify: ('Preview version {1} has already been integrated' format: {aString})]
			on: MCMergeResolutionRequest
			do: [:ex |
				Smalltalk isHeadless ifFalse: [ex pass].
				self error: ex description]]
]

{ #category : #baseline }
BaselineOfSBTreeSitter >> projectClass [
	^ Smalltalk
		at: #MetacelloCypressBaselineProject
		ifAbsent: [super projectClass]
]
