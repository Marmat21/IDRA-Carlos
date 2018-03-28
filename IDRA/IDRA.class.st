"
I represent an IDRA Debugger.

You can start me in two ways using the DebuggerWithChangesHandler class: 
1. debugger monitor mode to listen for exceptions.
2. debugger manager mode to debug such exceptions.

You can start it as MANAGER in the following way:
DebuggerWithChangesHandler setupAsDebuggerOnPort: <managerPort>.

You can start it as MONITOR in the following way:
DebuggerWithChangesHandler setupAsDebuggerMonitorOnURL: 'managerHttpServerURL'  port: managerHttpServerPort listeningChangesUrl: 'myHttpServerUrl' port: myChangesServerPort.

You can connect a MONITOR to a manager (if want to connect later) via:
IDRAMonitor connectToManagerIP:<managerIp> port: <managerPort>.

You can start listening on all exceptions (on MONITOR side) with:
IDRAMonitor getInstance debugAll: true.
"
Class {
	#name : #IDRA,
	#superclass : #Object,
	#traits : 'TSerializingProtocol',
	#classTraits : 'TSerializingProtocol classTrait',
	#instVars : [
		'started',
		'eventsQueue',
		'connectionSocket',
		'interactionSockets',
		'worker',
		'serializer',
		'serializing',
		'clientSocket',
		'count',
		'writtenBytes',
		'timer',
		'lastTime',
		'currentVersion',
		'orderedQueue',
		'table',
		'storedExceptionsQueue',
		'currentStrategy',
		'restartingVersion',
		'lastMaster',
		'connectionStatus',
		'interactingProcess',
		'servingProcess',
		'restartFromMethodSelector',
		'restartSenderSelector',
		'messageSerializer'
	],
	#classInstVars : [
		'clientSocket'
	],
	#category : #'IDRA-Debugger'
}

