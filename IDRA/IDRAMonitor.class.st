Class {
	#name : #IDRAMonitor,
	#superclass : #IDRAWebServer,
	#instVars : [
		'tuple',
		'debuggingAll',
		'changeToApply',
		'strategy'
	],
	#classInstVars : [
		'currentInstance'
	],
	#category : #'IDRA-Debugger'
}

{ #category : #'as yet unclassified' }
IDRAMonitor class >> connectToManagerIP: serverIP port: aPort [
	| instance |
	"self resetInstance."
	instance := self getInstance.
	instance resetConnectionTries.
	instance openClientSocketWithServerURL: serverIP port: aPort. 
]

{ #category : #'as yet unclassified' }
IDRAMonitor class >> connectToManagerIP: serverIP port: aPort restartingStrategy: aStrategy [
	self connectToManagerIP: serverIP  port: aPort.
	self getInstance restartingStrategy: aStrategy.
]

{ #category : #initialization }
IDRAMonitor class >> deleteInstance [
	currentInstance := nil.
]

{ #category : #'as yet unclassified' }
IDRAMonitor class >> getInstance [
	currentInstance ifNil: [ 
		currentInstance := self new.] .
	^currentInstance.
]

{ #category : #testing }
IDRAMonitor class >> isRunning [
	^currentInstance isNotNil and: [ currentInstance started ]
]

{ #category : #'as yet unclassified' }
IDRAMonitor class >> resetInstance [
	currentInstance isNotNil ifTrue:[
		currentInstance stop.
	].
	currentInstance := nil.
]

{ #category : #'queue-handling' }
IDRAMonitor >> autoRestartAll [
	| currentTuple debuggerProcess |
	[ storedExceptionsQueue isEmpty ]
		whileFalse: [ currentTuple := storedExceptionsQueue nextOrNil.
			debuggerProcess := IDRADebuggerProcess
				forContext: tuple second
				priority: Processor activePriority.
			currentTuple fourth
				restartWithParameters:
					{true.
					tuple.
					debuggerProcess} ]
]

{ #category : #'queue-handling' }
IDRAMonitor >> connectionTryLimit [
	^5.
]

{ #category : #'queue-handling' }
IDRAMonitor >> debugAll: aBoolean [

	debuggingAll := aBoolean.
]

{ #category : #'queue-handling' }
IDRAMonitor >> fuelAccept: aGeneralMapper [
    aGeneralMapper visitSubstitution: self by: nil
				
]

{ #category : #'queue-handling' }
IDRAMonitor >> initialize [
	super initialize.
	self showStackStatus.
	started := true.
	servingProcess := self serveQueueProcess.
	changeToApply := false.
	self addPostMaterializationToSerializer: (self errorsMaterialization).
	connectionStatus := -1.
]

{ #category : #'queue-handling' }
IDRAMonitor >> isConnectionAlive [
	^ super isConnectionAlive or: [(clientSocket isNotNil and: [ clientSocket isConnected ])
		ifTrue: [ ^ true ]
		ifFalse: [ connectionStatus := connectionStatus + 1.
			(connectionStatus = self connectionTryLimit)
				ifTrue: [ UIManager default
						alert: 'I cannot reconnect to the selected IDRA Manager. Please proceed with a manual connection' ]
				ifFalse: [ (connectionStatus > self connectionTryLimit)
						ifFalse: [ self openClientSocketWithServerURL: lastMaster first port: lastMaster second ] ] ].
				^ false.]
				
]

{ #category : #'queue-handling' }
IDRAMonitor >> isDebuggingAll [
	^debuggingAll
]

{ #category : #accessing }
IDRAMonitor >> resetConnectionTries [
	connectionStatus := -1.
]

{ #category : #accessing }
IDRAMonitor >> restartingStrategy: aStrategy [
	currentStrategy := aStrategy.
]

{ #category : #'queue-handling' }
IDRAMonitor >> serializeToSocketStreamTheException: anException withContext: aContext [
	self serializeOnSocketStreamObject: { anException . aContext }.
]

{ #category : #'queue-handling' }
IDRAMonitor >> serveQueue [
	| errorAndStack |
	changeToApply
		ifTrue: [ ^ self autoRestartAll ].
	eventsQueue isEmpty
		ifTrue: [ ^ self ].
		
	self isConnectionAlive ifFalse: [ ^ self ].
	
	tuple := eventsQueue nextOrNil.
	
	"extract strategy and apply function to manipulate stack and error"
	errorAndStack := tuple fourth processError: tuple first inContext: tuple second.
	"serialize the exception (as changed by the restartingStrategy)"
	self
		serializeToSocketStreamTheException: errorAndStack first
		withContext: errorAndStack second.
]

{ #category : #'queue-handling' }
IDRAMonitor >> signalCodeChanged [
	storedExceptionsQueue isEmpty ifFalse: [ 
	[changeToApply := true.
	self setRestartingContext: (storedExceptionsQueue first first baseContext).]
	on: Error do: [1 inform: 'could not find restarting context']].
]

{ #category : #'queue-handling' }
IDRAMonitor >> signalCodeChangedWithRestartDetails: details [
	storedExceptionsQueue isEmpty
		ifFalse: [ [ restartFromMethodSelector := details first.
			restartSenderSelector := details second.
			changeToApply := true ]
				on: Error
				do: [ 1 inform: 'could not find restarting context' ] ]
]

{ #category : #accessing }
IDRAMonitor >> stop [
	super stop.
	self class deleteInstance.
]
