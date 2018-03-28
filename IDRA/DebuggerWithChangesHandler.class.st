"
I represent a Debugger with Changes Handler.

You can use me to start an IDRA Debugger connected to an IDRA Changes Handler int two modes:
1. debugger monitor mode to listen for exceptions.
2. debugger manager mode to debug such exceptions.

You can start it as MANAGER in the following way:
DebuggerWithChangesHandler setupAsDebuggerOnPort: <managerPort>.

You can start it as MONITOR in the following way:
DebuggerWithChangesHandler setupAsDebuggerMonitorOnURL: 'managerHttpServerURL'  port: managerHttpServerPort listeningChangesUrl: 'myHttpServerUrl' port: myChangesServerPort.

You can start listening on all exceptions (on MONITOR side) with:
IDRAMonitor getInstance debugAll: true.
"
Class {
	#name : #DebuggerWithChangesHandler,
	#superclass : #Object,
	#instVars : [
		'changesHandler',
		'debuggerProcess'
	],
	#category : #'IDRA-ReadyToUse'
}

{ #category : #'as yet unclassified' }
DebuggerWithChangesHandler class >> addressToString: anAddress [
	| returnValue|
	
	returnValue := ''.
	anAddress do: [ :each |
		returnValue := (returnValue , (each printString) , '.') ].
	
	^(returnValue truncateTo: (returnValue size -1)).
]

{ #category : #'as yet unclassified' }
DebuggerWithChangesHandler class >> setupAsDebuggerMonitorOnURL: aUrl port: aDebuggerPort listeningChangesOnPort: aChangesPort [
	
	| instance |
	instance := self new.
	IDRAMonitor connectToManagerIP: aUrl port: aDebuggerPort.
	instance changesHandler: (IDRAChangesHandler newChangesListenerOnPort: aChangesPort).
	instance changesHandler addObserver: (IDRADebugger getInstance ).
	^instance.
]

{ #category : #'as yet unclassified' }
DebuggerWithChangesHandler class >> setupAsDebuggerMonitorOnURL: aUrl port: aDebuggerPort listeningChangesUrl: aChangesHost port: aChangesPort [
	
	| instance |
	instance := self new.
	IDRAMonitor connectToManagerIP: aUrl port: aDebuggerPort.
	instance changesHandler: (IDRAChangesHandler newChangesListenerOnPort: aChangesPort url: aChangesHost).
	instance changesHandler addObserver: (IDRAMonitor getInstance ).
	^instance.
]

{ #category : #'as yet unclassified' }
DebuggerWithChangesHandler class >> setupAsDebuggerOnPort: aPort [
	
	| instance |
	instance := self new.
	instance debuggerProcess: (IDRAManager setupOnPort:  aPort).
	^instance.
]

{ #category : #'as yet unclassified' }
DebuggerWithChangesHandler class >> setupAsDebuggerOnPort: aPort connectForChangesToPort: aChangesPort [
	
	| instance |
	instance := self new.
	instance debuggerProcess: (IDRAManager setServerModeOnPort: aPort whenConnected: 
		[:aSocket | instance connectToSendChangesToClientAddress: (aSocket remoteAddress) port: aChangesPort ]).
	^instance.
]

{ #category : #accessing }
DebuggerWithChangesHandler >> changesHandler [
	^changesHandler.
]

{ #category : #accessing }
DebuggerWithChangesHandler >> changesHandler: aHandler [
	changesHandler := aHandler.
]

{ #category : #accessing }
DebuggerWithChangesHandler >> connectToSendChangesToClientAddress: anAddress port: aPort [
	
	changesHandler connectChangesSocketToAddress: (DebuggerWithChangesHandler addressToString: anAddress) OnPort: aPort.
]

{ #category : #accessing }
DebuggerWithChangesHandler >> connectToSendChangesToClientURL: aURL port: aPort [
	
	changesHandler connectChangesSocketToUrl: aURL OnPort: aPort.
]

{ #category : #accessing }
DebuggerWithChangesHandler >> debuggerProcess: aProcess [
	debuggerProcess := aProcess.
]

{ #category : #accessing }
DebuggerWithChangesHandler >> fuelAccept: aGeneralMapper [
	aGeneralMapper visitSubstitution: self by: nil.
   "aGeneralMapper visitNotSerializable: self"
]

{ #category : #accessing }
DebuggerWithChangesHandler >> initialize [
	changesHandler := IDRAChangesHandler new.
]

{ #category : #accessing }
DebuggerWithChangesHandler >> stopDebugging [

	IDRADebugger getInstance stop.
	(1000 milliSeconds wait).
	(debuggerProcess isNotNil and: [ (debuggerProcess isTerminated) = false  ]) ifTrue: [ 
		debuggerProcess terminate ]. 
	
	changesHandler stopListening.
]
