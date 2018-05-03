Class {
	#name : #IDRAManager,
	#superclass : #IDRAWebServer,
	#instVars : [
		'autoRestart',
		'debuggerProcess',
		'restartNext',
		'debugger'
	],
	#classInstVars : [
		'currentInstance'
	],
	#category : #'IDRA-Debugger'
}

{ #category : #'as yet unclassified' }
IDRAManager class >> debugClientException: anException InContext: aContext [
self getInstance handleError: anException inContext: aContext.
]

{ #category : #initialization }
IDRAManager class >> deleteInstance [
	currentInstance := nil.
	
]

{ #category : #'as yet unclassified' }
IDRAManager class >> getInstance [
	currentInstance ifNil: [ 
		currentInstance := self new.] .
	^currentInstance.
]

{ #category : #testing }
IDRAManager class >> isRunning [
	^ currentInstance isNotNil and: [ currentInstance started ]
]

{ #category : #initialization }
IDRAManager class >> resetInstance [
	currentInstance isNotNil ifTrue:[
		currentInstance stop.
	].
	currentInstance := nil.
	
]

{ #category : #'as yet unclassified' }
IDRAManager class >> setupOnPort: aPort [
	"[self getInstance listenForChangesOnPort: 33333] fork."
	self resetInstance.
	^ ([self getInstance startAsServerOnPort:  aPort] fork).
	
]

{ #category : #initialization }
IDRAManager >> fuelAccept: aGeneralMapper [
    aGeneralMapper visitSubstitution: self by: nil
]

{ #category : #'queue-handling' }
IDRAManager >> initialize [
 super initialize.
 autoRestart := false.
 restartNext := false.
 started := true.
 servingProcess isNotNil ifTrue: [ 
		servingProcess isTerminated ifFalse: [ 
			servingProcess terminate. ] ].
	servingProcess := self serveQueueProcess.
	self showStackStatus.
	currentVersion := 0.
	restartingVersion := 0.
]

{ #category : #'queue-handling' }
IDRAManager >> processError: aTuple [
	"This message processes an error tuple."

	| currentError context errorVersion |
	currentError := aTuple first.
	context := aTuple second.
	errorVersion := aTuple third.
	debuggerProcess := IDRADebuggerProcess
						forContext: aTuple second
						priority: Processor activePriority.
	((autoRestart and: [ errorVersion = restartingVersion ]) or: [ restartNext ])
		ifTrue: [ restartNext := false.
			^ self
				restartExceptionTuple: aTuple
				withDebuggerProcess: debuggerProcess
				proceeding: autoRestart ].
	currentError searchFrom: context.
	debugger := debuggerProcess
		debug: currentError signalerContext
		title: currentError description
]

{ #category : #initialization }
IDRAManager >> restartFromMethodSelector [
	^restartFromMethodSelector.
]

{ #category : #initialization }
IDRAManager >> restartNextWithContext: aContext [
	restartNext := true.
	restartFromMethodSelector := aContext  methodSelector.
	restartSenderSelector := (aContext sender  ) methodSelector. 
]

{ #category : #initialization }
IDRAManager >> restartSenderSelector [
	^restartSenderSelector.
]

{ #category : #'queue-handling' }
IDRAManager >> serveQueue [
	"this method serves the queue in manager mode.
This means that opens a debugger on the first exception. 
In the case autorestart is true it has to open the debugger, restart from the last point if present and proceed automatically the session"

	"first check if debugging session is still active"

	| tuple |
	(debuggerProcess isNil or: [ debuggerProcess isTerminating ])
		ifFalse: [ ^ self ].

	eventsQueue isEmpty
		ifTrue: [ autoRestart := false ]
		ifFalse: [ tuple := eventsQueue nextOrNil.
			storedExceptionsQueue isEmpty
				ifFalse: [ storedExceptionsQueue remove: tuple ].
				table refresh.
				"if I have to restart I do it here"
				(autoRestart) ifTrue: [ 
					DefaultStrategy restartWithParameters: { true . tuple. debuggerProcess  }.
					^self. ].
				
				restartNext ifTrue: [ 
					DefaultStrategy restartWithParameters: { false . tuple. debuggerProcess  }.
					restartNext := false.
					^self. 
					 ].
				
				
				self processError: tuple ]
]

{ #category : #initialization }
IDRAManager >> setRestartingContext: aContext [
	autoRestart := true.
	restartFromMethodSelector := aContext  methodSelector.
	(aContext sender isNil) ifFalse: [ 
		restartSenderSelector := (aContext sender  ) methodSelector. ]
		ifTrue: [ restartSenderSelector := nil ].
	restartingVersion := currentVersion.
	currentVersion := currentVersion + 1.
]

{ #category : #'queue-handling' }
IDRAManager >> stop [
	super stop.
	debuggerProcess ifNotNil: [ debuggerProcess terminate. ].
	self class deleteInstance.
]
