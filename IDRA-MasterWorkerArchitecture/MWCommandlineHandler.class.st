Class {
	#name : #MWCommandlineHandler,
	#superclass : #CommandLineHandler,
	#category : #'IDRA-MasterWorkerArchitecture'
}

{ #category : #activation }
MWCommandlineHandler class >> activate [
	^ 'MasterWorker'
]

{ #category : #activation }
MWCommandlineHandler >> activate [
	| workers |
	(self commandLine hasOption: 'master') ifTrue: [ 
		workers := self optionAt: ''
		 ]
]
