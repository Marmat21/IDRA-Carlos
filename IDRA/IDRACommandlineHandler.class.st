Class {
	#name : #IDRACommandlineHandler,
	#superclass : #CommandLineHandler,
	#category : #'IDRA-CLH'
}

{ #category : #accessing }
IDRACommandlineHandler class >> commandName [
	^ 'IDRA'
]

{ #category : #accessing }
IDRACommandlineHandler class >> description [
	^'THIS IS A HELP'
]

{ #category : #activation }
IDRACommandlineHandler >> activate [
	| host port changesPort monitorHost |
	(self commandLine hasOption: 'monitor') ifTrue: [
		host := self optionAt: 'managerHost' ifAbsent: [
				self exitFailure: 'Missing host for IDRA Manager'.
			].
		port := self optionAt: 'managerPort' ifAbsent: [
				self exitFailure: 'Missing port for IDRA Manager'.
			].
		monitorHost := self optionAt: 'changesHost' ifAbsent: [ 
			1 inform: 'No host indicated for the changes handler. Using localhost'.
			monitorHost := 'http://localhost'
			 ].
		changesPort := self optionAt: 'changesPort' ifAbsent: [
				1 inform: 'changes listener started on default port 3333'.
				changesPort := '3333'.
			].
		DebuggerWithChangesHandler setupAsDebuggerMonitorOnURL: host port: (port asInteger)  listeningChangesUrl: monitorHost port: (changesPort asInteger).
		self exitSuccess.
	] ifFalse: [ 
	(self commandLine hasOption: 'manager') ifTrue: [ 
		port := self optionAt: 'managerPort' ifAbsent: [
				self exitFailure:  'Missing IDRA Manager port.'
			].
		DebuggerWithChangesHandler setupAsDebuggerOnPort: (port asInteger).
		self exitSuccess.
		 ].
		self exitFailure: 'No manager or monitor indicated']
]
