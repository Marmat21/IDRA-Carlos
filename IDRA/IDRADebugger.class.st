Class {
	#name : #IDRADebugger,
	#superclass : #IDRA,
	#instVars : [
		'autoRestart',
		'restartNext',
		'restertOuterContextSelector',
		'done',
		'debuggerProcess',
		'changesSocket',
		'serializedErrors',
		'changeToApply',
		'process',
		'debuggingAll',
		'restartingStrategy',
		'exceptionHandler',
		'debugger',
		'tuple',
		'serializingMutex'
	],
	#classInstVars : [
		'currentInstance',
		'clientMode'
	],
	#category : #'IDRA-Deprecated'
}

{ #category : #'as yet unclassified' }
IDRADebugger class >> clientSocket [
	^clientSocket.
]

{ #category : #'as yet unclassified' }
IDRADebugger class >> debugClientException: anException InContext: aContext [
self getInstance handleError: anException inContext: aContext.
]

{ #category : #'as yet unclassified' }
IDRADebugger class >> getInstance [
	Error new signal: 'This version of IDRA is Deprecated. You should now use IDRAManager and IDRAMonitor'
	"clientMode ifNil: [ 
		clientMode := true. ].
	currentInstance ifNil: [ 
		currentInstance := self new.] .
	^currentInstance."
]

{ #category : #'as yet unclassified' }
IDRADebugger class >> monitorMode [
	^clientMode .
]

{ #category : #'as yet unclassified' }
IDRADebugger class >> resetInstance [
	currentInstance isNotNil ifTrue:[
		currentInstance stop.
	].
	currentInstance := nil.
]

{ #category : #initialization }
IDRADebugger class >> setManagerModeOnPort: aPort [
	"[self getInstance listenForChangesOnPort: 33333] fork."
	self resetInstance.
	clientMode := false.
	^ ([self getInstance startAsServerOnPort:  aPort] fork).
	
	
]

{ #category : #initialization }
IDRADebugger class >> setMonitorModeWithServerIP: serverIP port: aPort [
	"[self getInstance listenForChangesOnPort: 33333] fork."
	| instance |
	self resetInstance.
	instance := self getInstance.
	clientMode := true .
	instance openClientSocketWithServerURL: serverIP port: aPort.
	
]

{ #category : #initialization }
IDRADebugger class >> setServerModeOnPort: aPort whenConnected: aBlock [
	"[self getInstance listenForChangesOnPort: 33333] fork."
	self resetInstance.
	clientMode := false.
	^ ([self getInstance startAsServerOnPort:  aPort whenConnected: aBlock] fork).
	
	
]

{ #category : #utils }
IDRADebugger >> cutStack: aStack beforeSelector: aSelector [ 

| context |

context := aStack findContextSuchThat: [ :ctx |
					(ctx methodSelector = aSelector)].
				^ aStack cut: context.
]

{ #category : #utils }
IDRADebugger >> cutStack: aStack beforeSelector: aSelector class: selectorClass [

| context |

context := aStack findContextSuchThat: [ :ctx |
					(ctx methodSelector = aSelector) and: (ctx methodClass = selectorClass)].
				^ aStack cut: context.
]

{ #category : #handling }
IDRADebugger >> debugAll: aBoolean [
	debuggingAll := aBoolean.
	
]

{ #category : #'queue-handling' }
IDRADebugger >> debugger [
	^debugger.
]

{ #category : #handling }
IDRADebugger >> debuggerProcess [
	^debuggerProcess.
	
]

{ #category : #handling }
IDRADebugger >> exceptionHandler [
 ^exceptionHandler.
	
]

{ #category : #handling }
IDRADebugger >> exceptionHandler: aHandler [
 exceptionHandler := aHandler.
	
]

{ #category : #utils }
IDRADebugger >> findContextInAStack: aStack [
	aStack do: [ :each |
			 ((each methodSelector == restartFromMethodSelector) and: [ each sender methodSelector == restartSenderSelector ]) ifTrue: [
				"test"
			^each]
	 ].
]

{ #category : #initialization }
IDRADebugger >> findTaskFromContext: aContext [
	| context |
		context := aContext findContextSuchThat: [ :ctx |
					(ctx methodSelector = 'executeTask:')].
		
		^(context arguments first task)
]

{ #category : #hooks }
IDRADebugger >> fuelAccept: aGeneralMapper [
    aGeneralMapper visitSubstitution: self by: nil
]

{ #category : #handling }
IDRADebugger >> handleBreakpoint: aBreakpoint inContext: aContext [
		"self handleBreakpoint: aBreakpoint inContext: aContext tasked: false."
		self handleBreakpoint: aBreakpoint inContext: aContext strategy: DefaultStrategy.
	
]

{ #category : #handling }
IDRADebugger >> handleBreakpoint: aBreakpoint inContext: aContext strategy: aStrategy [

		eventsQueue nextPut: {aBreakpoint . aContext . currentVersion . aStrategy }.
		table refresh. 
	
]

{ #category : #handling }
IDRADebugger >> handleBreakpoint: aBreakpoint inContext: aContext tasked: isTasked [

		eventsQueue nextPut: {aBreakpoint . aContext . currentVersion . isTasked }.
		table refresh. 
	
]

{ #category : #handling }
IDRADebugger >> handleError: anError inContext: aContext [
		"self handleError: anError inContext: aContext tasked: false."
		self handleError: anError inContext: aContext strategy: DefaultStrategy .
	
]

{ #category : #handling }
IDRADebugger >> handleError: anError inContext: aContext sendingContext: aContextToSend [
		"self handleError: anError inContext: aContext tasked: false."
		self handleError: anError inContext: aContext sendingContext: aContextToSend strategy: DefaultStrategy .
	
]

{ #category : #handling }
IDRADebugger >> handleError: anError inContext: aContext sendingContext: aContextToSend strategy: aStrategy [
		timer start.
		eventsQueue nextPut: {anError . aContextToSend . currentVersion . aStrategy}.
		storedExceptionsQueue addLast: { anError . aContext . currentVersion . aStrategy}.
		table refresh. 
	
]

{ #category : #handling }
IDRADebugger >> handleError: anError inContext: aContext strategy: aStrategy [
		eventsQueue nextPut: {anError . aContext . currentVersion . aStrategy}.
		storedExceptionsQueue addLast: { anError . aContext . currentVersion . aStrategy}.
		table refresh. 
	
]

{ #category : #handling }
IDRADebugger >> handleError: anError inContext: aContext tasked: isTasked [
		eventsQueue nextPut: {anError . aContext . currentVersion . isTasked}.
		storedExceptionsQueue addLast: { anError . aContext . currentVersion . isTasked}.
		table refresh. 
	
]

{ #category : #initialization }
IDRADebugger >> initialize [
	super initialize.
	storedExceptionsQueue := OrderedCollection new.
	serializedErrors := WaitfreeQueue new.
	self addPostMaterializationToSerializer: (self errorsMaterialization).
	started := true.
	autoRestart := false.
	restartNext := false.
	done := false.
	process isNotNil ifTrue: [ 
		process isTerminated ifFalse: [ 
			process terminate. ] ].
	process := self serveQueueProcess.
	self showStackStatus.
	currentVersion := 0.
	restartingVersion := 0.
	serializing := false.
	changeToApply := false.
	debuggingAll := false.
	exceptionHandler := MyExceptionHandler.
	serializingMutex := Mutex new.
	timer := SMarkTimer new.
	count := 0.
	writtenBytes := 0.
	
	
]

{ #category : #handling }
IDRADebugger >> isDebuggingAll [
	^debuggingAll
	
]

{ #category : #accessing }
IDRADebugger >> orderedQueue [
	^storedExceptionsQueue.
]

{ #category : #initialization }
IDRADebugger >> reScheduleFromContext: aContext [
	| task |
	task := self findTaskFromContext: aContext.
	worker runner schedule: task.
]

{ #category : #accessing }
IDRADebugger >> resetTimer [
	timer reset.
]

{ #category : #accessing }
IDRADebugger >> restartFromMethodSelector [
	^ restartFromMethodSelector
]

{ #category : #accessing }
IDRADebugger >> restartFromMethodSelector: obj [
	restartFromMethodSelector := obj.
]

{ #category : #actions }
IDRADebugger >> restartNextWithContext: aContext [
	restartNext := true.
	restartFromMethodSelector := aContext  methodSelector.
	restartSenderSelector := (aContext sender  ) methodSelector. 
]

{ #category : #accessing }
IDRADebugger >> restartSenderSelector [
	^ restartSenderSelector
]

{ #category : #accessing }
IDRADebugger >> restartSenderSelector: obj [
	restartSenderSelector := obj.
]

{ #category : #actions }
IDRADebugger >> restartSingleDebugSessionWithError: anError process: aProcess [
 "get the debugger"
	| debugSession stack foundContext |
	debugSession := aProcess proceedDebugSessionStartedAt: (anError signalerContext ).
	"get the stack"
	stack := debugSession stack.
	foundContext := nil.
	"look if the method selector is present in the stack"
	foundContext := self findContextInAStack: stack.
	"if i found a context restart and proceed the debugSession from that context"
	foundContext isNotNil ifTrue: [ 
		debugSession restart: foundContext.
		debugSession resume.
	]
	"add the process back to the queue ifFalse"
	
]

{ #category : #actions }
IDRADebugger >> restartSingleDebugSessionWithoutProceedingWithError: anError process: aProcess [
 "get the debugger"
	| debugSession stack foundContext |
	debugSession := aProcess proceedDebugSessionStartedAt: (anError signalerContext ).
	"get the stack"
	stack := debugSession stack.
	foundContext := nil.
	"look if the method selector is present in the stack"
	foundContext := self findContextInAStack: stack.
	"if i found a context restart and proceed the debugSession from that context"
	foundContext isNotNil ifTrue: [
		debugSession restart: foundContext.
	]
	
]

{ #category : #handling }
IDRADebugger >> restartingStrategy [
 ^restartingStrategy.
	
]

{ #category : #handling }
IDRADebugger >> restartingStrategy: aStrategy [
 restartingStrategy := aStrategy.
	
]

{ #category : #actions }
IDRADebugger >> serializeToSocketStreamTheException: anException withContext: aContext [
	self serializeOnSocketStreamObject: { anException . aContext }
]

{ #category : #'queue-handling' }
IDRADebugger >> serveQueue [
	"without the forx works with anError signalIn: thisContext "
	self class monitorMode ifFalse: [
		self serveQueueServerMode.
	] ifTrue: [ 
		changeToApply ifTrue: [
		autoRestart := true. 
		self serveQueueServerModeWithQueue: storedExceptionsQueue.
		(storedExceptionsQueue isEmpty) ifTrue: [ 
			changeToApply := false. ].
		] ifFalse: [ 
			self serveQueueClientMode.] ]
]

{ #category : #'queue-handling' }
IDRADebugger >> serveQueueClientMode [
	| |
	eventsQueue isEmpty
		ifFalse: [
			"serializing
				ifFalse: [ serializing := true."
					"[self serializeToSocketStreamTheContext: tuple second] fork."
			
					 tuple := eventsQueue nextOrNil.
					tuple fourth = TaskItStrategy
						ifTrue: [ | anError cuttedStack |
							anError := tuple first copy.
							cuttedStack := self cutStack: tuple second copy beforeSelector: 'doExecuteTask'.
							anError searchFrom: cuttedStack.
							self serializeToSocketStreamTheException: anError withContext: cuttedStack ]
						ifFalse: [ self serializeToSocketStreamTheException: (tuple first) withContext: (tuple second) ].
						"600 milliSeconds wait."] 
				"ifTrue: [ eventsQueue nextPut: tuple ] ]"
]

{ #category : #'queue-handling' }
IDRADebugger >> serveQueueServerMode [
	^ self serveQueueServerModeWithQueue: eventsQueue.
]

{ #category : #'queue-handling' }
IDRADebugger >> serveQueueServerModeWithQueue: aQueue [
	| currentError errorVersion strategy |
	aQueue isEmpty
		ifFalse: [ "take the next element in the queue"
			"in the case the queue is empty, put autoRestart a false"
			(debuggerProcess isNil or: [ debuggerProcess isTerminated ])
				ifTrue: [ aQueue = storedExceptionsQueue
						ifTrue: [ tuple := aQueue removeFirst ]
						ifFalse: [ tuple := aQueue nextOrNil.
							storedExceptionsQueue isEmpty
								ifFalse: [ storedExceptionsQueue remove: tuple ] ].
					table refresh.
					currentError := tuple first.
					"create a new process and with the context of the error and open a debugger in it"
					debuggerProcess := IDRADebuggerProcess
						forContext: tuple second
						priority: Processor activePriority.
					"BENCHMARKING"
					"timer := Time millisecondsSince: lastTime."
					"take the version of the error"
					errorVersion := tuple third.
					strategy := tuple fourth.
					"in the case I don't have to autoRestart proceed with a normal debugger opening in a 	context"
					(errorVersion ~= restartingVersion or: [ autoRestart not ])
						ifTrue: [ "in the case I have to autorestart proceed to get get the next debugger"
							restartNext
								ifFalse: [ currentError searchFrom: tuple second.
									debugger := debuggerProcess
										debug: currentError signalerContext
										title: currentError description ]
								ifTrue: [ DefaultStrategy
										restartWithParameters:
											{false.
											tuple.
											debuggerProcess}.
									"self restartSingleDebugSessionWithoutProceedingWithError: currentError process: 	debuggerProcess. "
									debuggerProcess debug ] ]
						ifFalse: [ self class monitorMode
								ifTrue: [ strategy
										restartWithParameters:
											{true.
											tuple.
											debuggerProcess}.
									"self reScheduleFromContext: (tuple second)."
									debuggerProcess := nil ]
								ifFalse: [ DefaultStrategy
										restartWithParameters:
											{true.
											tuple.
											debuggerProcess}
									"self restartSingleDebugSessionWithError: currentError process: debuggerProcess." ] ] ] ]
		ifTrue: [ autoRestart := false ]
]

{ #category : #actions }
IDRADebugger >> setRestartingContext: aContext [
	autoRestart := true.
	restartFromMethodSelector := aContext  methodSelector.
	(aContext sender isNil) ifFalse: [ 
		restartSenderSelector := (aContext sender  ) methodSelector. ]
		ifTrue: [ restartSenderSelector := nil ].
	restartingVersion := currentVersion.
	currentVersion := currentVersion + 1.
]

{ #category : #accessing }
IDRADebugger >> showConnectedClients [

	| clientCollection |
	clientCollection := interactionSockets collect: [ :socket | { socket localPort . socket remoteAddress } ].
	table := FTTableMorph new
		extent: 650@500;
		addColumn: (FTColumn id: 'Local Port');
		addColumn: (FTColumn id: 'Address');
		dataSource: (TupleDataSource  elements: clientCollection ) ;
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

{ #category : #signalling }
IDRADebugger >> signalCodeChanged [
	
	storedExceptionsQueue isEmpty ifFalse: [ 
	[changeToApply := true.
	self setRestartingContext: (storedExceptionsQueue first first baseContext).]
	on: Error do: [1 inform: 'could not find restarting context']].
]

{ #category : #signalling }
IDRADebugger >> signalCodeChangedWithRestartDetails: details [
	storedExceptionsQueue isEmpty
		ifFalse: [ [ restartFromMethodSelector := details first.
			restartSenderSelector := details second.
			changeToApply := true ]
				on: Error
				do: [ 1 inform: 'could not find restarting context' ] ]
]

{ #category : #accessing }
IDRADebugger >> stop [
	started := false.
]

{ #category : #accessing }
IDRADebugger >> timer [
	^timer.
]

{ #category : #handling }
IDRADebugger >> tuple [
	^tuple
]