{ #category : #utils }
IDRA class >> detectInstance [
	IDRAManager isRunning ifTrue: [ 
		^IDRAManager getInstance ] ifFalse: [ 
		^IDRAMonitor getInstance  ]
]

{ #category : #utils }
IDRA class >> findContextInAStack: aStack [
	self detectInstance findContextInAStack: aStack.
]

{ #category : #utils }
IDRA class >> getInstance [
	^ self detectInstance.
]

{ #category : #serialization }
IDRA >> addPostMaterializationToSerializer: aPostMaterBlock [
	serializer addPostMaterializationAction: aPostMaterBlock.
]

{ #category : #'queue-handling' }
IDRA >> errorsMaterialization [
"return the post-materialization action associated to errors"
	 ^[ :materialization | 		
			IDRAManager  debugClientException: (materialization root first) InContext: (materialization 				root second). ].
]

{ #category : #communication }
IDRA >> eventsQueue [
	^eventsQueue.


]

{ #category : #initialization }
IDRA >> findContextInAStack: aStack [
	aStack
		findContextSuchThat: [ :each | 
			each methodSelector == restartFromMethodSelector
				and: [ each sender methodSelector == restartSenderSelector ] ]
]

{ #category : #initialization }
IDRA >> fuelAccept: aGeneralMapper [
    aGeneralMapper visitSubstitution: self by: nil
]

{ #category : #serialization }
IDRA >> handleError: anError inContext: aContext [ 
		self handleError: anError inContext: aContext strategy: currentStrategy.
]

{ #category : #serialization }
IDRA >> handleError: anError inContext: aContext strategy: aStrategy [
		eventsQueue nextPut: {anError . aContext . currentVersion . aStrategy}.
		storedExceptionsQueue addLast: { anError . aContext . currentVersion . aStrategy}.
		table refresh. 
]

{ #category : #serialization }
IDRA >> handleMessage: aMessage [
	| ch |
	(aMessage first = 'changesListenerOnport') ifTrue: [ 
		ch := IDRAChangesHandler newChangesSender.
		ch connectChangesSocketToUrl: (aMessage third) OnPort: (aMessage second).
		 ]
]

{ #category : #serialization }
IDRA >> handleMessage: aMessage fromUrl: anUrl [
	| ch |
	aMessage first == 'changesListenerOnport' ifTrue: [ 
		ch := IDRAChangesHandler newChangesSender.
		ch addObserver: self.
		ch connectChangesSocketToUrl: anUrl OnPort: aMessage second.
		 ]
]

{ #category : #initialization }
IDRA >> initialize [
	interactionSockets := OrderedCollection new.
	eventsQueue := WaitfreeQueue new.
	storedExceptionsQueue := OrderedCollection new.
	started := false.
	serializer := FLSerializer newDefault.
	currentStrategy := DefaultStrategy.
	messageSerializer := FLSerializer newDefault.
	messageSerializer addPostMaterializationAction: (self messageMaterialization).
]

{ #category : #communication }
IDRA >> interactOnConnection [
	| interactionSocket   |
"Build a new socket for interaction with a client which connection request is accepted"
interactionSocket := connectionSocket waitForAcceptFor: 60 ifTimedOut: [ ^self ].

interactionSockets add: interactionSocket.
1000 milliSeconds wait.

interactingProcess := [ self interactWithSocket: interactionSocket ] fork.


]

{ #category : #accessing }
IDRA >> interactionSockets [
	^interactionSockets.
]

{ #category : #'queue-handling' }
IDRA >> isConnectionAlive [
	^false.
]

{ #category : #'queue-handling' }
IDRA >> messageMaterialization [
	"return the post-materialization action associated to errors"
	 ^[ :materialization | 		
			IDRA detectInstance handleMessage: (materialization root)  ].
]

{ #category : #'queue-handling' }
IDRA >> messageMaterializationFromUrl: anUrl [
	"return the post-materialization action associated to errors"
	 ^[ :materialization | 		
			IDRA detectInstance handleMessage: (materialization root first) fromUrl: anUrl. ].
]

{ #category : #communication }
IDRA >> openClientSocketWithServerURL: serverURL port: aPort [
	"[self getInstance listenForChangesOnPort: 33333] fork."
	clientSocket ifNotNil: [ 
		clientSocket isConnected ifTrue:[
		clientSocket close] ].
	lastMaster := { serverURL . aPort }.
	[clientSocket := SocketStream openConnectionToHostNamed: serverURL  port: aPort.
	clientSocket binary.
	started := true.
	connectionStatus := 0.] on: Error do: [ :e | clientSocket := nil. 1 inform: 'Connection to manager failed.' ].
^ (clientSocket isNil)
	
]

{ #category : #communication }
IDRA >> orderedQueue [
	^storedExceptionsQueue.

]

{ #category : #initialization }
IDRA >> resetWrite [
	writtenBytes := 0.
	count := 0.
]

{ #category : #initialization }
IDRA >> restartExceptionTuple: aTuple withDebuggerProcess: aDebuggerProcess proceeding: aBoolean [
	
	(aTuple third) = restartingVersion ifTrue: [ 
		(aTuple fourth) restartWithParameters: { aBoolean . aTuple . aDebuggerProcess }.
		^true.
		 ] ifFalse: [ 
		^false ] 
]

{ #category : #serialization }
IDRA >> serializeOnSocketStreamMessage: anObject [
	[ self serializeAnObject: anObject OnSocket: clientSocket withSerializer: messageSerializer ]
		on: Error
		do: [ :e | 
			1 inform: 'Error during serialization '.
			1 inform: e description.
			1 inform: 'there was a serialization error'.
			serializer = FLSerializer newDefault ].
	serializing := false
]

{ #category : #serialization }
IDRA >> serializeOnSocketStreamObject: anObject [
	[ self serializeAnObject: anObject OnSocket: clientSocket withSerializer: serializer ]
		on: Error
		do: [ :e | 
			1 inform: 'Error during serialization '.
			1 inform: e description.
			1 inform: 'there was a serialization error'.
			serializer = FLSerializer newDefault ].
	serializing := false
]

{ #category : #serialization }
IDRA >> serializeOnSocketStreamObjectDeprecated: anObject [
	|   sentStream |
	[ FuelOutStackDebugAction encodeDebugInformationOn: serializer.
	"----------------uncomment to benchmark-------------"
	"resultString := ByteArray new: 1000000000."
	"writeStream := resultString writeStream.
  	writeStream binary.
  	serializer serialize: anObject  on: writeStream."
	"Transcript crLog: writeStream position.
	writtenBytes := writtenBytes + (writeStream position)."
	"sentStream := ByteArray new: writeStream position."
	"1 to: writeStream position do: [ :i | sentStream at:i put: (resultString at: i) ].
	1 inform: 'serializing'."
	"serializer serialize: anObject   on: clientSocket."
	sentStream := ByteArray streamContents: [ :s | serializer serialize: anObject on: s ].
	clientSocket nextPutAll:  (#(0 0 0 0 1 1 1 1) asByteArray ).
	clientSocket nextPutAll: (sentStream size asByteArrayOfSize: 4).
	clientSocket nextPutAll: sentStream.
	clientSocket flush.
	1 inform: 'Serialized' ]
		on: Error
		do: [ :e | 
			1 inform: 'Error during serialization '.
			1 inform: e description.
			1 inform: 'there was a serialization error'.
			serializer = FLSerializer newDefault ].
	
	serializing := false
]

{ #category : #'queue-handling' }
IDRA >> serve [
started := true.
[ [ self started ]
whileTrue: [ self interactOnConnection ] ]
ensure: [ connectionSocket closeAndDestroy ].
]

{ #category : #'queue-handling' }
IDRA >> serveQueue [
	self subclassResponsibility.
]

{ #category : #'queue-handling' }
IDRA >> serveQueueProcess [
		| spawnedProcess |
	spawnedProcess := [
		[started] whileTrue: [  
			50 milliSeconds wait.
			self serveQueue.
		] ]newProcess  .
	spawnedProcess resume. 
	^spawnedProcess.
]

{ #category : #'queue-handling' }
IDRA >> showStackStatus [

	table := FTTableMorph new
		extent: 650@500;
		addColumn: (FTColumn id: 'Error Name');
		addColumn: (FTColumn id: 'Method Selector');
		dataSource: (TupleDataSource  elements: (self orderedQueue)) ;
		selectRowIndex: 1;
		showFirstRowSelection;
		onAnnouncement: FTSelectionChanged 
			do: [ :ann | ('rows selected: ', (ann newSelectedRowIndexes asString)) crLog ];
		onAnnouncement: FTStrongSelectionChanged 
			do: [ :ann | ('double-click on row: ', (ann selectedRowIndex asString)) crLog ];
		beMultipleSelection;
		yourself.
		
	^ table openInWindowLabeled: 'Errors Queue Status'
]

{ #category : #accessing }
IDRA >> signalCodeChanged [
"add here in the subclass the code to execute after a code change is executed"
]

{ #category : #accessing }
IDRA >> signalCodeChangedWithRestartDetails: details [
"add here in the subclass the code to execute after a code change is executed"
]

{ #category : #'queue-handling' }
IDRA >> startAsServerOnPort: aPort [
connectionSocket := Socket newTCP.
connectionSocket listenOn: aPort backlogSize: 10.
servingProcess := [ self serve ] forkAt: 70.
]

{ #category : #accessing }
IDRA >> started [
	^started.
]

{ #category : #'queue-handling' }
IDRA >> stop [
started := false.
100 milliSeconds wait.
interactingProcess ifNotNil: [ interactingProcess terminate. ].
100 milliSeconds wait.
servingProcess ifNotNil: [ servingProcess terminate. ].
100 milliSeconds wait.
table owner close.


]

{ #category : #accessing }
IDRA >> worker [
	^worker.
]

{ #category : #accessing }
IDRA >> worker: aWorker [
	worker := aWorker.
]

{ #category : #initialization }
IDRA >> writtenBytes [
	^writtenBytes.
]
